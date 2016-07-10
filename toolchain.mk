
include $(TOPDIR)/sources.mk

PREFIX=$(TOOLCHAIN_PREFIX)

TOOLCHAIN_BUILD_DIR=$(BUILDDIR)/toolchain
TOOLCHAIN_HOST_BUILD_DIR=$(BUILDDIR)/toolchain/host

HOST_LIBS_PREFIX=$(TOOLCHAIN_HOST_BUILD_DIR)/libs

GMP_BUILD_DIR=$(TOOLCHAIN_HOST_BUILD_DIR)/$(GMP_NAME)
MPFR_BUILD_DIR=$(TOOLCHAIN_HOST_BUILD_DIR)/$(MPFR_NAME)
MPC_BUILD_DIR=$(TOOLCHAIN_HOST_BUILD_DIR)/$(MPC_NAME)
ISL_BUILD_DIR=$(TOOLCHAIN_HOST_BUILD_DIR)/$(ISL_NAME)
CLOOG_BUILD_DIR=$(TOOLCHAIN_HOST_BUILD_DIR)/$(CLOOG_NAME)
BINUTILS_BUILD_DIR=$(TOOLCHAIN_BUILD_DIR)/$(BINUTILS_NAME)
GCC_INITIAL_BUILD_DIR=$(TOOLCHAIN_BUILD_DIR)/$(GCC_NAME)-initial
GCC_FINAL_BUILD_DIR=$(TOOLCHAIN_BUILD_DIR)/$(GCC_NAME)-final
LIBICONV_BUILD_DIR=$(TOOLCHAIN_BUILD_DIR)/$(LIBICONV_NAME)
ZLIB_BUILD_DIR=$(TOOLCHAIN_BUILD_DIR)/$(ZLIB_NAME)
MINGW_W64_BUILD_DIR=$(TOOLCHAIN_BUILD_DIR)/$(MINGW_W64_NAME)

MINGW_W64_HEADERS_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/headers
MINGW_W64_CRT_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/crt
MINGW_W64_GENDEF_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/gendef
MINGW_W64_GENIDL_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/genidl
MINGW_W64_WIDL_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/widl

all: gcc-final libiconv zlib

gmp:
	mkdir -p $(GMP_BUILD_DIR)
	(cd $(GMP_BUILD_DIR) && $(GMP_SRC_DIR)/configure --prefix=$(HOST_LIBS_PREFIX) --disable-shared --enable-static --enable-cxx)
	$(MAKE) -C $(GMP_BUILD_DIR) install
	
