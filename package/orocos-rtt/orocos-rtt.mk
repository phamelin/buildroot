#############################################################
#
# orocos-rtt
#
#############################################################

OROCOS_RTT_VERSION = 2.3.1
OROCOS_RTT_SOURCE = orocos-toolchain-$(OROCOS_RTT_VERSION)-sm.tar.gz
OROCOS_RTT_SITE = --ask-password --user=smuser http://robotique.jira.com/svn/SM/thirdparty/lib/orocos/
OROCOS_RTT_INSTALL_STAGING = YES
OROCOS_RTT_INSTALL_TARGET = YES
OROCOS_RTT_SUBDIR = rtt
OROCOS_RTT_CONF_OPT = -DOS_RT_MALLOC=ON -DOS_RT_MALLOC_MMAP=OFF -DOS_RT_MALLOC_SBRK=OFF -DCORBA_IMPLEMENTATION=OMNIORB -DENABLE_CORBA=ON -DENABLE_MQ=OFF -DOMNIORB4_IDL_COMPILER=$(STAGING_DIR)/usr/bin/omniidl -DENABLE_TESTS=OFF
OROCOS_RTT_DEPENDENCIES = omniorb orocos-log4cpp boost

$(eval $(call CMAKETARGETS,package,orocos-rtt))
