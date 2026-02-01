import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property bool enabled: false
    
    function toggle() {
        enabled = !enabled
        console.log("Caffeinate toggled:", enabled)
        if (enabled) {
            Quickshell.execDetached(["systemd-inhibit", "--what=idle:sleep", "--who=Nucleus", "--why=Caffeinate", "sleep", "infinity"])
        }
    }
}
