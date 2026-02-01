import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
pragma Singleton

Singleton {
    id: root
    property var map: ({})

    function notifyMissingVariant(theme, variant) {
        Quickshell.execDetached(["notify-send", "Nucleus Shell", `Theme '${theme}' does not have a ${variant} variant.`, "--urgency=normal", "--expire-time=5000"]);
    }

    // Watch colorschemes folder for changes (event-based)
    Process {
        id: themeWatcher
        running: true
        command: ["inotifywait", "-m", "-e", "create,delete,modify", Directories.shellConfig + "/colorschemes"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes(".json")) {
                    loadThemes.running = true
                }
            }
        }
    }

    Process {
        id: loadThemes
        command: ["ls", Directories.shellConfig + "/colorschemes"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                text.split("\n").map((t) => {
                    return t.trim();
                }).filter((t) => {
                    return t.endsWith(".json");
                }).forEach((t) => {
                    const name = t.replace(/\.json$/, "");
                    const parts = name.split("-");
                    const variant = parts.pop();
                    const themeName = parts.join("-");
                    if (!map[themeName])
                        map[themeName] = {};
                    map[themeName][variant] = name;
                });
                root.map = map;
            }
        }
    }

    // Load once on startup
    Component.onCompleted: {
        loadThemes.running = true
    }
}
