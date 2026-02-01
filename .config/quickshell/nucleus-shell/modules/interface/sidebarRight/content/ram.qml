import qs.config
import qs.modules.widgets
import qs.services
import QtQuick
import Quickshell
import QtQuick.Layouts

StyledRect {
    id: root
    width: 200
    height: 80
    radius: Appearance.rounding.verylarge
    color: Appearance.m3colors.m3surfaceContainerHigh

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    // Icon background
    StyledRect {
        id: iconBg
        width: 50
        height: 50
        radius: Appearance.rounding.verylarge
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Appearance.margin.small

        color: SystemDetails.ramPercent > 0.8 
            ? Appearance.m3colors.m3errorContainer 
            : Appearance.m3colors.m3secondaryContainer

        MaterialSymbol {
            anchors.centerIn: parent
            iconSize: 35
            icon: "memory_alt"
        }
    }

    // Text
    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: iconBg.right
        anchors.leftMargin: Appearance.margin.small
        spacing: 2

        StyledText {
            text: "RAM"
            font.pixelSize: Appearance.font.size.large
            elide: Text.ElideRight
            width: root.width - iconBg.width - 30
        }

        StyledText {
            text: SystemDetails.ramUsage || "0%"
            font.pixelSize: Appearance.font.size.small
            color: Appearance.m3colors.m3onSurfaceVariant
            elide: Text.ElideRight
            width: root.width - iconBg.width - 30
        }
    }

    // Interaction
    MouseArea {
        anchors.fill: parent
        onClicked: {
            Quickshell.execDetached(["kitty", "htop"])
        }
    }
}
