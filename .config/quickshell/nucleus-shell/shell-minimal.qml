import Quickshell
import QtQuick 
import qs.config
import qs.plugins
import qs.services
import qs.modules.interface.notifications
import qs.modules.interface.sidebarRight
import qs.modules.interface.settings

ShellRoot {
    LazyLoader {
        id: notificationsLoader
        source: Contracts.notifications
        active: Config.runtime.notifications.enabled
    }
    LazyLoader {
        id: sidebarRightLoader
        source: Contracts.sidebarRight
        active: Globals.visiblility.sidebarRight
    }
    Settings { }
    Ipc { }
    UpdateNotifier { }
}
