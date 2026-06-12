#!/usr/bin/env -S ags run
import app from "ags/gtk4/app";
import { Astal, Gdk, Gtk } from "ags/gtk4";
import { createBinding, createComputed, createState, For } from "ags";
import { createPoll } from "ags/time";
import { execAsync, exec } from "ags/process";
import GLib from "gi://GLib";
import Hyprland from "gi://AstalHyprland";
import Battery from "gi://AstalBattery";
import Wp from "gi://AstalWp";
import Network from "gi://AstalNetwork";
import Tray from "gi://AstalTray";

const ICONS = "/home/vib1240n/.config/waybar/icons";

type AudioDeviceType = "bluetooth" | "speakers" | "headphones" | "unknown";

function getAudioDeviceType(sinkName: string): AudioDeviceType {
  const name = sinkName.toLowerCase();
  if (name.includes("bluez") || name.includes("bluetooth")) return "bluetooth";
  if (
    name.includes("caldigit") ||
    name.includes("omen") ||
    name.includes("monitor")
  )
    return "speakers";
  if (name.includes("usb") && name.includes("audio")) return "speakers";
  if (name.includes("hdmi") || name.includes("displayport")) return "speakers";
  if (name.includes("analog") || name.includes("alsa")) return "speakers";
  return "unknown";
}

function getAudioIcon(
  volume: number,
  muted: boolean,
  deviceType: AudioDeviceType,
): string {
  if (muted || volume === 0) return `${ICONS}/speaker.slash.fill.svg`;
  if (deviceType === "bluetooth") return `${ICONS}/headphones.svg`;
  if (deviceType === "speakers") return `${ICONS}/hifispeaker.fill.svg`;
  if (volume <= 0.33) return `${ICONS}/speaker.wave.1.fill.svg`;
  if (volume <= 0.66) return `${ICONS}/speaker.wave.2.fill.svg`;
  return `${ICONS}/speaker.wave.3.fill.svg`;
}

interface BluetoothBattery {
  connected: boolean;
  percentage: number;
  name: string;
}

function getBluetoothBattery(): BluetoothBattery {
  try {
    const devices = exec("upower -e").trim().split("\n");
    const headset = devices.find((d) => d.includes("headset"));
    if (!headset) return { connected: false, percentage: 0, name: "" };
    const info = exec(`upower -i ${headset}`);
    const percentMatch = info.match(/percentage:\s*(\d+)%/);
    const modelMatch = info.match(/model:\s*(.+)/);
    if (percentMatch) {
      return {
        connected: true,
        percentage: parseInt(percentMatch[1]),
        name: modelMatch ? modelMatch[1].trim() : "Headphones",
      };
    }
  } catch (e) {}
  return { connected: false, percentage: 0, name: "" };
}

type NetworkType = "wifi" | "ethernet" | "disconnected";

function getNetworkType(): NetworkType {
  try {
    const ac = exec("nmcli -t -f TYPE,DEVICE,STATE c show --active").trim();
    if (ac.includes("802-3-ethernet") && ac.includes("activated"))
      return "ethernet";
    if (ac.includes("802-11-wireless") && ac.includes("activated"))
      return "wifi";
    try {
      const e = exec(
        "cat /sys/class/net/enp*/operstate 2>/dev/null | head -1",
      ).trim();
      if (e === "up") return "ethernet";
    } catch {}
    try {
      const w = exec(
        "cat /sys/class/net/wlan*/operstate 2>/dev/null | head -1",
      ).trim();
      if (w === "up") return "wifi";
    } catch {}
    return "disconnected";
  } catch (e) {
    return "disconnected";
  }
}

function getNetworkIcon(t: NetworkType): string {
  switch (t) {
    case "ethernet":
      return `${ICONS}/cable.connector.horizontal.svg`;
    case "wifi":
      return `${ICONS}/wifi.svg`;
    default:
      return `${ICONS}/wifi.slash.svg`;
  }
}

function getBatteryIcon(percentage: number, charging: boolean): string {
  if (charging) return `${ICONS}/battery.100percent.bolt.svg`;
  if (percentage <= 15) return `${ICONS}/battery.0percent.svg`;
  if (percentage <= 30) return `${ICONS}/battery.25percent.svg`;
  if (percentage <= 60) return `${ICONS}/battery.50percent.svg`;
  if (percentage <= 85) return `${ICONS}/battery.75percent.svg`;
  return `${ICONS}/battery.100percent.svg`;
}

const STYLE_PATH = GLib.build_filenamev([
  GLib.get_home_dir(),
  ".config/ags/style.css",
]);
let css: string;
try {
  const [ok, contents] = GLib.file_get_contents(STYLE_PATH);
  css = ok ? new TextDecoder().decode(contents) : "";
  if (!ok) printerr(`[bar] could not read ${STYLE_PATH}, using empty CSS`);
} catch (e) {
  printerr(`[bar] error reading ${STYLE_PATH}: ${e}`);
  css = "";
}

