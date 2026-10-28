pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for the network state, polled every 5 seconds.
Singleton {
    id: root

    property string label: "Offline"
    readonly property bool online: label !== "Offline"

    function refresh(): void {
        if (!probe.running)
            probe.running = true;
    }

    Process {
        id: probe
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]

        stdout: StdioCollector {
            onStreamFinished: {
                let label = "Offline";
                for (const line of text.trim().split("\n")) {
                    const p = line.split(":");
                    if (p[1] !== "connected")
                        continue;
                    if (p[0] === "wifi") {
                        label = "Wi-Fi";
                        break;
                    }
                    if (p[0] === "ethernet")
                        label = "Ethernet";
                }
                root.label = label;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
