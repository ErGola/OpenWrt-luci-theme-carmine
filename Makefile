#
# Carmine - a clean, modern theme for LuCI
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Carmine Theme (clean red, light/dark)
LUCI_DEPENDS:=+luci-base
LUCI_PKGARCH:=all

# The stylesheet uses modern CSS (custom properties, masks, :has) that
# csstidy would mangle, so ship it as written.
LUCI_MINIFY_CSS:=0

PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

define Package/luci-theme-carmine/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	uci -q delete luci.themes.Carmine
	uci -q delete luci.themes.CarmineDark
	uci -q delete luci.themes.CarmineLight
	case "$$(uci -q get luci.main.mediaurlbase)" in
		/luci-static/carmine*) uci set luci.main.mediaurlbase=/luci-static/bootstrap ;;
	esac
	uci commit luci
	rm -f /tmp/luci-indexcache*
	# opkg leaves symlinked directories behind; tidy them up
	rm -f /www/luci-static/carmine-dark /www/luci-static/carmine-light \
		/usr/share/ucode/luci/template/themes/carmine-dark \
		/usr/share/ucode/luci/template/themes/carmine-light
	rmdir /www/luci-static/carmine /usr/share/ucode/luci/template/themes/carmine 2>/dev/null
}
exit 0
endef

# In-tree builds (feeds/luci/themes/luci-theme-carmine) use ../../luci.mk,
# SDK builds from package/ use the luci feed copy.
include $(if $(wildcard ../../luci.mk),../../luci.mk,$(TOPDIR)/feeds/luci/luci.mk)

# call BuildPackage - OpenWrt buildroot signature
