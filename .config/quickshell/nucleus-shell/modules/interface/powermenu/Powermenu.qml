import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs.config
import qs.modules.functions
import qs.services
import qs.modules.interface.lockscreen
import qs.modules.components

PanelWindow {
    id: powermenu

    WlrLayershell.keyboardFocus: Compositor.require("niri") && Globals.visiblility.powermenu

    function togglepowermenu() {
        Globals.visiblility.powermenu = !Globals.visiblility.powermenu; // Simple toggle logic kept in a function as it might have more things to it later on.
    }

    WlrLayershell.namespace: "nucleus:powermenu"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized && Globals.visiblility.powermenu
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: DisplayMetrics.scaledWidth(0.25)
    implicitHeight: DisplayMetrics.scaledWidth(0.168)

    HyprlandFocusGrab {
        id: grab

        active: Compositor.require("hyprland")
        windows: [powermenu]
    }

    StyledRect {
        id: container

        color: Appearance.m3colors.m3background
        radius: Appearance.rounding.verylarge
        implicitWidth: powermenu.implicitWidth
        anchors.fill: parent

        FocusScope {
            focus: true
            anchors.fill: parent
            Keys.onPressed: {
                if (event.key === Qt.Key_Escape)
                    Globals.visiblility.powermenu = false;

            }

            Item {
                id: content

                anchors.margins: 12
                anchors.topMargin: 16
                anchors.leftMargin: 18
                anchors.fill: parent

                Grid {
                    columns: 3
                    rows: 3
                    rowSpacing: 10
                    columnSpacing: 10
                    anchors.fill: parent

                    PowerMenuButton {
                        buttonIcon: "power_settings_new"
                        onClicked: {
                            Quickshell.execDetached(["poweroff"]);
                            Globals.visiblility.powermenu = false;
                        }
                    }

                    PowerMenuButton {
                        buttonIcon: "logout"
                        onClicked: {
                            Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
                            Globals.visiblility.powermenu = false;
                        }
                    }

                    PowerMenuButton {
                        buttonIcon: "sleep"
                        onClicked: {
                            Quickshell.execDetached(["systemctl", "suspend"]);
                            Globals.visiblility.powermenu = false;
                        }
                    }

                    PowerMenuButton {
                        buttonIcon: "lock"
                        onClicked: {
                            Quickshell.execDetached(["nucleus", "ipc", "lockscreen", "lock"]);
                            Globals.visiblility.powermenu = false;
                        }
                    }

                    PowerMenuButton {
                        buttonIcon: "restart_alt"
                        onClicked: {
                            Quickshell.execDetached(["reboot"]);
                            Globals.visiblility.powermenu = false;
                        }
                    }

                    PowerMenuButton {
                        buttonIcon: "light_off"
                        onClicked: {
                            Quickshell.execDetached(["systemctl", "hibernate"]);
                            Globals.visiblility.powermenu = false;
                        }
                    }

                }

                component Anim: NumberAnimation {
                    running: Config.runtime.appearance.animations.enabled
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animation.curves.standard
                }

            }

        }

    }

    IpcHandler {
        function toggle() {
            togglepowermenu();
        }

        target: "powermenu"
    }

    component PowerMenuButton: StyledButton {
        property string buttonIcon

        icon: buttonIcon
        iconSize: 50
        width: powermenu.implicitWidth / 3.4
        height: powermenu.implicitHeight / 2.3
        radius: beingHovered ? Appearance.rounding.verylarge * 2 : Appearance.rounding.verylarge
    }

}