mpfr: gmp
	mkdir -p $(MPFR_BUILD_DIR)
	(cd $(MPFR_BUILD_DIR) && $(MPFR_SRC_DIR)/configure --prefix=$(HOST_LIBS_PREFIX) --disable-shared --enable-static --with-gmp=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(MPFR_BUILD_DIR) install

mpc: gmp mpfr
	mkdir -p $(MPC_BUILD_DIR)
	(cd $(MPC_BUILD_DIR) && $(MPC_SRC_DIR)/configure --prefix=$(HOST_LIBS_PREFIX) --disable-shared --enable-static --with-gmp=$(HOST_LIBS_PREFIX) --with-mpfr=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(MPC_BUILD_DIR) install

isl: gmp
	mkdir -p $(ISL_BUILD_DIR)
	(cd $(ISL_BUILD_DIR) && $(ISL_SRC_DIR)/configure --prefix=$(HOST_LIBS_PREFIX) --disable-shared --enable-static --with-gmp-prefix=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(ISL_BUILD_DIR) install

cloog: gmp isl
	mkdir -p $(CLOOG_BUILD_DIR)
	(cd $(CLOOG_BUILD_DIR) && $(CLOOG_SRC_DIR)/configure --prefix=$(HOST_LIBS_PREFIX) --disable-shared --enable-static --with-gmp-prefix=$(HOST_LIBS_PREFIX) --with-isl-prefix=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(CLOOG_BUILD_DIR) install

binutils: gmp mpfr mpc isl cloog
	mkdir -p $(BINUTILS_BUILD_DIR)
	(cd $(BINUTILS_BUILD_DIR) && $(BINUTILS_SRC_DIR)/configure --prefix=$(PREFIX) --target=$(TARGET) --enable-static --disable-shared --disable-nls --enable-ld --disable-lto --with-sysroot=$(PREFIX)/$(TARGET) --with-gmp=$(HOST_LIBS_PREFIX) --with-mpfr=$(HOST_LIBS_PREFIX) --with-mpc=$(HOST_LIBS_PREFIX) --with-isl=$(HOST_LIBS_PREFIX) --with-cloog=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(BINUTILS_BUILD_DIR)
	$(MAKE) -C $(BINUTILS_BUILD_DIR) install

gcc-initial: gmp mpfr mpc isl cloog binutils
	mkdir -p $(GCC_INITIAL_BUILD_DIR)
	(cd $(GCC_INITIAL_BUILD_DIR) && $(GCC_SRC_DIR)/configure --prefix=$(PREFIX) --target=$(TARGET)  --program-prefix=$(TARGET)- --disable-nls --disable-lto --disable-multilib --disable-libssp --disable-libmudflap --disable-libgomp --disable-libgcc --disable-libstdc++-v3 --disable-libatomic --disable-libvtv --disable-libquadmath --enable-sjlj-exceptions --enable-languages=c,c++ --enable-version-specific-runtime-libs --enable-decimal-float=yes --enable-threads=win32 --enable-tls --enable-fully-dynamic-string --with-gnu-ld --with-gnu-as --with-libiconv --with-system-zlib --without-dwarf2 --with-sysroot=$(PREFIX)/$(TARGET) --with-local-prefix=$(PREFIX)/local --with-native-system-header-dir=/include --with-gmp=$(HOST_LIBS_PREFIX) --with-mpfr=$(HOST_LIBS_PREFIX) --with-mpc=$(HOST_LIBS_PREFIX) --with-isl=$(HOST_LIBS_PREFIX) --with-cloog=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(GCC_INITIAL_BUILD_DIR)
	$(MAKE) -C $(GCC_INITIAL_BUILD_DIR) install

gendef:
	mkdir -p $(MINGW_W64_GENDEF_BUILD_DIR)
	(cd $(MINGW_W64_GENDEF_BUILD_DIR) && $(MINGW_W64_GENDEF_SRC_DIR)/configure --prefix=$(PREFIX))
	$(MAKE) -C $(MINGW_W64_GENDEF_BUILD_DIR) install

genidl:
	mkdir -p $(MINGW_W64_GENIDL_BUILD_DIR)
	(cd $(MINGW_W64_GENIDL_BUILD_DIR) && $(MINGW_W64_GENIDL_SRC_DIR)/configure --prefix=$(PREFIX))
	$(MAKE) -C $(MINGW_W64_GENIDL_BUILD_DIR) install

widl:
	mkdir -p $(MINGW_W64_WIDL_BUILD_DIR)
	(cd $(MINGW_W64_WIDL_BUILD_DIR) && $(MINGW_W64_WIDL_SRC_DIR)/configure --prefix=$(PREFIX) --target=$(TARGET))
	$(MAKE) -C $(MINGW_W64_WIDL_BUILD_DIR)
	cp $(MINGW_W64_WIDL_BUILD_DIR)/widl $(PREFIX)/bin

mingw-w64-headers: widl
	mkdir -p $(MINGW_W64_HEADERS_BUILD_DIR)
	(cd $(MINGW_W64_HEADERS_BUILD_DIR) && $(MINGW_W64_HEADERS_SRC_DIR)/configure --prefix=$(PREFIX)/$(TARGET) --target=$(TARGET) --enable-idl --enable-secure-api --with-widl=$(PREFIX)/bin)
	$(MAKE) -C $(MINGW_W64_HEADERS_BUILD_DIR) install

mingw-w64-crt: gcc-initial mingw-w64-headers widl genidl gendef
	mkdir -p $(MINGW_W64_CRT_BUILD_DIR)
	(cd $(MINGW_W64_CRT_BUILD_DIR) && AR='$(TARGET)-ar' AS='$(TARGET)-as' CC='$(TARGET)-gcc' CXX='$(TARGET)-g++' DLLTOOL='$(TARGET)-dlltool' RANLIB='$(TARGET)-ranlib' $(MINGW_W64_CRT_SRC_DIR)/configure --prefix=$(PREFIX)/$(TARGET) --disable-w32api --disable-lib32 --enable-lib64 --enable-private-exports)
	$(MAKE) -C $(MINGW_W64_CRT_BUILD_DIR) install

gcc-final: mingw-w64-crt
	mkdir -p $(GCC_FINAL_BUILD_DIR)
	(cd $(GCC_FINAL_BUILD_DIR) && $(GCC_SRC_DIR)/configure --prefix=$(PREFIX) --target=$(TARGET) --program-prefix=$(TARGET)- --disable-nls --disable-lto --disable-multilib --disable-libssp --disable-libmudflap --disable-libstdcxx-pch --disable-symvers --disable-shared --enable-static --enable-languages=c,c++ --enable-libstdcxx-debug --enable-version-specific-runtime-libs --enable-decimal-float=yes --enable-threads=win32 --enable-tls --enable-fully-dynamic-string --with-gnu-ld --with-gnu-as --with-libiconv --with-system-zlib --without-newlib --with-sysroot=$(PREFIX)/$(TARGET) --with-local-prefix=$(PREFIX)/local --with-native-system-header-dir=/include --with-gmp=$(HOST_LIBS_PREFIX) --with-mpfr=$(HOST_LIBS_PREFIX) --with-mpc=$(HOST_LIBS_PREFIX) --with-isl=$(HOST_LIBS_PREFIX) --with-cloog=$(HOST_LIBS_PREFIX))
	$(MAKE) -C $(GCC_FINAL_BUILD_DIR)
	$(MAKE) -C $(GCC_FINAL_BUILD_DIR) install

libiconv: gcc-final
	mkdir -p $(LIBICONV_BUILD_DIR)
	(cd $(LIBICONV_BUILD_DIR) && RC='$(TARGET)-windres' WINDRES='$(TARGET)-windres' $(LIBICONV_SRC_DIR)/configure -prefix=$(PREFIX)/$(TARGET) --host=$(TARGET) --enable-extra-encodings --enable-static --disable-shared --disable-nls --with-gnu-ld)
	$(MAKE) -C $(LIBICONV_BUILD_DIR) install

zlib: gcc-final
	mkdir -p $(ZLIB_BUILD_DIR)
	cp -a $(ZLIB_SRC_DIR)/* $(ZLIB_BUILD_DIR)
	$(MAKE) -C $(ZLIB_BUILD_DIR) -f win32/Makefile.gcc PREFIX='$(TARGET)-'
	cp $(ZLIB_BUILD_DIR)/libz.a $(PREFIX)/$(TARGET)/lib
	cp $(ZLIB_BUILD_DIR)/zconf.h $(PREFIX)/$(TARGET)/include
	cp $(ZLIB_BUILD_DIR)/zlib.h $(PREFIX)/$(TARGET)/include

