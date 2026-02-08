import QtQuick
import QtQuick.Layouts
import qs.config
import qs.plugins
import qs.modules.components

Item { // I didn't want the flicable implicitHeight headache
    id: pluginsPage
    Layout.fillWidth: true
    Layout.fillHeight: true
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.95

    Behavior on opacity {
        enabled: Config.runtime.appearance.animations.enabled
        NumberAnimation {
            duration: Appearance.animation.durations.normal
            easing.type: Appearance.animation.curves.standard[0] // using standard easing
        }
    }
    Behavior on scale {
        enabled: Config.runtime.appearance.animations.enabled
        NumberAnimation {
            duration: Appearance.animation.durations.normal
            easing.type: Appearance.animation.curves.standard[0]
        }
    }
    // Outer margins
    property int sideMargin: Appearance.margin.verylarge * 8
    property int topMargin: Appearance.margin.verylarge
    property int contentSpacing: Appearance.margin.normal

    // Header + description
    ColumnLayout {
        id: headerColumn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Appearance.margin.verylarge + Appearance.margin.small
        anchors.topMargin: topMargin
        spacing: Appearance.margin.small

        StyledText {
            text: "Plugins"
            font.pixelSize: Appearance.font.size.huge
            font.bold: true
            font.family: Appearance.font.family.title
        }

        StyledText {
            text: "Modify and Customize Installed Plugins."
            font.pixelSize: Appearance.font.size.small
        }

    }

    // Scrollable plugin list
    Flickable {
        id: pluginFlickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerColumn.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: sideMargin
        anchors.rightMargin: sideMargin
        anchors.topMargin: contentSpacing
        clip: true

        contentWidth: width

        ColumnLayout {
            id: pluginColumn
            width: parent.width
            spacing: contentSpacing

            StyledText {
                text: "Plugins not found!"
                font.pixelSize: 20
                font.bold: true
                visible: PluginLoader.plugins.length === 0
                Layout.alignment: Qt.AlignHCenter
            }

            Repeater {
                model: PluginLoader.plugins

                delegate: ContentCard {
                    Layout.fillWidth: true

                    Loader {
                        Layout.fillWidth: true
                        asynchronous: true
                        source: Qt.resolvedUrl(
                            Directories.shellConfig + "/plugins/" + modelData + "/Settings.qml"
                        )
                    }
                }
            }
        }

        // Update contentHeight dynamically
        contentHeight: pluginColumn.implicitHeight
    }
}
