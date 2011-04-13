#############################################################
#
# boost
# 
#############################################################
BOOST_VERSION_MAJOR      := 1
BOOST_VERSION_MINOR      := 40
BOOST_VERSION_PATCHLEVEL := 0
BOOST_VERSION        := $(BOOST_VERSION_MAJOR)_$(BOOST_VERSION_MINOR)_$(BOOST_VERSION_PATCHLEVEL)
BOOST_VERSION_DOTTED := $(BOOST_VERSION_MAJOR).$(BOOST_VERSION_MINOR).$(BOOST_VERSION_PATCHLEVEL)

BOOST_SOURCE := boost_$(BOOST_VERSION).tar.bz2
BOOST_SITE   := http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/boost/
BOOST_DIR    := $(BUILD_DIR)/boost_$(BOOST_VERSION)

# Boost library configuration
ifdef BR2_PACKAGE_BOOST_CONFIG_THREADING
        BOOST_CONFIG_THREADING := multi
        BOOST_LIB_SUFFIX:=-mt 
else
        BOOST_CONFIG_THREADING := single
        BOOST_LIB_SUFFIX:=
endif
# Boost.Build default is "release threading=multi link=shared runtime-link=shared"
BOOST_BUILD_CONFIG := release threading=$(BOOST_CONFIG_THREADING)
BOOST_BUILD_CONFIG += link=shared runtime-link=shared
#BOOST_BUILD_CONFIG += -d+2

BOOST_BUILD_OPTIMIZATION := $(subst -O0,optimization=off,$(TARGET_OPTIMIZATION))
BOOST_BUILD_OPTIMIZATION := $(subst -O1,optimization=speed,$(BOOST_BUILD_OPTIMIZATION))
BOOST_BUILD_OPTIMIZATION := $(subst -O2,optimization=speed,$(BOOST_BUILD_OPTIMIZATION))
BOOST_BUILD_OPTIMIZATION := $(subst -O3,optimization=speed,$(BOOST_BUILD_OPTIMIZATION))
BOOST_BUILD_OPTIMIZATION := $(subst -Os,optimization=space,$(BOOST_BUILD_OPTIMIZATION))

# remove all flags non related to optimization
BOOST_BUILD_CONFIG += $(filter optimization=%,$(BOOST_BUILD_OPTIMIZATION))

# cross compilation ideas from
# http://goodliffe.blogspot.com/2008/05/cross-compiling-boost.html
BOOST_BJAM_CONFIG = using gcc : : $(TARGET_CXX) :
BOOST_BJAM_CONFIG += <cflags>"$(TARGET_CFLAGS) 
BOOST_BJAM_CONFIG += -I$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_SHORT)"
BOOST_BJAM_CONFIG += <cxxflags>"$(TARGET_CXXFLAGS)
BOOST_BJAM_CONFIG += -I$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_SHORT)"
BOOST_BJAM_CONFIG += <linkflags>"$(TARGET_LDFLAGS)"
BOOST_BJAM_CONFIG += ;

BOOST_LIBS :=
BOOST_PREDEPENDENCIES :=
ifdef BR2_PACKAGE_BOOST_DATE_TIME
        BOOST_LIBS += date_time
endif
ifdef BR2_PACKAGE_BOOST_FILESYSTEM
        BOOST_LIBS += filesystem
endif
ifdef BR2_PACKAGE_BOOST_FUNCTION_TYPES
        BOOST_LIBS += function_types
endif
ifdef BR2_PACKAGE_BOOST_GRAPH
        BOOST_LIBS += graph
endif
ifdef BR2_PACKAGE_BOOST_IOSTREAMS
        BOOST_LIBS += iostreams
	BOOST_BUILD_CONFIG += -sNO_COMPRESSION=1
endif
#ifdef BR2_PACKAGE_BOOST_MPI
#        BOOST_LIBS += mpi
#endif
ifdef BR2_PACKAGE_BOOST_PROGRAM_OPTIONS
        BOOST_LIBS += program_options
