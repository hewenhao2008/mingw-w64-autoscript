
include $(TOPDIR)/sources.mk

PREFIX=/mingw64
HOST=$(TARGET)

TARGET_BUILD_DIR=$(BUILDDIR)/target
TARGET_BOOTSTRAP_LIB_BUILD_DIR=$(BUILDDIR)/target/bootstrap

TARGET_BOOTSTRAP_LIBS_PREFIX=$(TARGET_BOOTSTRAP_LIB_BUILD_DIR)/libs

GMP_BOOTSTRAP_BUILD_DIR=$(TARGET_BOOTSTRAP_LIB_BUILD_DIR)/$(GMP_NAME)
MPFR_BOOTSTRAP_BUILD_DIR=$(TARGET_BOOTSTRAP_LIB_BUILD_DIR)/$(MPFR_NAME)
MPC_BOOTSTRAP_BUILD_DIR=$(TARGET_BOOTSTRAP_LIB_BUILD_DIR)/$(MPC_NAME)
ISL_BOOTSTRAP_BUILD_DIR=$(TARGET_BOOTSTRAP_LIB_BUILD_DIR)/$(ISL_NAME)
CLOOG_BOOTSTRAP_BUILD_DIR=$(TARGET_BOOTSTRAP_LIB_BUILD_DIR)/$(CLOOG_NAME)

GMP_BUILD_DIR=$(TARGET_BUILD_DIR)/$(GMP_NAME)
MPFR_BUILD_DIR=$(TARGET_BUILD_DIR)/$(MPFR_NAME)
MPC_BUILD_DIR=$(TARGET_BUILD_DIR)/$(MPC_NAME)
ISL_BUILD_DIR=$(TARGET_BUILD_DIR)/$(ISL_NAME)
CLOOG_BUILD_DIR=$(TARGET_BUILD_DIR)/$(CLOOG_NAME)
M4_BUILD_DIR=$(TARGET_BUILD_DIR)/$(M4_NAME)
LIBTOOL_BUILD_DIR=$(TARGET_BUILD_DIR)/$(LIBTOOL_NAME)
BINUTILS_BUILD_DIR=$(TARGET_BUILD_DIR)/$(BINUTILS_NAME)
GCC_BUILD_DIR=$(TARGET_BUILD_DIR)/$(GCC_NAME)
GDB_BUILD_DIR=$(TARGET_BUILD_DIR)/$(GDB_NAME)
LIBICONV_BUILD_DIR=$(TARGET_BUILD_DIR)/$(LIBICONV_NAME)
ZLIB_BUILD_DIR=$(TARGET_BUILD_DIR)/$(ZLIB_NAME)
MINGW_W64_BUILD_DIR=$(TARGET_BUILD_DIR)/$(MINGW_W64_NAME)

MINGW_W64_HEADERS_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/headers
MINGW_W64_CRT_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/crt
MINGW_W64_GENDEF_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/gendef
MINGW_W64_GENIDL_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/genidl
MINGW_W64_GENPEIMG_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/genpeimg
MINGW_W64_WIDL_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/widl
MINGW_W64_LIBMANGLE_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/libmangle
MINGW_W64_WINPTHREADS_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/winpthreads
MINGW_W64_WINSTORECOMPAT_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/winstorecompat

all: gmp mpfr mpc isl cloog binutils m4 libtool gendef genidl genpeimg widl winpthreads winstorecompat gcc libiconv zlib gdb
	-find $(TARGET_PREFIX)/$(PREFIX)/lib -name '*.la' -name '*.pc' | xargs sed -i 's/$(subst /,\/,$(TARGET_BOOTSTRAP_LIBS_PREFIX))/$(subst /,\/,$(PREFIX))/g'
	-find $(TARGET_PREFIX)/ -name '*.exe' -o -name '*.dll' | xargs $(TARGET)-strip

gmp-bootstrap:
	mkdir -p $(GMP_BOOTSTRAP_BUILD_DIR)
	(cd $(GMP_BOOTSTRAP_BUILD_DIR) && $(GMP_SRC_DIR)/configure --prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --host=$(HOST) --enable-cxx --enable-shared --disable-static)
	$(MAKE) -C $(GMP_BOOTSTRAP_BUILD_DIR) install
	
