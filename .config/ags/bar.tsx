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

// ============================================
// Audio Device Type Detection
// ============================================

type AudioDeviceType = "bluetooth" | "speakers" | "headphones" | "unknown";

function getAudioDeviceType(sinkName: string): AudioDeviceType {
  const name = sinkName.toLowerCase();

  // Bluetooth devices (bluez in sink name)
  if (name.includes("bluez") || name.includes("bluetooth")) {
    return "bluetooth";
  }

  // USB audio devices - check for known speaker/monitor names
  if (
    name.includes("caldigit") ||
    name.includes("omen") ||
    name.includes("monitor")
  ) {
    return "speakers";
  }

  // Generic USB audio likely speakers
  if (name.includes("usb") && name.includes("audio")) {
    return "speakers";
  }

  // HDMI/DisplayPort audio
  if (name.includes("hdmi") || name.includes("displayport")) {
    return "speakers";
  }

  // Default to speakers for analog outputs
  if (name.includes("analog") || name.includes("alsa")) {
    return "speakers";
  }

  return "unknown";
}

function getAudioIcon(
  volume: number,
  muted: boolean,
  deviceType: AudioDeviceType,
): string {
  if (muted || volume === 0) return `${ICONS}/speaker.slash.fill.svg`;

  // Use device-specific icons
  if (deviceType === "bluetooth") {
    return `${ICONS}/headphones.svg`;
  }

  if (deviceType === "speakers") {
    return `${ICONS}/hifispeaker.fill.svg`;
  }

  // Fallback to volume-based speaker icons
  if (volume <= 0.33) return `${ICONS}/speaker.wave.1.fill.svg`;
  if (volume <= 0.66) return `${ICONS}/speaker.wave.2.fill.svg`;
  return `${ICONS}/speaker.wave.3.fill.svg`;
}

// ============================================
// Bluetooth Battery Detection
// ============================================

interface BluetoothBattery {
  connected: boolean;
  percentage: number;
  name: string;
}

function getBluetoothBattery(): BluetoothBattery {
  try {
    // Check upower for headset devices
    const devices = exec("upower -e").trim().split("\n");
    const headset = devices.find((d) => d.includes("headset"));

    if (!headset) {
      return { connected: false, percentage: 0, name: "" };
    }

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
  } catch (e) {
    // No bluetooth headset connected
  }

  return { connected: false, percentage: 0, name: "" };
}

// ============================================
// Network Type Detection
// ============================================

type NetworkType = "wifi" | "ethernet" | "disconnected";

function getNetworkType(): NetworkType {
  try {
    // Check nmcli for active connections - most reliable
    const activeConnections = exec(
      "nmcli -t -f TYPE,DEVICE,STATE c show --active",
    ).trim();

    // Check for ethernet first (802-3-ethernet)
    if (
      activeConnections.includes("802-3-ethernet") &&
      activeConnections.includes("activated")
    ) {
      return "ethernet";
    }

    // Check for wifi (802-11-wireless)
    if (
      activeConnections.includes("802-11-wireless") &&
      activeConnections.includes("activated")
    ) {
      return "wifi";
    }

    // Fallback: check operstate files like the waybar script
    try {
      const ethState = exec(
        "cat /sys/class/net/enp*/operstate 2>/dev/null | head -1",
      ).trim();
      if (ethState === "up") {
        return "ethernet";
      }
    } catch {}

    try {
      const wifiState = exec(
        "cat /sys/class/net/wlan*/operstate 2>/dev/null | head -1",
      ).trim();
      if (wifiState === "up") {
        return "wifi";
      }
    } catch {}

    return "disconnected";
  } catch (e) {
    return "disconnected";
  }
}

function getNetworkIcon(networkType: NetworkType): string {
  switch (networkType) {
    case "ethernet":
      return `${ICONS}/cable.connector.horizontal.svg`;
    case "wifi":
      return `${ICONS}/wifi.svg`;
    default:
      return `${ICONS}/wifi.slash.svg`;
  }
}

// ============================================
// Battery Icon Helper
// ============================================

