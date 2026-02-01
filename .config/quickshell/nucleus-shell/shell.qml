import Quickshell
import QtQuick
import qs.config
import qs.plugins
import qs.services
import qs.modules.interface.bar
import qs.modules.interface.background
import qs.modules.interface.powermenu
import qs.modules.interface.launcher
import qs.modules.interface.notifications
import qs.modules.interface.intelligence
import qs.modules.interface.overlays
import qs.modules.interface.sidebarRight
import qs.modules.interface.settings
import qs.modules.interface.sidebarLeft
import qs.modules.interface.lockscreen
import qs.modules.interface.audioOutputPopup

ShellRoot {
    id: shellroot

    LazyLoader {
        id: barLoader
        source: Contracts.bar
        active: Config.runtime.bar.enabled && !Contracts.overriddenBar
    }
    LazyLoader {
        id: backgroundLoader
        source: Contracts.background
        active: Config.runtime.appearance.background.enabled && !Contracts.overriddenBackground
    }
    LazyLoader {
        id: powerMenuLoader
        source: Contracts.powerMenu
        active: Globals.visiblility.powermenu && !Contracts.overriddenPowerMenu
    }
    LazyLoader {
        id: launcherLoader
        source: Contracts.launcher
        active: true && !Contracts.overriddenLauncher
    }
    LazyLoader {
        id: notificationsLoader
        source: Contracts.notifications
        active: Config.runtime.notifications.enabled && !Contracts.overriddenNotifications
    }
    LazyLoader {
        id: overlaysLoader
        source: Contracts.overlays
        active: Config.runtime.overlays.enabled && !Contracts.overriddenOverlays
    }
    LazyLoader {
        id: sidebarRightLoader
        source: Contracts.sidebarRight
        active: Globals.visiblility.sidebarRight && !Contracts.overriddenSidebarRight
    }
    LazyLoader {
        id: sidebarLeftLoader
        source: Contracts.sidebarLeft
        active: Globals.visiblility.sidebarLeft && !Contracts.overriddenSidebarLeft
    }
    LazyLoader {
        id: lockScreenLoader
        source: Contracts.lockScreen
        active: true && !Contracts.overriddenLockScreen
    }

    AudioOutputPopup { }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (Globals.visiblility.audioOutputPopup) {
                    Globals.visiblility.audioOutputPopup = false
                    event.accepted = true
                } else if (Globals.visiblility.powermenu) {
                    Globals.visiblility.powermenu = false
                    event.accepted = true
                } else if (Globals.visiblility.sidebarRight) {
                    Globals.visiblility.sidebarRight = false
                    event.accepted = true
                } else if (Globals.visiblility.sidebarLeft) {
                    Globals.visiblility.sidebarLeft = false
                    event.accepted = true
                } else if (Globals.states?.intelligenceWindowOpen) {
                    Globals.states.intelligenceWindowOpen = false
                    event.accepted = true
                }
            }
        }
    }

    Settings { }
    Ipc { }
    Intelligence { }
    UpdateNotifier { }
    PluginHost { }
}
