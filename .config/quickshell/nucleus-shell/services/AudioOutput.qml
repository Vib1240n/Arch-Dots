import QtQuick
import Quickshell

Singleton {
    id: root
    property bool popupOpen: false
    
    // Re-export Volume properties for convenience
    property var sinks: Volume.sinks
    property var sources: Volume.sources
    property var defaultSink: Volume.defaultSink
    property string icon: Volume.icon
    
    function setDefaultSink(sink) {
        Volume.setDefaultSink(sink)
    }
    
    function setDefaultSource(source) {
        Volume.setDefaultSource(source)
    }
}
