include $(TOPDIR)/rules.mk

# Name and release number of this package
PKG_NAME:=macchina
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/macchina
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=macchina.io
  DEPENDS:=+libopenssl +libstdcpp +libpthread +librt
endef

define Package/macchina/description
	A toolkit for building IoT device applications in JavaScript and C++
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
TARGET_CXXFLAGS += -I$(STAGING_DIR)/usr/include
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) macchina.io/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) hosttools DEFAULT_TARGET=shared_release
	$(CP) OpenWRT $(PKG_BUILD_DIR)/platform/build/config
	$(MAKE) -C $(PKG_BUILD_DIR) POCO_CONFIG=OpenWRT DEFAULT_TARGET=shared_release V8_NOSNAPSHOT=1 \
	$(MAKE_FLAGS) \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_CXXFLAGS="$(TARGET_CXXFLAGS)" \
        TARGET_LINKFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/macchina/install
	$(MAKE) -C $(PKG_BUILD_DIR) install_runtime POCO_CONFIG=OpenWRT INSTALLDIR=$(1)/usr $(MAKE_FLAGS)
	-mv $(1)/usr/etc $(1)/etc
	$(CP) macchina.properties $(1)/etc
endef

$(eval $(call BuildPackage,macchina))

