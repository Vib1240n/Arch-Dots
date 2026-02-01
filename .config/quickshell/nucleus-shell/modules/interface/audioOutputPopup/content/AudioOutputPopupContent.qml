import qs.config
import qs.modules.widgets
import qs.services
import qs.modules.functions
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    anchors.fill: parent
    anchors.margins: Appearance.margin.large

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.margin.normal

        StyledText {
            text: "Audio Output"
            font.bold: true
            font.pixelSize: Appearance.font.size.big
            color: Appearance.m3colors.m3onSurface
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.m3colors.m3outlineVariant
        }

        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true

            model: Pipewire.nodes

            delegate: Item {
                id: delegateRoot
                required property var modelData
                
                width: deviceList.width
                height: modelData.mediaClass === "Audio/Sink" ? 60 : 0
                visible: modelData.mediaClass === "Audio/Sink"

                StyledRect {
                    anchors.fill: parent
                    visible: parent.visible
                    color: delegateRoot.modelData.id === Pipewire.defaultAudioSink?.id ? Appearance.m3colors.m3primaryContainer : Appearance.m3colors.m3surfaceContainerLow
                    radius: Appearance.rounding.normal

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 12

                        MaterialSymbol {
                            icon: delegateRoot.modelData.id === Pipewire.defaultAudioSink?.id ? "check_circle" : "volume_up"
                            iconSize: 22
                            color: delegateRoot.modelData.id === Pipewire.defaultAudioSink?.id ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurface
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            StyledText {
                                text: delegateRoot.modelData.description || delegateRoot.modelData.name || "Unknown Device"
                                font.pixelSize: 15
                                color: delegateRoot.modelData.id === Pipewire.defaultAudioSink?.id ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurface
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: delegateRoot.modelData.id === Pipewire.defaultAudioSink?.id ? "Active" : ""
                                font.pixelSize: 12
                                color: Appearance.m3colors.m3onSurfaceVariant
                                visible: delegateRoot.modelData.id === Pipewire.defaultAudioSink?.id
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Pipewire.defaultAudioSink = delegateRoot.modelData
                            Globals.visiblility.audioOutputPopup = false
                        }
                    }
                }
            }
        }

        StyledButton {
            text: "Close"
            secondary: true
            Layout.alignment: Qt.AlignRight
            onClicked: Globals.visiblility.audioOutputPopup = false
        }
    }
}