endif
ifdef BR2_PACKAGE_BOOST_PYTHON
        BOOST_LIBS += python
	BOOST_PREDEPENDENCIES += python
endif
ifdef BR2_PACKAGE_BOOST_REGEX
        BOOST_LIBS += regex
endif
ifdef BR2_PACKAGE_BOOST_SERIALIZATION
        BOOST_LIBS += serialization
endif
ifdef BR2_PACKAGE_BOOST_SIGNALS
        BOOST_LIBS += signals
endif
ifdef BR2_PACKAGE_BOOST_SYSTEM
        BOOST_LIBS += system
endif
ifdef BR2_PACKAGE_BOOST_TEST
        BOOST_LIBS += test
endif
ifdef BR2_PACKAGE_BOOST_THREAD
        BOOST_LIBS += thread
endif
ifdef BR2_PACKAGE_BOOST_WAVE
        BOOST_LIBS += wave
endif

$(DL_DIR)/$(BOOST_SOURCE):
	$(WGET) -P $(DL_DIR) $(BOOST_SITE)/$(BOOST_SOURCE)

boost-source: $(DL_DIR)/$(BOOST_SOURCE)

$(BOOST_DIR)/.unpacked: $(DL_DIR)/$(BOOST_SOURCE)
	bzcat $(DL_DIR)/$(BOOST_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(BOOST_DIR) package/boost/ boost-\*.patch

	touch $@

# build and install bjam -- boost build utility
BOOST_BJAM := $(STAGING_DIR)/usr/bin/bjam

$(BOOST_BJAM): $(BOOST_DIR)/.unpacked
	( cd $(BOOST_DIR)/tools/jam/src; \
	    ./build.sh gcc; \
	    ./bootstrap/jam0 -d0 -f build.jam --toolset=gcc --toolset-root= \
                             --show-locate-target \
	);
	mkdir -p $(dir $(BOOST_BJAM))
	cp $(BOOST_DIR)/tools/jam/src/bin.*/bjam $@

BOOST_LIBS_STAGING := $(addprefix $(STAGING_DIR)/usr/lib/libboost_, \
                      $(addsuffix $(BOOST_LIB_SUFFIX).so.$(BOOST_VERSION_DOTTED), \
                      $(firstword $(BOOST_LIBS))))

BOOST_LIBS_TARGET  := $(addprefix $(TARGET_DIR)/usr/lib/libboost_, \
                      $(addsuffix $(BOOST_LIB_SUFFIX).so.$(BOOST_VERSION_DOTTED), \
                      $(firstword $(BOOST_LIBS))))

$(BOOST_LIBS_STAGING): $(BOOST_DIR)/.unpacked $(BOOST_BJAM)
	( cd $(BOOST_DIR); \
	echo '$(BOOST_BJAM_CONFIG)' > tools/build/v2/user-config.jam; \
	$(BOOST_BJAM) -q \
	    --toolset=gcc \
	    --layout=system \
	    --prefix=$(STAGING_DIR)/usr \
	    $(addprefix --with-,$(BOOST_LIBS)) \
	    $(BOOST_BUILD_CONFIG) \
	    install \
	);

$(BOOST_LIBS_TARGET): $(BOOST_LIBS_STAGING)
	cp -dpf $(STAGING_DIR)/usr/lib/libboost*so* $(TARGET_DIR)/usr/lib
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libboost*so*

boost: uclibc $(BOOST_PREDEPENDENCIES) $(BOOST_LIBS_TARGET)

boost-clean:
	rm -f $(TARGET_DIR)/usr/lib/libboost*
	rm -rf $(STAGING_DIR)/usr/lib/libboost* $(STAGING_DIR)/usr/include/boost/
	-cd $(BOOST_DIR) && $(BOOST_BJAM) --toolset=gcc clean

boost-dirclean:
	rm -rf $(BOOST_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_BOOST)),y)
TARGETS+=boost
endif
