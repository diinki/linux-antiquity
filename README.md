<div align="center">

#  Linux Antiquity 

<img src="./screenshots/happy_sun.png" width="8%">

</div>

<div align="center">

 **A highly tasteful, customizable & feature-rich Linux-theme reminiscent of art-nouveau and old drawings related to astronomy, science, and mythology.** 

</div>


<div align="center">

<a href="https://discord.gg/gleep">![badge](https://img.shields.io/badge/discord-262622?style=for-the-badge&logo=discord&logoColor=262622&logoSize=auto&color=e2e2d3) </a>
<a href="https://ko-fi.com/diinki">![badge](https://img.shields.io/badge/tip-262622?style=for-the-badge&logo=kofi&logoColor=262622&logoSize=auto&color=e2e2d3) </a>
<a href="https://www.youtube.com/watch?v=qOoWQeIGKiA">![badge](https://img.shields.io/badge/youtube_video-262622?style=for-the-badge&logo=youtube&logoColor=262622&logoSize=auto&color=e2e2d3) </a>

</div>

![image](./screenshots/1.png)
![image](./screenshots/2.png)
![image](./screenshots/3.png)


| theme picker                       | 
| ---------------------------------- | 
| ![image](./screenshots/theme_picker.png) |
|                                    |                                   

| weather widgets                     |                                    |
| ----------------------------------  | ---------------------------------- |
| ![image](./screenshots/hot.png)|![image](./screenshots/phlegmatic.png)|
|                                     |          



*And much more...* Wallpapers can be found in my [wallpapers repo](https://github.com/diinki/wallpapers).

___

> [!CAUTION]
> This theme is first and foremost an art project which entails that as of version 0.1 the main focus was to get a proof of concept done and ready for my video about this theme, so **INSTALL AND USE AT YOUR OWN RISK!**
>
>A lot of the code, a **large** portion will be refactored post version 0.1, and a lot of designs may change and be improved.
>
>Performance of the UI was not a concern as of version 0.1, but regardless it runs well for me. Just keep in mind that it isn't optimized yet.
>
>If you intend to use this theme, do subscribe/follow this repo to be notified of any updates. I recommend installing the latest version of the theme often from the releases page.
>
>I'm quite busy, but I will try to improve and update this theme as much as I can since I will be using this as my main theme.
____

### Dependencies 📦

> [!TIP]
> The install script should notify you if anything is missing. It will also create backups if any existing directories are found.


**Required Software:**
* `Hyprland` (>0.55) - we use lua now!
* `Hyprpaper` *For wallpapers*
* `Quickshell` (>0.3.0)
* `Kitty` *Terminal configs use by default*
* `Nemo` *File explorer configs use by default*
* `Mako`
* `Hyprshot` *For the screenshot keybind*
* `jq`
* `socat`

**Recommended Software:**
* `nwg-look` To easily set icon theme, gtk theme, cursors etc
* `dconf` & `dconf-editor` To easily set environment variables related to the theme.

### Editing crucial sections ⚠️
Things such as Monitor details, wallpaper directories, and also creating an open weather map account for weather widget data have to be done manually for now.

Edit `~/.config/hypr/hyprland.lua` & `~/.config/hypr/hyprpaper.conf`
to set monitor details, I've commented the files in a detailed manner so it shouldn't be hard to figure this out.

To enable weather widget support simply open the settings menu of the theme using the left side-bar buttons.

You'll be able to see where to input [open weather map](https://openweathermap.org/) details. Its free and lets you use the beautiful weather widget!

> [!NOTE]
> Open weather map is lovely! They provide more than enough free API calls and  detailed data that is used by the theme weather widgets.

> [!NOTE]
> I am considering creating a settings tab specifically for setting monitor data in order to reduce the amount of config file editing, do look forward to that!

### Configuring the sidebar & bottom bar 🎛️
The radial sidebar and bottom bar can be tweaked without touching any qml, in `~/.config/quickshell/settings.json` (the file is created on first run) under `radialBars`:

* `enableSidebar` / `enableBottomBar` — turn either bar off entirely.
* `raiseOnHover` — set to `false` if you don't want the bars to jump to the front when your mouse touches the screen edge.
* `monitorOverrides` — override any of the above per monitor, keyed by the monitor names from `hyprctl monitors`.

```json
"radialBars": {
    "enableSidebar": true,
    "enableBottomBar": true,
    "raiseOnHover": true,
    "monitorOverrides": {
        "DP-2": { "enableSidebar": false, "raiseOnHover": false }
    }
}
```

You can also raise/lower both bars with a keybind (`mod` + `B` by default) — see the `toggleBars` command in `~/.config/hypr/hyprland.lua`.

### Setting quickshell-specific Icon Themes 🎨
You can find and use your own icon theme but you will need to customize the top lines of code in the `~/.config/quickshell/shell.qml` directory to set the icon theme in the quickshell UI specifically. Namely:

`~/.config/quickshell/shell.qml`:
```
/* NOTE: CHANGE THESE IF YOU WANT TO USE A DIFFERENT ICON THEME:*/
//@ pragma IconTheme buuf-nestort
//@ pragma Env QS_ICON_THEME=buuf-nestort
```

I have included an icon theme that I think fits well in this repo as well (buuf-nestort). But feel free to pick your own.

Make sure to place the icon theme folders in `~/.local/share/icons` in order for them to be found.

### External Themes 🎨
I decided to not include things such as GTK theme and cursor theme into this repo, because those are highly up to you and I think there's a wide range of styles that would look well with this theme.

### Installation ⬇️
Simply run the install script `./install.sh` and it should move the relevant directories to your `~/.config` folder. If you prefer to do this yourself then you can simply find the config directories in this repo and move them manually.

The install script will create backups of existing directories before it replaces them, and it will also notify you if any dependencies are missing.

This theme does require some manual config file editing in order to setup wallpapers, monitors, and also set the kitty terminal theme to whichever one you want.

I've made a set of kitty terminal themes that match each relevant theme that comes with Linux Antiquity by default.

> [!NOTE]
>I might also make a more detailed installation video guide later on, I'll link that here in the future.

### Default keybinds *️⃣
You can edit and view the default keybinds in `~/.config/hypr/hyprland.lua`.
These are just my personal preferences, so feel entirely free to edit them.

> [!NOTE]
> I might make editing keybinds part of the settings menu in the future, along with other things you'd usually edit config files manually for!

- `mod` = the super key, (the windows key, as some people refer to it as). You can re-bind mod to something else if you wish.

- `mod` + `Enter` = launch terminal.
- `mod` + `D` = open application launcher popup.
- `mod` + `B` = bring the sidebar & bottom bar to the front, or send them back behind windows.
- `mod` + `E` = open file explorer launcher popup.
- `mod` + `[any number, 1-9]` = switch focus to the workspace equivalent to the number.
- `mod` + `Shift` + ` [any number, 1-9]` = move the focused/hovered window to the workspace equivalent to the number.
- `mod` + `Shift` + ` Space` = toggle floating mode for the focused/hovered window.
- `mod` + `Q` = Exit/Kill the focused/hovered window.
- `mod` + `F` = toggle full-screen mode for the focused/hovered window.
- `mod` + `Right Mouse Button` + `move mouse` = re-size a window
- `mod` + `Left Mouse Button` + ``move mouse``= move a window

