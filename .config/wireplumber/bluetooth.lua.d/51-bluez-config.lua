bluez_monitor.properties = {
  ["bluez5.enable-sbc-xq"] = true,
  ["bluez5.enable-msbc"] = true,
  ["bluez5.enable-hw-volume"] = true,
  ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
  ["bluez5.codecs"] = "[ ldac ldac_hq aac aptx aptx_hd sbc_xq sbc ]",
  ["bluez5.default.rate"] = 48000,
  ["bluez5.default.channels"] = 2,
}

bluez_monitor.rules = {
  {
    matches = {
      {
        { "device.name", "matches", "bluez_card.*" },
      },
    },
    apply_properties = {
      ["bluez5.auto-connect"] = "[ a2dp_sink ]",
      ["bluez5.hw-volume"] = "[ a2dp_sink ]",
      ["bluez5.a2dp.ldac.quality"] = "hq",
      ["bluez5.a2dp.ldac.eqmid"] = "hq",
    },
  },
}
