import QtQuick
import Quickshell
import qs.config

Item {
    Repeater {
        model: PluginLoader.plugins

        delegate: Item {
            width: 0
            height: 0

            LazyLoader {
                id: pluginLoader
                active: Config.initialized && Config.runtime.plugins[modelData]?.enabled
                source: Qt.resolvedUrl(
                    Directories.shellConfig + "/plugins/" + modelData + "/Main.qml"
                )
                loading: true   // optional, keeps plugin loaded
            }
        }
    }
}
