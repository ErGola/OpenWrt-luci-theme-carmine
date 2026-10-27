# OpenWrt-luci-theme-carmine

A clean, modern theme for the OpenWrt LuCI web interface — white cards, a
crimson accent, a sidebar with icons, and light/dark modes.

- Works with **OpenWrt 23.05, 24.10 and 25.12** (ucode-based LuCI).
- Three variants under *System → System → Language and Style → Design*:
  - **Carmine** – follows your device's light/dark preference (the ☀︎/☾ button in
    the topbar lets you override it per browser session)
  - **CarmineLight** – always light
  - **CarmineDark** – always dark
- Phone-friendly: the sidebar becomes a slide-out drawer, tables turn into
  cards, and the Save & Apply bar stays pinned at the bottom.

---

## Install (wget — any version, needs SSH)

Run this single command over SSH on your router — no SCP, no package manager:

```sh
wget -O /tmp/carmine-install.sh \
  https://raw.githubusercontent.com/ErGola/OpenWrt-luci-theme-carmine/main/install.sh \
&& sh /tmp/carmine-install.sh
```

The script fetches every theme file directly from GitHub, registers the three
variants in UCI, switches LuCI to Carmine, and clears the cache.

**Uninstall:**

```sh
sh /tmp/carmine-install.sh uninstall
```

> **Requires** an internet connection on the router and OpenWrt 23.05 or newer
> with LuCI installed.

---

## Alternative installs

### opkg package (OpenWrt 23.05 / 24.10)

Web UI: *System → Software → Upload Package…* and pick
`luci-theme-carmine_1.0.0-r1_all.ipk`.

Or over SSH:

```sh
opkg install /tmp/luci-theme-carmine_1.0.0-r1_all.ipk
```

### apk package (OpenWrt 25.12)

```sh
apk add --allow-untrusted /tmp/luci-theme-carmine-1.0.0-r1.apk
```

*(The Upload Package… button in 25.12 refuses unsigned packages; use the wget
installer or the command above.)*

After installing, reload LuCI in the browser (Ctrl+F5 / pull to refresh).

---

## Switch themes / undo

Go to *System → System → Language and Style → Design*, choose another theme,
then **Save & Apply**.

If LuCI ever fails to load, restore via SSH:

```sh
uci set luci.main.mediaurlbase=/luci-static/bootstrap && uci commit luci
```

---

## Customise

All colours are CSS variables at the top of
`/www/luci-static/carmine/cascade.css`.

To change the accent colour, edit `--primary` (and `--primary-hover`,
`--primary-text`, `--primary-soft`) in the `:root` block for light mode and
`:root[data-darkmode="true"]` for dark mode.

To use your own logo, replace `/www/luci-static/carmine/logo.svg`.

A firmware upgrade (`sysupgrade`) does not preserve installed packages — just
re-run the wget installer after upgrading.

---

## Repository layout

```
install.sh                          ← wget one-command installer (start here)
htdocs/luci-static/carmine/        ← CSS, SVG logo, PNG icons
htdocs/luci-static/resources/      ← menu-carmine.js (sidebar + tabs logic)
ucode/template/themes/carmine/     ← header.ut, footer.ut, sysauth.ut
root/etc/uci-defaults/             ← UCI theme-registration script
Makefile                           ← OpenWrt SDK / buildroot build file
tools/install.sh.in                ← source template for the self-contained installer
```

---

## Build from source (OpenWrt SDK / buildroot)

```sh
cp -r OpenWrt-luci-theme-carmine <sdk>/package/luci-theme-carmine
make package/luci-theme-carmine/compile V=s
```

---

## License

Apache License 2.0.
