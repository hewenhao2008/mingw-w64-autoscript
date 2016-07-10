
export GMP_NAME=gmp-6.1.1
export MPFR_NAME=mpfr-3.1.4
export MPC_NAME=mpc-1.0.3
export ISL_NAME=isl-0.17
export CLOOG_NAME=cloog-0.18.4
export BINUTILS_NAME=binutils-2.26
export GCC_NAME=gcc-6.1.0
export GDB_NAME=gdb-7.11
export LIBICONV_NAME=libiconv-1.14
export LIBTOOL_NAME=libtool-2.4.6
export M4_NAME=m4-1.4.17
export ZLIB_NAME=zlib-1.2.8
export MINGW_W64_NAME=mingw-w64-v4.0.6

export GMP_SRC_DIR=$(SRCDIR)/$(GMP_NAME)
export MPFR_SRC_DIR=$(SRCDIR)/$(MPFR_NAME)
export MPC_SRC_DIR=$(SRCDIR)/$(MPC_NAME)
export ISL_SRC_DIR=$(SRCDIR)/$(ISL_NAME)
export CLOOG_SRC_DIR=$(SRCDIR)/$(CLOOG_NAME)
export BINUTILS_SRC_DIR=$(SRCDIR)/$(BINUTILS_NAME)
export GCC_SRC_DIR=$(SRCDIR)/$(GCC_NAME)
export GDB_SRC_DIR=$(SRCDIR)/$(GDB_NAME)
export LIBICONV_SRC_DIR=$(SRCDIR)/$(LIBICONV_NAME)
export LIBTOOL_SRC_DIR=$(SRCDIR)/$(LIBTOOL_NAME)
export M4_SRC_DIR=$(SRCDIR)/$(M4_NAME)
export ZLIB_SRC_DIR=$(SRCDIR)/$(ZLIB_NAME)
export MINGW_W64_SRC_DIR=$(SRCDIR)/$(MINGW_W64_NAME)

export MINGW_W64_CRT_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-crt
export MINGW_W64_HEADERS_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-headers
export MINGW_W64_WINPTHREADS_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-libraries/winpthreads
export MINGW_W64_WINSTORECOMPAT_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-libraries/winstorecompat
export MINGW_W64_LIBMANGLE_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-libraries/libmangle
export MINGW_W64_GENPEIMG_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-tools/genpeimg
export MINGW_W64_GENDEF_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-tools/gendef
export MINGW_W64_GENIDL_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-tools/genidl
export MINGW_W64_WIDL_SRC_DIR=$(MINGW_W64_SRC_DIR)/mingw-w64-tools/widl
