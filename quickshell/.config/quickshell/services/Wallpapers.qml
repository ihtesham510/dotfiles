pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string defaultWallpaper: root.directory + "/anime girl.jpg"
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell"
    readonly property string stateFile: root.cacheDir + "/wallpaper"
    readonly property string schemeFile: root.cacheDir + "/scheme"
    readonly property string applyScript: Quickshell.env("HOME") + "/.config/matugen/apply.sh"

    property string current: root.defaultWallpaper

    Process {
        id: loadState
        command: ["sh", "-c", "[ -f \"$1\" ] && cat \"$1\"", "sh", root.stateFile]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                if (path.length > 0)
                    root.current = path;
                root.applyColours();
            }
        }
    }

    Process {
        id: colours
        command: ["sh", "-c", "mkdir -p \"$1\"; command -v matugen >/dev/null 2>&1 || exit 0; scheme=$(cat \"$3\" 2>/dev/null); [ -n \"$scheme\" ] || scheme=scheme-tonal-spot; sh \"$4\" \"$2\" \"$scheme\" >/dev/null 2>&1 || exit 1; " + "command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1", "sh", root.cacheDir, root.current, root.schemeFile, root.applyScript]

        onExited: Colours.refresh()
    }

    function applyColours(): void {
        if (root.current.length === 0)
            return;
        colours.running = false;
        colours.running = true;
    }

    Process {
        id: saveState
        command: ["sh", "-c", "mkdir -p \"$(dirname \"$2\")\" && printf '%s' \"$1\" > \"$2\"", "sh", root.current, root.stateFile]
        running: false
    }

    FolderListModel {
        id: files

        folder: "file://" + root.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif"]
        showDirs: false
        sortField: FolderListModel.Name
        sortCaseSensitive: false
    }

    function all(): var {
        const out = [];
        for (let i = 0; i < files.count; i++)
            out.push({
                name: files.get(i, "fileName"),
                path: files.get(i, "filePath")
            });
        return out;
    }

    function search(query: string): var {
        const list = root.all();
        const q = query.trim().toLowerCase();
        if (q.length === 0)
            return list;
        return list.filter(w => w.name.toLowerCase().indexOf(q) !== -1);
    }

    function setCurrent(path: string): void {
        if (path.length === 0 || path === root.current)
            return;
        root.current = path;
        saveState.running = true;
        root.applyColours();
    }
}
