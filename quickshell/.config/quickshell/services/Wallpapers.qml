pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel

// The wallpaper library and the currently applied wallpaper.
//
// The background renderer (Wallpaper.qml) and the picker both read `current`
// from here, so picking an image updates the desktop immediately.
Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string defaultWallpaper: root.directory + "/anime girl.jpg"
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell"
    readonly property string stateFile: root.cacheDir + "/wallpaper"

    property string current: root.defaultWallpaper

    // Restore the wallpaper picked last session. Quietly does nothing on the
    // first run, before the state file exists.
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

    // Rebuild the Material palette for the current wallpaper. matugen writes
    // ~/.cache/quickshell/colors.json (read by services/Colours.qml) and
    // ~/.config/hypr/scheme/current.lua, then Hyprland is told to reload so
    // window borders follow the wallpaper too. Missing matugen is not an
    // error: the shell just keeps its fallback colours.
    Process {
        id: colours
        command: ["sh", "-c", "mkdir -p \"$1\"; command -v matugen >/dev/null 2>&1 || exit 0; " + "matugen image \"$2\" --mode dark --type scheme-smart --source-color-index 0 >/dev/null 2>&1 || exit 1; " + "command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1", "sh", root.cacheDir, root.current]

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

    // Every wallpaper as { name, path }.
    function all(): var {
        const out = [];
        for (let i = 0; i < files.count; i++)
            out.push({
                name: files.get(i, "fileName"),
                path: files.get(i, "filePath")
            });
        return out;
    }

    // Case-insensitive filename search.
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
