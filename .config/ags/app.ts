import app from "ags/gtk4/app"
import style from "./style.scss"
import SpotifyWidget from "./widget/SpotifyWidget"

app.start({
  css: style,
  main() {
    app.get_monitors().map(SpotifyWidget)
  },
})