function Workspaces() {
  const hypr = Hyprland.get_default();
  const workspaces = createBinding(hypr, "workspaces");
  const focused = createBinding(hypr, "focusedWorkspace");

  const sortedWorkspaces = createComputed(() => {
    const ws = workspaces();
    if (!ws) return [];
    return [...ws]
      .filter((w) => w != null && w.id > 0 && w.monitor != null)
      .sort((a, b) => a.id - b.id);
  });

  const activeSpecial = createPoll<{ name: string; id: number } | null>(
    null,
    500,
    () => {
      try {
        const monitorsJson = exec("hyprctl monitors -j").trim();
        const monitors = JSON.parse(monitorsJson);
        for (const m of monitors) {
          const sw = m.specialWorkspace;
          if (sw && sw.name && sw.name.length > 0 && sw.id < 0) {
            const displayName = sw.name.startsWith("special:")
              ? sw.name.slice(8)
              : sw.name;
            return { name: displayName || "special", id: sw.id };
          }
        }
        return null;
      } catch {
        return null;
      }
    },
  );

  const specialVisible = createComputed(() => activeSpecial() != null);
  const specialLabel = createComputed(() => {
    const s = activeSpecial();
    return s ? s.name : "";
  });

  return (
    <box cssClasses={["workspaces"]}>
      <For each={sortedWorkspaces}>
        {(workspace) => {
          const isActive = createComputed(() => {
            const f = focused();
            return f != null && workspace != null && f.id === workspace.id;
          });
          const classes = createComputed(() => (isActive() ? ["active"] : []));

          return (
            <button
              cssClasses={classes}
              onClicked={() => {
                try {
                  workspace.focus();
                } catch {}
              }}
            >
              <label label={workspace.id.toString()} />
            </button>
          );
        }}
      </For>
      <button
        cssClasses={["special"]}
        visible={specialVisible}
        tooltipText={createComputed(() => {
          const s = activeSpecial();
          return s ? `Special: ${s.name}` : "";
        })}
        onClicked={() => {
          const s = activeSpecial();
          if (!s) return;
          try {
            execAsync([
              "hyprctl",
              "dispatch",
              "togglespecialworkspace",
              s.name,
            ]);
          } catch {}
        }}
      >
        <box spacing={6}>
          <image file={`${ICONS}/eye.fill.svg`} pixelSize={16} />
          <label label={specialLabel} />
        </box>
      </button>
    </box>
  );
}

function Clock() {
  const time = createPoll("", 1000, () => {
    const now = new Date();
    const hours = now.getHours();
    const minutes = now.getMinutes().toString().padStart(2, "0");
    const period = hours >= 12 ? "PM" : "AM";
    const hour12 = hours % 12 || 12;
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return `${hour12}:${minutes} ${period}  |  ${days[now.getDay()]}, ${months[now.getMonth()]} ${now.getDate()}`;
  });

  return (
    <button
      cssClasses={["clock"]}
      onClicked={() => execAsync(["rw", "toggle", "notifications"])}
    >
      <label label={time} />
    </button>
  );
}

function Volume() {
  const wp = Wp.get_default();
  const speaker = wp?.audio?.defaultSpeaker;

  if (!speaker) {
    return (
      <button cssClasses={["module"]}>
        <label label="" />
      </button>
    );
  }

  const volume = createBinding(speaker, "volume");
  const muted = createBinding(speaker, "mute");

  const sinkInfo = createPoll(
    { name: "", type: "unknown" as AudioDeviceType },
    2000,
    () => {
      try {
        const defaultSink = exec("pactl get-default-sink").trim();
        return { name: defaultSink, type: getAudioDeviceType(defaultSink) };
      } catch {
        return { name: "", type: "unknown" as AudioDeviceType };
      }
    },
  );

  const iconPath = createComputed(() =>
    getAudioIcon(volume(), muted(), sinkInfo().type),
  );
  const volumeText = createComputed(() => `${Math.round(volume() * 100)}%`);
  const tooltip = createComputed(() => {
    const info = sinkInfo();
    const vol = Math.round(volume() * 100);
    const label =
      info.type === "bluetooth"
        ? "Bluetooth"
        : info.type === "speakers"
          ? "Speakers"
          : "Audio";
    return `${label}: ${vol}%`;
  });

  return (
    <button
      cssClasses={["module"]}
      tooltipText={tooltip}
      onClicked={() => execAsync(["rw", "toggle", "volume"])}
    >
      <box spacing={8}>
        <image file={iconPath} pixelSize={22} />
        <label label={volumeText} cssClasses={["module-label"]} />
      </box>
    </button>
  );
}

function BluetoothBattery() {
  const btInfo = createPoll(
    { connected: false, percentage: 0, name: "" },
    300000,
    getBluetoothBattery,
  );

  const visible = createComputed(() => btInfo().connected);
  const classes = createComputed(() => {
    const info = btInfo();
    return info.percentage <= 20 ? ["bt-battery", "low"] : ["bt-battery"];
  });
  const tooltip = createComputed(() => {
    const info = btInfo();
    return `${info.name}: ${info.percentage}%`;
  });

  return (
    <box visible={visible}>
      <button
        cssClasses={classes}
        tooltipText={tooltip}
        onClicked={() => execAsync(["rw", "toggle", "control"])}
      >
        <box spacing={8}>
          <image
            file={`${ICONS}/battery.100percent.circle.fill.svg`}
            pixelSize={20}
          />
          <label label={btInfo((i) => `${i.percentage}%`)} />
        </box>
      </button>
    </box>
  );
}

