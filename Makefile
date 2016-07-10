
export TARGET=x86_64-w64-mingw32

TOPDIR=$(CURDIR)
DLDIR=$(TOPDIR)/dl
SRCDIR=$(TOPDIR)/src
BUILDDIR=$(TOPDIR)/build

export TOPDIR DLDIR SRCDIR BUILDDIR

export TOOLCHAIN_PREFIX=$(TOPDIR)/toolchain/usr
export TARGET_PREFIX=$(TOPDIR)/target

all: target

target: toolchain
	PATH=$(TOOLCHAIN_PREFIX)/bin:$(shell echo $$PATH) $(MAKE) -f target.mk

toolchain:
	PATH=$(TOOLCHAIN_PREFIX)/bin:$(shell echo $$PATH) $(MAKE) -f toolchain.mk

.PHONY: target toolchain

