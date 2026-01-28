import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"

export default function SpotifyWidget(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      visible
      application={app}
      name="spotify-window"
      namespace="ags-spotify"
      gdkmonitor={gdkmonitor}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
      marginTop={20}
      marginRight={20}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.NORMAL}
    >
      <box class="media-player" orientation={Gtk.Orientation.VERTICAL}>
        <box class="album-art" />
        <box class="controls" orientation={Gtk.Orientation.VERTICAL}>
          <box class="track-info" orientation={Gtk.Orientation.VERTICAL}>
            <label
              class="track-title"
              label="Midnight Dreams"
              halign={Gtk.Align.START}
            />
            <label
              class="track-artist"
              label="The Wanderers"
              halign={Gtk.Align.START}
            />
          </box>
          <box class="progress-section" orientation={Gtk.Orientation.VERTICAL}>
            <slider
              class="progress-slider"
              orientation={Gtk.Orientation.HORIZONTAL}
              hexpand
            />
            <box class="time-labels" orientation={Gtk.Orientation.HORIZONTAL}>
              <label
                class="time-current"
                label="1:24"
                halign={Gtk.Align.START}
                hexpand
              />
              <label class="time-total" label="3:48" halign={Gtk.Align.END} />
            </box>
          </box>
          <box
            class="control-buttons"
            orientation={Gtk.Orientation.HORIZONTAL}
            halign={Gtk.Align.CENTER}
          >
            <button class="btn-skip">
              <label label="Previous" />
            </button>
            <button class="btn-play">
              <label label="Play" />
            </button>
            <button class="btn-skip">
              <label label="Next" />
            </button>
          </box>
          <box class="volume-control" orientation={Gtk.Orientation.HORIZONTAL}>
            <label class="volume-icon" label="Volume" />
            <slider
              class="volume-slider"
              orientation={Gtk.Orientation.HORIZONTAL}
              hexpand
            />
            <label class="volume-percent" label="70%" />
          </box>
        </box>
      </box>
    </window>
  )
}
