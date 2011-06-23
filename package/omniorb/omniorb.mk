#############################################################
#
# omniorb
#
#############################################################
OMNIORB_VERSION_MAJOR:=4.1
OMNIORB_VERSION_MINOR:=4
OMNIORB_VERSION = $(OMNIORB_VERSION_MAJOR).$(OMNIORB_VERSION_MINOR)

OMNIORB_SOURCE = omniORB-$(OMNIORB_VERSION).tar.gz
OMNIORB_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/omniorb/
OMNIORB_INSTALL_STAGING = YES
OMNIORB_INSTALL_TARGET = YES

OMNIORB_DEPENDENCIES = host-python
OMNIORB_CONF_OPT = PYTHON=$(HOST_DIR)/usr/bin/python

define OMNIORB_BUILD_CMDS
 $(MAKE) CC="$(HOSTCC)" CXX="$(HOSTCXX)" CFLAGS="$(HOST_CFLAGS) -I../ -I$(@D)/include" CXXFLAGS="$(HOST_CXXFLAGS) -I../ -I$(@D)/include" LDFLAGS="$(HOST_LDFLAGS)" -C $(@D)/src/tool/omniidl/cxx/cccp
 $(MAKE) CC="$(HOSTCC)" CXX="$(HOSTCXX)" CFLAGS="$(HOST_CFLAGS) -I$(@D)/include" CXXFLAGS="$(HOST_CXXFLAGS) -fPIC -DPYTHON_INCLUDE=\"<python2.7/Python.h>\" -DIDLMODULE_VERSION=\"\\\"0x2630\\\"\" -I$(@D)/src/tool/omniidl/cxx -I$(@D)/include" LDFLAGS="$(HOST_LDFLAGS) -fPIC" -C $(@D)/src/tool/omniidl/cxx
 $(MAKE) CC="$(HOSTCC)" CFLAGS="$(HOST_CFLAGS)" CXXFLAGS="$(HOST_CXXFLAGS)" LDFLAGS="$(HOST_LDFLAGS)" CDEBUGFLAGS="" CXXDEBUGFLAGS="" -C $(@D)/src/tool/omkdepend
 cp $(@D)/src/tool/omkdepend/omkdepend $(@D)/bin/
 $(MAKE) -C $(@D)
endef

$(eval $(call AUTOTARGETS,package,omniorb))

