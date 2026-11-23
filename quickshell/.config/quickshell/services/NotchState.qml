pragma Singleton
import Quickshell

// What the notch is currently showing.
// Add new entries to Mode as more panels are built (Theme, Clipboard, ...).
Singleton {
    enum Mode {
        Idle,
        Launcher,
        Expand,
        Hoverd,
        ExpandedWide,
        VolumeMeter,
        BrightnessMeter,
        ControlCenter,
        SchemeChanger,
        PowerCenter
    }

    property int mode: NotchState.Mode.Idle

    readonly property bool open: mode !== NotchState.Mode.Idle

    function setMode(next): void {
        mode = next;
    }

    function close(): void {
        mode = NotchState.Mode.Idle;
    }

    function toggle(next): void {
        mode = (mode === next) ? NotchState.Mode.Idle : next;
    }
}
