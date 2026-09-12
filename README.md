# Secondary Black Background

Keep the Omarchy wallpaper on your main display and show solid black on every secondary display.

## Install

```bash
omarchy plugin add https://github.com/pbjorklund/omarchy-secondary-black-background.git --enable
```

By default, the display focused when the plugin starts is treated as the main display.

For a stable choice, create `~/.config/omarchy/secondary-black-background.json` with one or more monitor-description fragments in priority order:

```json
{
  "mainMonitors": [
    "AW2725Q",
    "DELL U2725QE"
  ]
}
```

Find monitor descriptions with:

```bash
hyprctl monitors -j | jq -r '.[].description'
```

The plugin watches the configuration file and applies changes without a shell restart. If no configured description matches, it falls back to the focused display, then the first connected display.

## Remove

```bash
omarchy plugin remove io.github.pbjorklund.secondary-black-background --yes
rm -f ~/.config/omarchy/secondary-black-background.json
```

## Dependencies

- Omarchy 4 with its Quickshell desktop shell
- Hyprland and `hyprctl`
- `jq` only for the optional monitor-discovery command shown above

## License

MIT
