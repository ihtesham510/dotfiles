//@ pragma IconTheme Papirus-Dark
// Quickshell's icons follow Qt's platform-theme icon theme, which currently
// falls back to hicolor here. hicolor has app icons but no UI glyphs like
// system-search, so pin the theme the rest of the desktop uses.
import Quickshell
import qs.notch

Scope {
    id: root

    Wallpaper {}

    Notch {}
}
