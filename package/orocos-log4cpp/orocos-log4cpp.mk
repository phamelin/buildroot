#############################################################
#
# orocos-log4cpp
#
#############################################################

OROCOS_LOG4CPP_VERSION = 2.3.1
OROCOS_LOG4CPP_SOURCE = orocos-toolchain-$(OROCOS_LOG4CPP_VERSION)-src.tar.gz
OROCOS_LOG4CPP_SITE = http://www.orocos.org/stable/toolchain/v$(OROCOS_LOG4CPP_VERSION)/
OROCOS_LOG4CPP_INSTALL_STAGING = YES
OROCOS_LOG4CPP_INSTALL_TARGET = YES
OROCOS_LOG4CPP_SUBDIR = log4cpp

$(eval $(call CMAKETARGETS,package,orocos-log4cpp))
