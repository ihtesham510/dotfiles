pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell"
    readonly property string modeFile: root.cacheDir + "/mode"
    readonly property string schemeFile: root.cacheDir + "/scheme"
    readonly property string applyScript: Quickshell.env("HOME") + "/.config/matugen/apply.sh"

    readonly property var schemes: [
        {
            value: "scheme-content",
            name: "Content",
            icon: "image"
        },
        {
            value: "scheme-expressive",
            name: "Expressive",
            icon: "brush"
        },
        {
            value: "scheme-fidelity",
            name: "Fidelity",
            icon: "verified"
        },
        {
            value: "scheme-fruit-salad",
            name: "Fruit Salad",
            icon: "cherry"
        },
        {
            value: "scheme-monochrome",
            name: "Monochrome",
            icon: "contrast"
        },
        {
            value: "scheme-neutral",
            name: "Neutral",
            icon: "opacity"
        },
        {
            value: "scheme-rainbow",
            name: "Rainbow",
            icon: "palette"
        },
        {
            value: "scheme-tonal-spot",
            name: "Tonal Spot",
            icon: "droplet"
        },
        {
            value: "scheme-vibrant",
            name: "Vibrant",
            icon: "sparkles"
        }
    ]

    property string mode: "dark"
    property string scheme: "scheme-tonal-spot"

    readonly property var currentScheme: root.find(root.scheme)

    property bool ready: false

    signal changed

    function find(value: string): var {
        return root.schemes.find(s => s.value === value) ?? null;
    }

    Process {
        id: loadScheme
        command: ["sh", "-c", "[ -f \"$1\" ] && cat \"$1\"", "sh", root.schemeFile]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim();
                if (root.find(s) !== null)
                    root.scheme = s;
                loadMode.running = true;
            }
        }
    }

    Process {
        id: loadMode
        command: ["sh", "-c", "[ -f \"$1\" ] && cat \"$1\"", "sh", root.modeFile]
        running: false   // started by loadScheme

        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.trim();
                if (m === "dark" || m === "light")
                    root.mode = m;
                root.ready = true;
            }
        }
    }

    Process {
        id: saveMode
        command: ["sh", "-c", "mkdir -p \"$(dirname \"$2\")\" && printf '%s' \"$1\" > \"$2\"", "sh", root.mode, root.modeFile]
        running: false
    }

    Process {
        id: saveScheme
        command: ["sh", "-c", "mkdir -p \"$(dirname \"$2\")\" && printf '%s' \"$1\" > \"$2\"", "sh", root.scheme, root.schemeFile]
        running: false
    }

    Process {
        id: applyScheme
        command: ["sh", root.applyScript, Wallpapers.current, root.scheme]
        running: false

        onExited: {
            Colours.refresh();
            Quickshell.execDetached(["sh", "-c", "command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1"]);
        }
    }

    function setMode(m: string): void {
        if ((m !== "dark" && m !== "light") || m === root.mode)
            return;
        root.mode = m;
        saveMode.running = true;
        root.changed();
    }

    function toggleMode(): void {
        root.setMode(root.mode === "dark" ? "light" : "dark");
    }

    function setScheme(s: string): void {
        if (root.find(s) === null || s === root.scheme)
            return;
        root.scheme = s;
        saveScheme.running = true;
        applyScheme.running = false;
        applyScheme.running = true;
        root.changed();
    }

    function cycleScheme(): void {
        const i = root.schemes.findIndex(s => s.value === root.scheme);
        root.setScheme(root.schemes[(i + 1) % root.schemes.length].value);
    }
}