mpfr-bootstrap: gmp-bootstrap
	mkdir -p $(MPFR_BOOTSTRAP_BUILD_DIR)
	(cd $(MPFR_BOOTSTRAP_BUILD_DIR) && $(MPFR_SRC_DIR)/configure --prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --host=$(HOST) --with-gmp=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(MPFR_BOOTSTRAP_BUILD_DIR) install

mpc-bootstrap: gmp-bootstrap mpfr-bootstrap
	mkdir -p $(MPC_BOOTSTRAP_BUILD_DIR)
	(cd $(MPC_BOOTSTRAP_BUILD_DIR) && $(MPC_SRC_DIR)/configure --prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --host=$(HOST) --with-mpfr=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-gmp=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(MPC_BOOTSTRAP_BUILD_DIR) install

isl-bootstrap: gmp-bootstrap
	mkdir -p $(ISL_BOOTSTRAP_BUILD_DIR)
	(cd $(ISL_BOOTSTRAP_BUILD_DIR) && $(ISL_SRC_DIR)/configure --prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --host=$(HOST) --with-gmp-prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(ISL_BOOTSTRAP_BUILD_DIR) install

cloog-bootstrap: gmp-bootstrap isl-bootstrap
	mkdir -p $(CLOOG_BOOTSTRAP_BUILD_DIR)
	(cd $(CLOOG_BOOTSTRAP_BUILD_DIR) && $(CLOOG_SRC_DIR)/configure --prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --host=$(HOST) --with-isl-prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-gmp-prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(CLOOG_BOOTSTRAP_BUILD_DIR) install

binutils: gmp-bootstrap mpfr-bootstrap mpc-bootstrap isl-bootstrap cloog-bootstrap
	mkdir -p $(BINUTILS_BUILD_DIR)
	(cd $(BINUTILS_BUILD_DIR) && $(BINUTILS_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --target=$(TARGET) --enable-shared --disable-nls --enable-ld --enable-lto --with-gmp=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-mpfr=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-mpc=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-isl=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-cloog=$(TARGET_BOOTSTRAP_LIBS_PREFIX))
	$(MAKE) -C $(BINUTILS_BUILD_DIR)
	$(MAKE) -C $(BINUTILS_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

m4:
	mkdir -p $(M4_BUILD_DIR)
	(cd $(M4_BUILD_DIR) && $(M4_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --enable-threads=windows --enable-c++)
	$(MAKE) -C $(M4_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

libtool:
	mkdir -p $(LIBTOOL_BUILD_DIR)
	(cd $(LIBTOOL_BUILD_DIR) && $(LIBTOOL_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --with-gnu-ld --enable-ltdl-install --enable-shared --enable-static)
	$(MAKE) -C $(LIBTOOL_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

libmangle:
	mkdir -p $(MINGW_W64_LIBMANGLE_BUILD_DIR)
	(cd $(MINGW_W64_LIBMANGLE_BUILD_DIR) && $(MINGW_W64_LIBMANGLE_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST))
	$(MAKE) -C $(MINGW_W64_LIBMANGLE_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

gendef: libmangle
	mkdir -p $(MINGW_W64_GENDEF_BUILD_DIR)
	(cd $(MINGW_W64_GENDEF_BUILD_DIR) && $(MINGW_W64_GENDEF_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --with-mangle=$(TARGET_PREFIX)/$(PREFIX))
	$(MAKE) -C $(MINGW_W64_GENDEF_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

genidl:
	mkdir -p $(MINGW_W64_GENIDL_BUILD_DIR)
	(cd $(MINGW_W64_GENIDL_BUILD_DIR) && $(MINGW_W64_GENIDL_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST))
	$(MAKE) -C $(MINGW_W64_GENIDL_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

genpeimg:
	mkdir -p $(MINGW_W64_GENPEIMG_BUILD_DIR)
	(cd $(MINGW_W64_GENPEIMG_BUILD_DIR) && $(MINGW_W64_GENPEIMG_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST))
	$(MAKE) -C $(MINGW_W64_GENPEIMG_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

widl:
	mkdir -p $(MINGW_W64_WIDL_BUILD_DIR)
	(cd $(MINGW_W64_WIDL_BUILD_DIR) && ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes $(MINGW_W64_WIDL_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --target=$(TARGET) --program-prefix="")
	$(MAKE) -C $(MINGW_W64_WIDL_BUILD_DIR)
	$(MAKE) -C $(MINGW_W64_WIDL_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

mingw-w64-headers:
	mkdir -p $(MINGW_W64_HEADERS_BUILD_DIR)
	(cd $(MINGW_W64_HEADERS_BUILD_DIR) && $(MINGW_W64_HEADERS_SRC_DIR)/configure --prefix=$(PREFIX)/$(TARGET) --target=$(TARGET) --host=$(HOST) --enable-idl --enable-secure-api)
	$(MAKE) -C $(MINGW_W64_HEADERS_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

mingw-w64-crt: mingw-w64-headers
	mkdir -p $(MINGW_W64_CRT_BUILD_DIR)
	(cd $(MINGW_W64_CRT_BUILD_DIR) && AR='$(TARGET)-ar' AS='$(TARGET)-as' CC='$(TARGET)-gcc' CXX='$(TARGET)-g++' DLLTOOL='$(TARGET)-dlltool' RANLIB='$(TARGET)-ranlib' $(MINGW_W64_CRT_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --disable-w32api --disable-lib32 --enable-lib64 --enable-private-exports)
	$(MAKE) -C $(MINGW_W64_CRT_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

winpthreads:
	mkdir -p $(MINGW_W64_WINPTHREADS_BUILD_DIR)
	(cd $(MINGW_W64_WINPTHREADS_BUILD_DIR) && $(MINGW_W64_WINPTHREADS_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --enable-shared --enable-static --with-gnu-ld)
	$(MAKE) -C $(MINGW_W64_WINPTHREADS_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

winstorecompat:
	mkdir -p $(MINGW_W64_WINSTORECOMPAT_BUILD_DIR)
	(cd $(MINGW_W64_WINSTORECOMPAT_BUILD_DIR) && $(MINGW_W64_WINSTORECOMPAT_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST))
	$(MAKE) -C $(MINGW_W64_WINSTORECOMPAT_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

gcc: mingw-w64-crt gmp-bootstrap mpfr-bootstrap mpc-bootstrap isl-bootstrap cloog-bootstrap
	mkdir -p $(GCC_BUILD_DIR)
	(cd $(GCC_BUILD_DIR) && $(GCC_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --target=$(TARGET) --disable-nls --enable-lto --disable-multilib --disable-win32-registry --disable-libstdcxx-pch --disable-symvers --enable-shared --enable-static --enable-languages=c,c++ --enable-libstdcxx-debug --enable-version-specific-runtime-libs --enable-decimal-float=yes --enable-threads=posix --enable-tls --enable-fully-dynamic-string --with-gnu-ld --with-gnu-as --without-newlib --with-libiconv --with-local-prefix=$(PREFIX)/local --with-native-system-header-dir=/mingw64/include --with-gmp=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-mpfr=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-mpc=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-isl=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-cloog=$(TARGET_BOOTSTRAP_LIBS_PREFIX))
	_COMPILE_TIME_PREFIX=$(TARGET_PREFIX)/ $(MAKE) -C $(GCC_BUILD_DIR)
	$(MAKE) -C $(GCC_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

gdb:
	mkdir -p $(GDB_BUILD_DIR)
	(cd $(GDB_BUILD_DIR) && $(GDB_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --target=$(TARGET) --disable-nls --with-system-zlib --with-isl=$(TARGET_BOOTSTRAP_LIBS_PREFIX))
	$(MAKE) -C $(GDB_BUILD_DIR)
	$(MAKE) -C $(GDB_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

gmp:
	mkdir -p $(GMP_BUILD_DIR)
	(cd $(GMP_BUILD_DIR) && $(GMP_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --enable-cxx --enable-shared --disable-static)
	$(MAKE) -C $(GMP_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)
	
mpfr: gmp-bootstrap
	mkdir -p $(MPFR_BUILD_DIR)
	(cd $(MPFR_BUILD_DIR) && $(MPFR_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --with-gmp=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(MPFR_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

mpc: gmp-bootstrap mpfr-bootstrap
	mkdir -p $(MPC_BUILD_DIR)
	(cd $(MPC_BUILD_DIR) && $(MPC_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --with-mpfr=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-gmp=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(MPC_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

isl: gmp-bootstrap
	mkdir -p $(ISL_BUILD_DIR)
	(cd $(ISL_BUILD_DIR) && $(ISL_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --with-gmp-prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(ISL_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

cloog: gmp-bootstrap isl-bootstrap
	mkdir -p $(CLOOG_BUILD_DIR)
	(cd $(CLOOG_BUILD_DIR) && $(CLOOG_SRC_DIR)/configure --prefix=$(PREFIX) --host=$(HOST) --with-isl-prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --with-gmp-prefix=$(TARGET_BOOTSTRAP_LIBS_PREFIX) --enable-shared --disable-static)
	$(MAKE) -C $(CLOOG_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

zlib:
	mkdir -p $(ZLIB_BUILD_DIR)
	cp -a $(ZLIB_SRC_DIR)/* $(ZLIB_BUILD_DIR)
	$(MAKE) -C $(ZLIB_BUILD_DIR) -f win32/Makefile.gcc PREFIX=$(TARGET)- DESTDIR=$(ZLIB_BUILD_DIR)/install install
	cp $(ZLIB_BUILD_DIR)/libz.a $(TARGET_PREFIX)/$(PREFIX)/lib
	cp $(ZLIB_BUILD_DIR)/libz.dll.a $(TARGET_PREFIX)/$(PREFIX)/lib
	cp $(ZLIB_BUILD_DIR)/install/pkgconfig/zlib.pc $(TARGET_PREFIX)/$(PREFIX)/lib/pkgconfig
	cp $(ZLIB_BUILD_DIR)/zconf.h $(TARGET_PREFIX)/$(PREFIX)/include
	cp $(ZLIB_BUILD_DIR)/zlib.h $(TARGET_PREFIX)/$(PREFIX)/include
	cp $(ZLIB_BUILD_DIR)/zlib1.dll $(TARGET_PREFIX)/$(PREFIX)/bin

libiconv: gcc
	mkdir -p $(LIBICONV_BUILD_DIR)
	(cd $(LIBICONV_BUILD_DIR) && RC='$(TARGET)-windres' $(LIBICONV_SRC_DIR)/configure -prefix=$(PREFIX) --host=$(HOST) --enable-extra-encodings --enable-static --enable-shared --disable-nls --with-gnu-ld)
	$(MAKE) -C $(LIBICONV_BUILD_DIR) install DESTDIR=$(TARGET_PREFIX)