function NetworkWidget() {
  const networkType = createPoll(
    "disconnected" as NetworkType,
    5000,
    getNetworkType,
  );
  const iconPath = createComputed(() => getNetworkIcon(networkType()));
  const tooltip = createComputed(() => {
    const t = networkType();
    if (t === "ethernet") return "Ethernet Connected";
    if (t === "wifi") return "WiFi Connected";
    return "Disconnected";
  });

  return (
    <button
      cssClasses={["module"]}
      tooltipText={tooltip}
      onClicked={() => execAsync(["rw", "toggle", "stats"])}
    >
      <image file={iconPath} pixelSize={26} />
    </button>
  );
}

function BatteryWidget() {
  const bat = Battery.get_default();
  const percentage = createBinding(bat, "percentage");
  const charging = createBinding(bat, "charging");

  const iconPath = createComputed(() =>
    getBatteryIcon(percentage() * 100, charging()),
  );
  const classes = createComputed(() => {
    const isCritical = !charging() && percentage() <= 0.15;
    return isCritical ? ["module", "critical"] : ["module"];
  });
  const percentText = createComputed(
    () => `${Math.round(percentage() * 100)}%`,
  );
  const tooltip = createComputed(() => {
    const pct = Math.round(percentage() * 100);
    const state = charging() ? "Charging" : "Battery";
    return `${state}: ${pct}%`;
  });

  return (
    <button
      cssClasses={classes}
      tooltipText={tooltip}
      onClicked={() => execAsync(["rw", "toggle", "stats"])}
    >
      <box spacing={8}>
        <image file={iconPath} pixelSize={22} />
        <label label={percentText} cssClasses={["module-label"]} />
      </box>
    </button>
  );
}

function ControlCenter() {
  return (
    <button
      cssClasses={["module"]}
      tooltipText="Control Center"
      onClicked={() => execAsync(["rw", "toggle", "control"])}
    >
      <image file={`${ICONS}/slider.horizontal.3.svg`} pixelSize={22} />
    </button>
  );
}

function SysTray() {
  const tray = Tray.get_default();
  const items = createBinding(tray, "items");

  return (
    <box cssClasses={["tray"]}>
      <For each={items}>
        {(item) => (
          <button
            cssClasses={["tray-item"]}
            tooltipText={createBinding(item, "title")}
            onClicked={() => item.activate(0, 0)}
          >
            <image gicon={createBinding(item, "gicon")} pixelSize={20} />
          </button>
        )}
      </For>
    </box>
  );
}

function Caffeinate() {
  const active = createPoll(false, 2000, () =>
    GLib.file_test("/tmp/caffeinate.pid", GLib.FileTest.EXISTS),
  );
  const classes = createComputed(() =>
    active() ? ["caffeinate", "active"] : ["caffeinate"],
  );

  return (
    <button
      cssClasses={classes}
      tooltipText={active((a) => (a ? "Caffeinate: ON" : "Caffeinate: OFF"))}
      onClicked={() =>
        execAsync([
          "/home/vib1240n/Development/bash_scripts/toggle-caffeinate.sh",
        ])
      }
    >
      <label label={active((a) => (a ? "" : ""))} />
    </button>
  );
}

function Left() {
  return (
    <box hexpand halign={Gtk.Align.START}>
      <SysTray />
      <Caffeinate />
    </box>
  );
}

function Center() {
  return (
    <box>
      <Workspaces />
    </box>
  );
}

function Right() {
  return (
    <box hexpand halign={Gtk.Align.END}>
      <BluetoothBattery />
      <Volume />
      <NetworkWidget />
      <BatteryWidget />
      <ControlCenter />
      <Clock />
    </box>
  );
}

function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      gdkmonitor={gdkmonitor}
      cssClasses={["bar"]}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
      marginTop={6}
      marginLeft={10}
      marginRight={10}
      namespace="ags-bar"
    >
      <centerbox cssClasses={["bar-inner"]}>
        <Left $type="start" />
        <Center $type="center" />
        <Right $type="end" />
      </centerbox>
    </window>
  );
}

function spawnBars() {
  const monitors = app.get_monitors();
  const seen = new Set<string>();

  for (const m of monitors) {
    if (m == null) continue;
    const geom = m.get_geometry();
    const key = `${m.get_connector() ?? "?"}-${geom.x}x${geom.y}-${geom.width}x${geom.height}`;
    if (seen.has(key)) {
      console.log(`[bar] skipping duplicate monitor: ${key}`);
      continue;
    }
    seen.add(key);
    console.log(`[bar] creating bar for ${key}`);
    Bar(m);
  }
}

app.start({
  instanceName: "bar",
  css: css,
  main() {
    spawnBars();

    const display = Gdk.Display.get_default();
    if (display) {
      display.connect("monitor-added", () => {
        console.log("[bar] monitor-added, respawning bars");
        spawnBars();
      });
    }
  },
});
