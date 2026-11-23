pragma Singleton
import Quickshell
import QtQuick

Singleton {
    function url(name: string): url {
        return "file://" + Quickshell.shellPath("svgs/" + name + ".svg");
    }
}