function getBatteryIcon(percentage: number, charging: boolean): string {
  if (charging) return `${ICONS}/battery.100percent.bolt.svg`;
  if (percentage <= 15) return `${ICONS}/battery.0percent.svg`;
  if (percentage <= 30) return `${ICONS}/battery.25percent.svg`;
  if (percentage <= 60) return `${ICONS}/battery.50percent.svg`;
  if (percentage <= 85) return `${ICONS}/battery.75percent.svg`;
  return `${ICONS}/battery.100percent.svg`;
}

// ============================================
// Inline CSS with Workspace Animations
// ============================================
const css = `
* {
  font-family: "SF Pro Text", "JetBrainsMono Nerd Font", sans-serif;
  font-size: 14px;
  color: rgba(252, 252, 252, 1);
}

/* Make all SVG icons white */
image {
  -gtk-icon-style: symbolic;
  color: rgba(252, 252, 252, 1);
}

window {
  background-color: rgba(20, 22, 24, 0.35);
  border-radius: 14px;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.bar-inner {
  margin: 4px 8px;
}

/* ============================================
   Animated Workspaces - Fluid Water Sloshing
   ============================================ */

.workspaces {
  margin: 0 4px;
  padding: 3px 5px;
  background-color: rgba(41, 44, 48, 0.35);
  border-radius: 14px;
}

.workspaces button {
  background-color: transparent;
  color: rgba(252, 252, 252, 0.45);
  padding: 5px 12px;
  margin: 2px 3px;
  border-radius: 10px;
  min-width: 30px;
  min-height: 26px;
  font-size: 14px;
  font-weight: 500;
  transition: 
    color 180ms ease-out,
    background-color 280ms cubic-bezier(0.34, 1.56, 0.64, 1),
    padding 280ms cubic-bezier(0.34, 1.56, 0.64, 1),
    min-width 280ms cubic-bezier(0.34, 1.56, 0.64, 1),
    margin 280ms cubic-bezier(0.34, 1.56, 0.64, 1),
    box-shadow 320ms cubic-bezier(0.22, 1, 0.36, 1);
}

.workspaces button:hover {
  background-color: rgba(255, 255, 255, 0.08);
  color: rgba(252, 252, 252, 0.85);
}

.workspaces button.active {
  background-color: rgba(61, 174, 233, 0.35);
  color: #3daee9;
  font-weight: 600;
  min-width: 38px;
  padding: 5px 16px;
  margin: 2px 2px;
  box-shadow: 
    0 0 0 1px rgba(61, 174, 233, 0.3),
    0 2px 12px rgba(61, 174, 233, 0.25),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
  transition: 
    color 120ms ease-out,
    background-color 350ms cubic-bezier(0.34, 1.56, 0.64, 1),
    padding 350ms cubic-bezier(0.34, 1.56, 0.64, 1),
    min-width 350ms cubic-bezier(0.34, 1.56, 0.64, 1),
    margin 350ms cubic-bezier(0.34, 1.56, 0.64, 1),
    box-shadow 400ms cubic-bezier(0.22, 1, 0.36, 1);
}

/* ============================================
   Clock
   ============================================ */

.clock {
  font-family: "SF Pro Display", "SF Pro Text", sans-serif;
  font-weight: 500;
  font-size: 15px;
  color: rgba(252, 252, 252, 1);
  padding: 6px 16px;
  margin: 0 6px;
  background-color: rgba(41, 44, 48, 0.5);
  border-radius: 10px;
  transition: all 200ms ease;
}

.clock:hover {
  background-color: rgba(61, 174, 233, 0.2);
  color: #3daee9;
}

/* ============================================
   Modules
   ============================================ */

.module {
  padding: 6px 12px;
  margin: 0 4px;
  background-color: transparent;
  border-radius: 10px;
  min-height: 36px;
  transition: all 200ms ease;
}

.module:hover {
  background-color: rgba(41, 44, 48, 0.5);
}

.module.critical {
  color: #ed8796;
}

.module-label {
  font-size: 13px;
  font-weight: 500;
  color: rgba(252, 252, 252, 1);
}

/* ============================================
   Bluetooth Battery
   ============================================ */

.bt-battery {
  padding: 4px 12px;
  margin: 0 4px;
  background-color: rgba(41, 44, 48, 0.4);
  border-radius: 10px;
  min-height: 36px;
  transition: all 200ms ease;
}

.bt-battery:hover {
  background-color: rgba(41, 44, 48, 0.6);
}

.bt-battery image {
  margin-right: 8px;
}

.bt-battery label {
  font-size: 13px;
  font-weight: 500;
  color: rgba(252, 252, 252, 1);
}

.bt-battery.low image {
  opacity: 0.7;
}

.bt-battery.low label {
  color: #ed8796;
}

/* ============================================
   System Tray
   ============================================ */

.tray {
  padding: 0 8px;
}

.tray-item {
  padding: 6px 8px;
  margin: 0 2px;
  background-color: transparent;
  border-radius: 8px;
  transition: all 150ms ease;
}

.tray-item:hover {
  background-color: rgba(41, 44, 48, 0.5);
}

/* ============================================
   Caffeinate
   ============================================ */

.caffeinate {
  color: rgba(252, 252, 252, 0.55);
  padding: 6px 10px;
  background-color: transparent;
  font-family: "JetBrainsMono Nerd Font";
  font-size: 18px;
  transition: all 200ms ease;
}

.caffeinate:hover {
  color: #3daee9;
}

.caffeinate.active {
  color: #a6e3a1;
}
`;

