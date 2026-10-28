pragma Singleton
import Quickshell

// Application database + search, backed by Quickshell's DesktopEntries.
// The binding on `apps` re-evaluates when the desktop entry scan finishes.
Singleton {
    id: root

    readonly property var apps: {
        const entries = DesktopEntries.applications.values;
        const out = [];

        for (let i = 0; i < entries.length; i++) {
            const entry = entries[i];
            if (entry && entry.name && !entry.noDisplay)
                out.push(entry);
        }

        return out;
    }

    function search(query): var {
        const q = query.trim().toLowerCase();
        const list = root.apps;

        if (q.length === 0) {
            const all = list.slice();
            all.sort((a, b) => a.name.localeCompare(b.name));
            return all;
        }

        const matches = [];
        for (let i = 0; i < list.length; i++) {
            const score = rank(list[i], q);
            if (score > 0)
                matches.push({ entry: list[i], score: score });
        }

        matches.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
        return matches.map(m => m.entry);
    }

    // Higher is better; 0 means no match.
    function rank(entry, q): real {
        const name = (entry.name || "").toLowerCase();

        if (name === q)
            return 1000;

        if (name.indexOf(q) === 0)
            return 900 - Math.min(name.length, 90);

        const at = name.indexOf(q);
        if (at !== -1)
            return 800 - Math.min(at * 4 + name.length, 190);

        // keywords is exposed as a list, not a string.
        if (matches(entry.keywords, q))
            return 600;

        if (matches(entry.genericName, q))
            return 500;

        if (matches(entry.comment, q))
            return 400;

        // Subsequence match: "gimp" also matches
        // "GNU Image Manipulation Program".
        let qi = 0;
        let streak = 0;
        let points = 0;

        for (let i = 0; i < name.length && qi < q.length; i++) {
            if (name[i] === q[qi]) {
                qi++;
                streak++;
                points += streak * 2;
            } else {
                streak = 0;
            }
        }

        return qi === q.length ? 200 + points : 0;
    }

    // DesktopEntry fields can be a string or a list of strings.
    function matches(value, q): bool {
        if (!value)
            return false;

        if (typeof value === "string")
            return value.toLowerCase().indexOf(q) !== -1;

        for (let i = 0; i < value.length; i++) {
            if (String(value[i]).toLowerCase().indexOf(q) !== -1)
                return true;
        }

        return false;
    }
}
