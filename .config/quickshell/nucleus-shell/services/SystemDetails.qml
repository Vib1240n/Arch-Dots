import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
pragma Singleton

Singleton {
    id: root

    property string hostname: ""
    property string username: ""
    property string osIcon: ""
    property string osName: ""
    property string kernelVersion: ""
    property string architecture: ""
    property string uptime: ""
    property string qsVersion: ""
    property string swapUsage: "—"
    property real swapPercent: 0
    property string ipAddress: "—"
    property int runningProcesses: 0
    property int loggedInUsers: 0
    property string ramUsage: "—"
    property real ramPercent: 0
    property string cpuLoad: "—"
    property real cpuPercent: 0
    property string diskUsage: "—"
    property real diskPercent: 0
    property string cpuTemp: "—"
    property string keyboardLayout: "none"
    property real cpuTempPercent: 0

    readonly property var osIcons: ({
        "almalinux": "", "alpine": "", "arch": "󰣇", "archcraft": "",
        "arcolinux": "", "artix": "", "centos": "", "debian": "",
        "elementary": "", "endeavouros": "", "fedora": "", "freebsd": "",
        "garuda": "", "gentoo": "", "kali": "", "kubuntu": "",
        "linuxmint": "", "lubuntu": "", "manjaro": "", "mx": "",
        "nixos": "", "openbsd": "", "opensuse": "", "parrot": "",
        "pop": "", "raspbian": "", "redhat": "", "rocky": "",
        "slackware": "", "solus": "", "ubuntu": "", "void": "",
        "zorin": "", "linux": ""
    })

    // Only poll when sidebar is visible
    Timer {
        interval: 3000
        running: Globals.visiblility.sidebarRight
        repeat: true
        onTriggered: {
            ramProc.running = true
            cpuProc.running = true
            cpuTempProc.running = true
            diskProc.running = true
        }
    }

    // Refresh immediately when sidebar opens
    Connections {
        target: Globals.visiblility
        function onSidebarRightChanged() {
            if (Globals.visiblility.sidebarRight) {
                ramProc.running = true
                cpuProc.running = true
                cpuTempProc.running = true
                diskProc.running = true
                uptimeProc.running = true
            }
        }
    }

    // Static values - load once on startup
    Component.onCompleted: {
        hostnameProc.running = true
        usernameProc.running = true
        osProc.running = true
        kernelProc.running = true
        archProc.running = true
        uptimeProc.running = true
        keyboardProc.running = true
    }

    // === STATIC PROCESSES ===
    Process {
        id: hostnameProc
        command: ["cat", "/etc/hostname"]
        stdout: StdioCollector { onStreamFinished: hostname = text.trim() }
    }

    Process {
        id: usernameProc
        command: ["whoami"]
        stdout: StdioCollector { onStreamFinished: username = text.trim() }
    }

    Process {
        id: osProc
        command: ["sh", "-c", "grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '\"'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const id = text.trim().toLowerCase()
                osName = id
                osIcon = osIcons[id] || osIcons["linux"]
            }
        }
    }

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: StdioCollector { onStreamFinished: kernelVersion = text.trim() }
    }

    Process {
        id: archProc
        command: ["uname", "-m"]
        stdout: StdioCollector { onStreamFinished: architecture = text.trim() }
    }

    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        stdout: StdioCollector { onStreamFinished: uptime = "Up " + text.trim() }
    }

    Process {
        id: keyboardProc
        command: ["sh", "-c", "hyprctl devices -j | jq -r '.keyboards[0].active_keymap' | cut -c1-2 | tr 'a-z' 'A-Z'"]
        stdout: StdioCollector { onStreamFinished: keyboardLayout = text.trim() || "US" }
    }

    // === DYNAMIC PROCESSES (only when sidebar visible) ===
    Process {
        id: ramProc
        command: ["free", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(l => l.startsWith("Mem:"))
                if (!line) return
                const p = line.split(/\s+/)
                const total = parseInt(p[1])
                const used = parseInt(p[2])
                ramPercent = used / total
                ramUsage = `${used}/${total} MB`
            }
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseFloat(text.trim())
                cpuPercent = val / 100
                cpuLoad = val.toFixed(1) + "%"
            }
        }
    }

    Process {
        id: cpuTempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const temp = parseInt(text.trim()) / 1000
                cpuTemp = temp.toFixed(0) + "°C"
                cpuTempPercent = Math.min(temp / 100, 1)
            }
        }
    }

    Process {
        id: diskProc
        command: ["df", "-h", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                if (lines.length < 2) return
                const p = lines[1].split(/\s+/)
                diskUsage = `${p[2]}/${p[1]}`
                diskPercent = parseInt(p[4]) / 100
            }
        }
    }
}
