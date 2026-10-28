pragma Singleton
import Quickshell

// One clock for the whole shell, so every widget ticks off the same source.
Singleton {
    id: root

    readonly property alias date: source.date

    SystemClock {
        id: source
        precision: SystemClock.Seconds
    }
}
