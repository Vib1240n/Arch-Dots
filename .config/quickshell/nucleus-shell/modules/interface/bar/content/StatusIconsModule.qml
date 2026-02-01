import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.widgets
import qs.services

Item {
    id: statusIconsContainer

    property bool isVertical: (Config.runtime.bar.position === "left" || Config.runtime.bar.position === "right")

    Layout.alignment: Qt.AlignVCenter
    visible: Config.runtime.bar.modules.statusIcons.enabled
    implicitWidth: bgRect.implicitWidth
    implicitHeight: bgRect.implicitHeight

    property bool caffeinateActive: false

    // Check if file exists using Process
    Process {
        id: caffCheck
        command: ["test", "-f", "/tmp/caffeinate.pid"]
        onExited: (exitCode, exitStatus) => {
            statusIconsContainer.caffeinateActive = (exitCode === 0)
        }
    }

    // Watch /tmp for changes using inotifywait (event-based, not polling)
    Process {
        id: caffWatcher
        running: true
        command: ["inotifywait", "-m", "-e", "create,delete", "/tmp"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("caffeinate.pid")) {
                    caffCheck.running = true
                }
            }
        }
    }

    // Initial check on load
    Component.onCompleted: {
        caffCheck.running = true
    }

    StyledRect {
        id: bgRect

        color: Appearance.m3colors.m3surfaceContainer
        radius: Config.runtime.bar.modules.radius * Config.runtime.appearance.rounding.factor
        implicitWidth: isVertical ? contentRow.implicitWidth + Appearance.margin.large - 8 : contentRow.implicitWidth + Appearance.margin.large
        implicitHeight: Config.runtime.bar.modules.height

        RowLayout {
            id: contentRow

            anchors.centerIn: parent
            spacing: isVertical ? 2 : 8

            MaterialSymbol {
                id: themeIcon
                visible: Config.runtime.bar.modules.statusIcons.themeStatusEnabled
                rotation: isVertical ? 270 : 0
                fill: 1
                icon: Config.runtime.appearance.theme === "light" ? "light_mode" : "dark_mode"
                iconSize: Appearance.font.size.huge
                color: Appearance.m3colors.m3onSecondaryContainer
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: Config.runtime.appearance.theme = (Config.runtime.appearance.theme === "light" ? "dark" : "light")
                }
            }

            MaterialSymbol {
                id: wifi
                visible: Config.runtime.bar.modules.statusIcons.networkStatusEnabled
                rotation: isVertical ? 270 : 0
                icon: Network.icon
                iconSize: Appearance.font.size.huge
                color: Appearance.m3colors.m3onSecondaryContainer
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: Globals.visiblility.sidebarRight = !Globals.visiblility.sidebarRight
                }
            }

            MaterialSymbol {
                id: btIcon
                visible: Config.runtime.bar.modules.statusIcons.bluetoothStatusEnabled
                rotation: isVertical ? 270 : 0
                icon: Bluetooth.icon
                iconSize: Appearance.font.size.huge
                color: Appearance.m3colors.m3onSecondaryContainer
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: Globals.visiblility.sidebarRight = !Globals.visiblility.sidebarRight
                }
            }

            MaterialSymbol {
                id: volumeIcon
                visible: true
                rotation: isVertical ? 270 : 0
                fill: 1
                icon: Volume.icon || "volume_up"
                iconSize: Appearance.font.size.huge
                color: Appearance.m3colors.m3onSecondaryContainer
                
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            Quickshell.execDetached(["pavucontrol"])
                        } else {
                            Globals.visiblility.audioOutputPopup = !Globals.visiblility.audioOutputPopup
                        }
                    }
                }
            }

            StyledText {
                id: keyboardLayoutIcon
                visible: Config.runtime.bar.modules.statusIcons.keyboardLayoutStatusEnabled
                rotation: isVertical ? 270 : 0
                text: SystemDetails.keyboardLayout
                font.pixelSize: Appearance.font.size.huge - 4
                Layout.leftMargin: isVertical ? 0 : -3
                color: Appearance.m3colors.m3onSecondaryContainer
            }

            MaterialSymbol {
                id: caffIcon
                visible: true
                rotation: isVertical ? 270 : 0
                fill: statusIconsContainer.caffeinateActive ? 1 : 0
                icon: "coffee"
                iconSize: Appearance.font.size.huge
                color: statusIconsContainer.caffeinateActive ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSecondaryContainer
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Quickshell.execDetached(["bash", "/home/vib1240n/Development/bash_scripts/toggle-caffeinate.sh"])
                    }
                }
            }

            MaterialSymbol {
                id: controlCenterIcon
                visible: true
                rotation: isVertical ? 270 : 0
                fill: Globals.visiblility.sidebarRight ? 1 : 0
                icon: "widgets"
                iconSize: Appearance.font.size.huge
                color: Globals.visiblility.sidebarRight ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSecondaryContainer
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: Globals.visiblility.sidebarRight = !Globals.visiblility.sidebarRight
                }
            }
        }
    }
}
