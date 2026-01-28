import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules.functions
import qs.modules.widgets
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: backgroundContainer

            required property var modelData

            function applyWallpaper(wallpaper) {
                Config.updateKey("appearance.background.path", wallpaper)
            }

            color: (currentImage.status === Image.Error) ? Appearance.colors.colLayer2 : "transparent" // To prevent showing nothing.
            WlrLayershell.namespace: "nucleus:background"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            screen: modelData
            visible: Config.initialized && Config.runtime.appearance.background.enabled

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Process {
                id: wallpaperProc

                command: ["bash", "-c", Directories.scriptsPath + "/interface/changebg.sh"]

                stdout: StdioCollector {
                    onStreamFinished: {
                        const out = text.trim();
                        if (out !== "null" && out.length > 0) {
                            applyWallpaper(out);
                        }
                        // Only run regenColors if auto-generated colors are enabled
                        Quickshell.execDetached(["qs", "-c", "nucleus-shell", "ipc", "call", "clock", "changePosition"]);
                        Quickshell.execDetached([
                            "qs", "-c", "nucleus-shell", "ipc", "call", "global", "regenColors"
                        ]);
                    }
                }

            }

            Item {
                anchors.fill: parent

                Image {
                    id: currentImage

                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: Config.runtime.appearance.background.path
                    opacity: 1
                }


                Item {
                    anchors.centerIn: parent
                    visible: currentImage.status === Image.Error

                    Rectangle {
                        width: 550
                        height: 400
                        radius: Appearance.rounding.windowRounding
                        color: "transparent" // It looks better somehow
                        anchors.centerIn: parent

                        ColumnLayout {
                            anchors.centerIn: parent
                            anchors.margins: Appearance.margin.normal
                            spacing: Appearance.margin.small

                            // Icon
                            MaterialSymbol {
                                text: "wallpaper"
                                font.pixelSize: Appearance.font.size.wildass
                                color: Appearance.colors.colOnLayer2
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Heading
                            StyledText {
                                text: "Wallpaper Missing"
                                font.pixelSize: Appearance.font.size.hugeass
                                font.bold: true
                                color: Appearance.colors.colOnLayer2
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Description
                            StyledText {
                                text: "Seems like you haven't set a wallpaper yet."
                                font.pixelSize: Appearance.font.size.small
                                color: Appearance.colors.colSubtext
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            // Action
                            StyledButton {
                                text: "Set wallpaper"
                                icon: "wallpaper"
                                secondary: true
                                radius: Appearance.rounding.large
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: wallpaperProc.running = true
                            }

                        }

                    }

                }

            }

            Clock {
                id: clock

                imageFailed: currentImage.status === Image.Error
            }

            IpcHandler {
                function change() {
                    wallpaperProc.running = true;
                }

                function next() {
                    WallpaperSlideshow.nextWallpaper();
                }

                target: "background"
            }

        }

    }

}