// ============================================
// Widgets
// ============================================

function Workspaces() {
  const hypr = Hyprland.get_default();
  const workspaces = createBinding(hypr, "workspaces");
  const focused = createBinding(hypr, "focusedWorkspace");

  const sortedWorkspaces = createComputed(() => {
    const ws = workspaces();
    if (!ws) return [];
    return [...ws].filter((w) => w.id > 0).sort((a, b) => a.id - b.id);
  });

  return (
    <box cssClasses={["workspaces"]}>
      <For each={sortedWorkspaces}>
        {(workspace) => {
          const isActive = createComputed(() => focused()?.id === workspace.id);
          const classes = createComputed(() => (isActive() ? ["active"] : []));

          return (
            <button cssClasses={classes} onClicked={() => workspace.focus()}>
              <label label={workspace.id.toString()} />
            </button>
          );
        }}
      </For>
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

  // Poll for sink name to detect device type
  const sinkInfo = createPoll(
    { name: "", type: "unknown" as AudioDeviceType },
    2000,
    () => {
      try {
        const defaultSink = exec("pactl get-default-sink").trim();
        return {
          name: defaultSink,
          type: getAudioDeviceType(defaultSink),
        };
      } catch {
        return { name: "", type: "unknown" as AudioDeviceType };
      }
    },
  );

  const iconPath = createComputed(() => {
    const info = sinkInfo();
    return getAudioIcon(volume(), muted(), info.type);
  });

  const volumeText = createComputed(() => {
    const vol = Math.round(volume() * 100);
    return `${vol}%`;
  });

  const tooltip = createComputed(() => {
    const info = sinkInfo();
    const vol = Math.round(volume() * 100);
    const deviceLabel =
      info.type === "bluetooth"
        ? "Bluetooth"
        : info.type === "speakers"
          ? "Speakers"
          : "Audio";
    return `${deviceLabel}: ${vol}%`;
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
  // Poll every 5 minutes (300000ms) - battery level doesn't change fast
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
  const percentText = createComputed(() => {
    const pct = Math.round(percentage() * 100);
    return `${pct}%`;
  });
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
  const active = createPoll(false, 2000, () => {
    return GLib.file_test("/tmp/caffeinate.pid", GLib.FileTest.EXISTS);
  });

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

// ============================================
// Left/Center/Right Modules
// ============================================

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

// ============================================
// Bar
// ============================================

function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      gdkmonitor={gdkmonitor}
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

// ============================================
// App Entry
// ============================================

app.start({
  css: css,
  main() {
    const monitors = app.get_monitors();
    monitors.map(Bar);
  },
});
