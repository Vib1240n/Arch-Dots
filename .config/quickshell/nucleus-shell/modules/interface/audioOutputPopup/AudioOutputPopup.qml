import qs.config
import qs.modules.widgets
import qs.services
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland

PanelWindow {
    id: audioPopup
    WlrLayershell.namespace: "nucleus:audiopopup"
    WlrLayershell.layer: WlrLayer.Overlay
    visible: Config.initialized && Globals.visiblility.audioOutputPopup
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    exclusiveZone: 0

    implicitWidth: 320
    implicitHeight: contentColumn.height + 40

    anchors {
        top: true
        right: true
    }

    margins {
        top: Config.runtime.bar.density + 10
        right: 10
    }

    property var sinkList: Volume.sinks
    
    onSinkListChanged: updateModel()
    onVisibleChanged: if (visible) updateModel()
    Component.onCompleted: updateModel()
    
    function updateModel() {
        sinkModel.clear()
        for (let i = 0; i < sinkList.length; i++) {
            let sink = sinkList[i]
            sinkModel.append({
                sinkId: sink.id,
                sinkName: sink.name || "Unknown",
                sinkDescription: sink.description || sink.name || "Unknown Device"
            })
        }
    }

    ListModel {
        id: sinkModel
    }

    Item {
        anchors.fill: parent
        focus: true
        
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                Globals.visiblility.audioOutputPopup = false
                event.accepted = true
            }
        }

        Rectangle {
            id: background
            anchors.fill: parent
            color: Appearance.m3colors.m3background
            radius: Appearance.rounding.large
            
            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                spacing: 12

                StyledText {
                    text: "Output"
                    font.bold: true
                    font.pixelSize: Appearance.font.size.big - 2
                    color: Appearance.m3colors.m3onSurface
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Appearance.m3colors.m3outlineVariant
                }

                StyledText {
                    visible: sinkModel.count === 0
                    text: "No audio devices found"
                    font.pixelSize: Appearance.font.size.normal
                    color: Appearance.m3colors.m3onSurfaceVariant
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: sinkModel

                        delegate: Rectangle {
                            id: delegateRect
                            property bool isActive: Volume.defaultSink && model.sinkId === Volume.defaultSink.id

                            width: contentColumn.width
                            height: 55
                            radius: Appearance.rounding.normal
                            color: isActive ? Appearance.m3colors.m3primaryContainer : Appearance.m3colors.m3surfaceContainerLow

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    icon: delegateRect.isActive ? "check_circle" : "volume_up"
                                    iconSize: 20
                                    color: delegateRect.isActive ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurface
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    StyledText {
                                        text: model.sinkDescription
                                        font.pixelSize: Appearance.font.size.normal
                                        color: delegateRect.isActive ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurface
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    StyledText {
                                        visible: delegateRect.isActive
                                        text: "Active"
                                        font.pixelSize: Appearance.font.size.small
                                        color: Appearance.m3colors.m3onSurfaceVariant
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    let sink = audioPopup.sinkList.find(s => s.id === model.sinkId)
                                    if (sink) {
                                        Volume.setDefaultSink(sink)
                                    }
                                    Globals.visiblility.audioOutputPopup = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
