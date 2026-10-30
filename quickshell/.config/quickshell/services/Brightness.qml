pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness for the OSD.
//
// Quickshell 0.3 has no brightness service, so this talks to brightnessctl.
// `available` stays false when there is no backlight device (a desktop with
// only external monitors has no /sys/class/backlight), and then the OSD is not
// shown at all instead of pretending the key did something.
Singleton {
    id: root

    property int percent: 0
    property bool available: false

    // Keyboard shortcut step, in percent.
    readonly property int step: 5
    // Finer step for the mouse wheel / trackpad.
    readonly property int wheelStep: 2

    // Queued value for the next write, -1 when idle. Key repeat can ask for a
    // new level while the previous brightnessctl call is still running.
    property int pending: -1

    signal brightnessUpdated

    // brightnessctl -m -c backlight prints: device,class,current,percent,max.
    //
    // The class filter matters: without it brightnessctl falls back to any
    // device it can find (keyboard LEDs on a desktop), which would make the OSD
    // appear with a meaningless level.
    Process {
        id: readProc
        command: ["brightnessctl", "-m", "-c", "backlight"]

        stdout: StdioCollector {
            id: readOut
            onStreamFinished: {
                const fields = readOut.text.trim().split(",");
                if (fields.length < 5)
                    return;

                const current = Number(fields[2]);
                const max = Number(fields[4]);
                if (!isFinite(current) || !isFinite(max) || max <= 0)
                    return;

                root.available = true;
                root.percent = Math.round((current / max) * 100);
            }
        }

        onExited: (exitCode, exitStatus) => {
            // No backlight device: hide the OSD instead of faking a level.
            if (exitCode !== 0)
                root.available = false;
        }
    }

    Process {
        id: writeProc
        onExited: {
            if (root.pending >= 0)
                root.flush();
            else
                root.refresh();
        }
    }

    Component.onCompleted: root.refresh()

    function refresh(): void {
        if (!readProc.running)
            readProc.running = true;
    }

    function flush(): void {
        const next = root.pending;
        root.pending = -1;
        writeProc.command = ["brightnessctl", "-c", "backlight", "set", next + "%"];
        writeProc.running = true;
    }

    function setPercent(value: real): void {
        if (!root.available)
            return;

        const next = Math.max(1, Math.min(100, Math.round(value)));
        root.percent = next;
        root.pending = next;
        // Always notify, even when clamped: the user did press the key.
        root.brightnessUpdated();

        if (!writeProc.running)
            root.flush();
    }

    function up(): void {
        root.setPercent(root.percent + root.step);
    }

    function down(): void {
        root.setPercent(root.percent - root.step);
    }

    // qs ipc call brightness up
    // qs ipc call brightness down
    // qs ipc call brightness set 40
    // qs ipc call brightness get
    IpcHandler {
        target: "brightness"

        function up(): void {
            root.up();
        }

        function down(): void {
            root.down();
        }

        function set(percent: int): void {
            root.setPercent(percent);
        }

        function get(): int {
            return root.percent;
        }
    }
}
