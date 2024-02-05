CC=clang
#CFLAGS=-g
CFLAGS=-O3
SRCDIR=source
INSTALLDIR=/usr/local
INCLUDEDIR=$(INSTALLDIR)/include/armadillo
LIBDIR=$(INSTALLDIR)/lib
PKGCONFIGDIR=$(INSTALLDIR)/lib/pkgconfig
PKGCONFIGFILE=$(INSTALLDIR)/lib/pkgconfig/armadillo.pc

SOURCE_FILES = $(SRCDIR)/armadillo.c \
			   $(SRCDIR)/bits.c \
			   $(SRCDIR)/DataProcessingImmediate.c \
			   $(SRCDIR)/BranchExcSys.c \
			   $(SRCDIR)/LoadsAndStores.c \
			   $(SRCDIR)/DataProcessingRegister.c \
			   $(SRCDIR)/DataProcessingFloatingPoint.c \
			   $(SRCDIR)/instruction.c \
			   $(SRCDIR)/strext.c \
			   $(SRCDIR)/utils.c

OBJECT_FILES = $(SRCDIR)/armadillo.o \
			   $(SRCDIR)/bits.o \
			   $(SRCDIR)/DataProcessingImmediate.o \
			   $(SRCDIR)/BranchExcSys.o \
			   $(SRCDIR)/LoadsAndStores.o \
			   $(SRCDIR)/DataProcessingRegister.o \
			   $(SRCDIR)/DataProcessingFloatingPoint.o \
			   $(SRCDIR)/instruction.o \
			   $(SRCDIR)/strext.o \
			   $(SRCDIR)/utils.o

armadillo : $(OBJECT_FILES)
	$(CC) $(CFLAGS) -dynamiclib -o libarmadillo.dylib $(OBJECT_FILES)

install_static: armadillo_static
	rm -rf $(INCLUDEDIR)
	mkdir -p $(INCLUDEDIR)
	cp $(SRCDIR)/{armadillo,adefs}.h $(INCLUDEDIR)
	mv libarmadillo.a $(LIBDIR)
	mkdir -p $(PKGCONFIGDIR)
	@echo 'prefix=/usr/local' > $(PKGCONFIGFILE)
	@echo 'includedir=$${prefix}/include' >> $(PKGCONFIGFILE)
	@echo 'libdir=$${prefix}/lib' >> $(PKGCONFIGFILE)
	@echo '' >> $(PKGCONFIGFILE)
	@echo 'Name: armadillo' >> $(PKGCONFIGFILE)
	@echo 'Description: armadillo - a disassembler library for ARM64' >> $(PKGCONFIGFILE)
	@echo 'Version: 1.0.0' >> $(PKGCONFIGFILE)
	@echo 'Cflags: -I$${includedir}/armadillo' >> $(PKGCONFIGFILE)
	@echo 'Libs: -L$${libdir} -larmadillo' >> $(PKGCONFIGFILE)

armadillo_static: $(OBJECT_FILES)
	libtool -static -o libarmadillo.a $(OBJECT_FILES)

driver85 : $(OBJECT_FILES) driver85.c linkedlist.c
	$(MAKE) armadillo
	$(CC) $(CFLAGS) -L. -larmadillo linkedlist.c driver85.c -o driver85

asmtestcases : asmtests
	llvm-mc -triple=aarch64 -mattr=+mte,+pa,+lse,+rcpc-immo,+crc,+fmi,+fullfp16,+rdm,+dotprod,+complxnum,+fp16fml,+aes,+sm4,+sha3 \
		--show-encoding --print-imm-hex -assemble < asmtests | perl asmtestgen > tests.txt

$(SRCDIR)/%.o : $(SRCDIR)/%.c $(SRCDIR)/%.h
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean :
	rm -f libarmadillo.dylib libarmadillo.a $(OBJECT_FILES)
