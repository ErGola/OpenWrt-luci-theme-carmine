#!/bin/sh
#
# Carmine - a clean, modern theme for LuCI
# GitHub-raw installer for OpenWrt 23.05 / 24.10 / 25.12
#
# Install:
#   wget -O /tmp/carmine-install.sh \
#     https://raw.githubusercontent.com/ErGola/OpenWrt-luci-theme-carmine/main/install.sh \
#   && sh /tmp/carmine-install.sh
#
# Uninstall:
#   sh /tmp/carmine-install.sh uninstall
#
# Licensed to the public under the Apache License 2.0.

VERSION="1.0.0"
BASE_URL="https://raw.githubusercontent.com/ErGola/OpenWrt-luci-theme-carmine/main"
ROOT="${CARMINE_ROOT:-}"

say() { printf '%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# ── fetch one file, keep permissions ─────────────────────────────────────────
fetch() {
	local url="$1"
	local dest="$2"
	local dir
	dir="$(dirname "$dest")"

	mkdir -p "$dir" || die "cannot create directory $dir"

	if command -v wget >/dev/null 2>&1; then
		wget -q -O "$dest" "$url" || die "wget failed for $url"
	elif command -v curl >/dev/null 2>&1; then
		curl -fsSL -o "$dest" "$url" || die "curl failed for $url"
	else
		die "neither wget nor curl found"
	fi
}

# ── symlink helper ────────────────────────────────────────────────────────────
lnk() {
	local target="$1"   # e.g. carmine
	local link="$2"     # e.g. /www/luci-static/carmine-dark
	rm -f "$link"
	ln -sf "$target" "$link"
}

clear_cache() {
	rm -f  "$ROOT"/tmp/luci-indexcache*   2>/dev/null
	rm -rf "$ROOT"/tmp/luci-modulecache   2>/dev/null
	return 0
}

fallback_theme() {
	local t
	[ -d "$ROOT/www/luci-static/bootstrap" ] && { echo /luci-static/bootstrap; return; }
	for t in $(uci -q show luci.themes | sed -n "s/^luci\.themes\.[^=]*='\{0,1\}\([^']*\)'\{0,1\}$/\1/p"); do
		case "$t" in /luci-static/carmine*) continue ;; esac
		[ -d "$ROOT/www$t" ] && { echo "$t"; return; }
	done
	echo /luci-static/bootstrap
}

# ── install ───────────────────────────────────────────────────────────────────
do_install() {
	[ -d "$ROOT/usr/share/ucode/luci/template" ] || \
		die "LuCI with ucode templates not found. Need OpenWrt 23.05+ with LuCI."

	say "Installing Carmine theme $VERSION from GitHub..."

	# Static assets
	fetch "$BASE_URL/htdocs/luci-static/carmine/cascade.css"     "$ROOT/www/luci-static/carmine/cascade.css"
	fetch "$BASE_URL/htdocs/luci-static/carmine/logo.svg"        "$ROOT/www/luci-static/carmine/logo.svg"
	fetch "$BASE_URL/htdocs/luci-static/carmine/logo_48.png"     "$ROOT/www/luci-static/carmine/logo_48.png"
	fetch "$BASE_URL/htdocs/luci-static/carmine/logo_180.png"    "$ROOT/www/luci-static/carmine/logo_180.png"

	# JS menu module
	fetch "$BASE_URL/htdocs/luci-static/resources/menu-carmine.js" \
	      "$ROOT/www/luci-static/resources/menu-carmine.js"

	# ucode templates
	fetch "$BASE_URL/ucode/template/themes/carmine/header.ut"  \
	      "$ROOT/usr/share/ucode/luci/template/themes/carmine/header.ut"
	fetch "$BASE_URL/ucode/template/themes/carmine/footer.ut"  \
	      "$ROOT/usr/share/ucode/luci/template/themes/carmine/footer.ut"
	fetch "$BASE_URL/ucode/template/themes/carmine/sysauth.ut" \
	      "$ROOT/usr/share/ucode/luci/template/themes/carmine/sysauth.ut"

	# Variant symlinks  (carmine-dark → carmine, carmine-light → carmine)
	lnk carmine "$ROOT/www/luci-static/carmine-dark"
	lnk carmine "$ROOT/www/luci-static/carmine-light"
	lnk carmine "$ROOT/usr/share/ucode/luci/template/themes/carmine-dark"
	lnk carmine "$ROOT/usr/share/ucode/luci/template/themes/carmine-light"

	# Register theme variants in UCI
	uci -q get luci.themes.Carmine      >/dev/null || uci set luci.themes.Carmine=/luci-static/carmine
	uci -q get luci.themes.CarmineDark  >/dev/null || uci set luci.themes.CarmineDark=/luci-static/carmine-dark
	uci -q get luci.themes.CarmineLight >/dev/null || uci set luci.themes.CarmineLight=/luci-static/carmine-light

	# Switch to the theme (skip if already on a Carmine variant)
	case "$(uci -q get luci.main.mediaurlbase)" in
		/luci-static/carmine*) ;;
		*)
			uci set luci.main.mediaurlbase=/luci-static/carmine || \
				die "could not switch LuCI to the theme (uci failed)"
		;;
	esac

	uci commit luci

	clear_cache

	say ""
	say "Done!  Reload the LuCI page in your browser (Ctrl+F5 on a PC,"
	say "pull to refresh on a phone)."
	say ""
	say "Tip: pick CarmineLight / CarmineDark under"
	say "  System → System → Language and Style → Design"
	say "to force a colour mode."
}

# ── uninstall ─────────────────────────────────────────────────────────────────
do_uninstall() {
	say "Removing Carmine theme..."

	rm -f "$ROOT/www/luci-static/carmine/cascade.css"
	rm -f "$ROOT/www/luci-static/carmine/logo.svg"
	rm -f "$ROOT/www/luci-static/carmine/logo_48.png"
	rm -f "$ROOT/www/luci-static/carmine/logo_180.png"
	rm -f "$ROOT/www/luci-static/resources/menu-carmine.js"
	rm -f "$ROOT/usr/share/ucode/luci/template/themes/carmine/header.ut"
	rm -f "$ROOT/usr/share/ucode/luci/template/themes/carmine/footer.ut"
	rm -f "$ROOT/usr/share/ucode/luci/template/themes/carmine/sysauth.ut"
	rm -f "$ROOT/www/luci-static/carmine-dark"
	rm -f "$ROOT/www/luci-static/carmine-light"
	rm -f "$ROOT/usr/share/ucode/luci/template/themes/carmine-dark"
	rm -f "$ROOT/usr/share/ucode/luci/template/themes/carmine-light"
	rmdir "$ROOT/www/luci-static/carmine"                          2>/dev/null
	rmdir "$ROOT/usr/share/ucode/luci/template/themes/carmine"    2>/dev/null

	uci -q delete luci.themes.Carmine
	uci -q delete luci.themes.CarmineDark
	uci -q delete luci.themes.CarmineLight

	case "$(uci -q get luci.main.mediaurlbase)" in
		/luci-static/carmine*)
			fb="$(fallback_theme)"
			uci set luci.main.mediaurlbase="$fb"
			say "LuCI switched back to ${fb##*/}."
		;;
	esac

	uci commit luci
	clear_cache

	say "Done. Reload the LuCI page in your browser."
}

# ── entry point ───────────────────────────────────────────────────────────────
case "${1:-install}" in
	install|update)   do_install   ;;
	uninstall|remove) do_uninstall ;;
	*) say "usage: sh $0 [install|uninstall]"; exit 1 ;;
esac

exit 0
