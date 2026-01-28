import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Layouts
import Quickshell.Wayland
import qs.config
import qs.modules.functions
import qs.modules.widgets
import qs.modules.widgets.morphedPolygons
import qs.services
import "../../widgets/morphedPolygons/geometry/offset.js" as Offset
import "../../widgets/morphedPolygons/material-shapes.js" as MaterialShapes // For polygons
import "../../widgets/morphedPolygons/shapes/corner-rounding.js" as CornerRounding

Rectangle {
    id: root

    required property LockContext context

    color: "transparent"

    Image {
        anchors.fill: parent
        z: -1
        source: Config.runtime.appearance.background.path
    }

    RowLayout {
        spacing: 20

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 20
            rightMargin: 30
        }

        MaterialSymbol {
            id: themeIcon

            visible: Config.runtime.bar.modules.statusIcons.themeStatusEnabled
            fill: 1
            icon: Config.runtime.appearance.theme === "light" ? "light_mode" : "dark_mode"
            iconSize: Appearance.font.size.hugeass
        }

        MaterialSymbol {
            id: wifi

            visible: Config.runtime.bar.modules.statusIcons.networkStatusEnabled
            icon: Network.icon
            iconSize: Appearance.font.size.hugeass
        }

        MaterialSymbol {
            id: btIcon

            visible: Config.runtime.bar.modules.statusIcons.bluetoothStatusEnabled
            icon: Bluetooth.icon
            iconSize: Appearance.font.size.hugeass
        }

        StyledText {
            id: keyboardLayoutIcon

            visible: Config.runtime.bar.modules.statusIcons.keyboardLayoutStatusEnabled
            text: SystemDetails.keyboardLayout
            font.pixelSize: Appearance.font.size.huge - 4
        }

    }

    ColumnLayout {
        spacing: 0

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 150
        }

        StyledText {
            id: clock

            visible: !Config.runtime.appearance.background.clock.isAnalog
            Layout.alignment: Qt.AlignBottom
            animate: false
            renderType: Text.NativeRendering
            font.pixelSize: 180
            text: Time.format("hh:mm")
        }

        StyledText {
            id: date

            visible: !Config.runtime.appearance.background.clock.isAnalog
            Layout.alignment: Qt.AlignCenter
            animate: false
            renderType: Text.NativeRendering
            font.pixelSize: 50
            text: Time.format("dddd, dd/MM")
        }

        Item {
            id: analogClockContainer

            property int hours: parseInt(Time.format("hh"))
            property int minutes: parseInt(Time.format("mm"))
            property int seconds: parseInt(Time.format("ss"))
            readonly property real cx: width / 2
            readonly property real cy: height / 2
            property var shapes: [MaterialShapes.getCookie7Sided, MaterialShapes.getCookie9Sided, MaterialShapes.getCookie12Sided, MaterialShapes.getPixelCircle, MaterialShapes.getCircle, MaterialShapes.getGhostish]

            visible: Config.runtime.appearance.background.clock.isAnalog
            width: 350
            height: 350

            // Polygon
            MorphedPolygon {
                id: shapeCanvas
                anchors.fill: parent
                color: Appearance.m3colors.m3surfaceContainerLow
                roundedPolygon: analogClockContainer.shapes[Config.runtime.appearance.background.clock.shape]()
            }

            // Hour hand
            Rectangle {
                z: 1
                width: 12
                height: parent.height * 0.38
                radius: Appearance.rounding.full
                color: Qt.darker(Appearance.m3colors.m3secondary, 0.8)
                x: analogClockContainer.cx - width / 2
                y: analogClockContainer.cy - height
                transformOrigin: Item.Bottom
                rotation: (analogClockContainer.hours % 12 + analogClockContainer.minutes / 60) * 30
            }

            // Minute hand
            Rectangle {
                width: 12
                height: parent.height * 0.3
                radius: Appearance.rounding.full
                color: Appearance.m3colors.m3secondary
                x: analogClockContainer.cx - width / 2
                y: analogClockContainer.cy - height
                transformOrigin: Item.Bottom
                rotation: analogClockContainer.minutes * 6
            }

            // Second hand
            Rectangle {
                visible: false
                width: 4
                height: parent.height * 0.22
                radius: Appearance.rounding.full
                color: Appearance.m3colors.m3error
                x: analogClockContainer.cx - width / 2
                y: analogClockContainer.cy - height
                transformOrigin: Item.Bottom
                rotation: analogClockContainer.seconds * 6
            }

            StyledText {
                text: Time.format("ddd MMM d")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 4 - 30
                font.bold: true
            }

        }

    }

    ColumnLayout {
        // Uncommenting this will make the password entry invisible except on the active monitor.
        // visible: Window.active

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 20
        }

        RowLayout {
            StyledTextField {
                id: passwordBox

                implicitWidth: 300
                padding: 10
                placeholder: root.context.showFailure ? "Incorrect Password" : "Enter Password"
                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                // Update the text in the context when the text in the box changes.
                onTextChanged: root.context.currentText = this.text
                // Try to unlock when enter is pressed.
                onAccepted: root.context.tryUnlock()

                // Update the text in the box to match the text in the context.
                // This makes sure multiple monitors have the same text.
                Connections {
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }

                    target: root.context
                }

            }

            StyledButton {
                icon: "chevron_right"
                padding: 10
                radius: Appearance.rounding.unsharpenmore
                // don't steal focus from the text box
                focusPolicy: Qt.NoFocus
                enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                onClicked: root.context.tryUnlock()
            }

        }

    }

}
