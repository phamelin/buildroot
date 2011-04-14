#############################################################
#
# orocos-ocl
#
#############################################################

OROCOS_OCL_VERSION = 2.3.1
OROCOS_OCL_SOURCE = orocos-toolchain-$(OROCOS_OCL_VERSION)-sm.tar.gz
OROCOS_OCL_SITE = --ask-password --user=smuser http://robotique.jira.com/svn/SM/thirdparty/lib/orocos/
OROCOS_OCL_INSTALL_STAGING = YES
OROCOS_OCL_INSTALL_TARGET = YES
OROCOS_OCL_SUBDIR = ocl
OROCOS_OCL_CONF_OPT = -DBUILD_HELLOWORLD=OFF -DBUILD_LUA_RTT=OFF -DBUILD_TESTING=OFF 
OROCOS_OCL_DEPENDENCIES = orocos-log4cpp orocos-rtt readline host-pkg-config

$(eval $(call CMAKETARGETS,package,orocos-ocl))
