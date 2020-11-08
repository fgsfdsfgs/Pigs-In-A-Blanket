LIB  	= pib
OBJS    = src/main.o src/hooks.o src/shacccgpatch.o src/patches.o src/sha1.o
INCLUDE = include

PREFIX  ?= ${VITASDK}/arm-vita-eabi
CC      = arm-vita-eabi-gcc
AR      = arm-vita-eabi-ar
CFLAGS  = -Wl,-q -Wall -Wno-incompatible-pointer-types -Wno-pointer-sign -O3 -nostartfiles -nostdlib -DVITA -D__vita__
ASFLAGS = $(CFLAGS)

all: stub lib

debug: CFLAGS += -DDEBUG
debug: stub lib

stub: piglet_stub/out/liblibScePiglet_stub.a

piglet_stub/out/liblibScePiglet_stub.a:
	$(MAKE) -C piglet_stub

lib: lib$(LIB).a

%.a: $(OBJS) 
	$(AR) -rc $@ $^

clean:
	@rm -rf combine $(OBJS) lib$(LIB).a
	@$(MAKE) -C piglet_stub clean

install: lib$(LIB).a
	@mkdir -p $(DESTDIR)$(PREFIX)/include/
	@cp include/pib.h $(DESTDIR)$(PREFIX)/include/
	@cp -r include/EGL $(DESTDIR)$(PREFIX)/include/
	@cp -r include/GLES2 $(DESTDIR)$(PREFIX)/include/
	@cp -r include/KHR $(DESTDIR)$(PREFIX)/include/
	@mkdir -p combine
	@cp $(PREFIX)/lib/liblibScePiglet_stub.a combine
	@cp $(PREFIX)/lib/libSceShaccCg_stub.a combine
	@cp $(PREFIX)/lib/libtaihen_stub.a combine
	@cp libpib.a combine
	@cd combine && $(AR) -x liblibScePiglet_stub.a
	@cd combine && $(AR) -x libSceShaccCg_stub.a
	@cd combine && $(AR) -x libtaihen_stub.a
	@cd combine && $(AR) -x libpib.a
	@cd combine && $(AR) -qc ../libpib.a *.o
	@mkdir -p $(DESTDIR)$(PREFIX)/lib/
	@cp lib$(LIB).a $(DESTDIR)$(PREFIX)/lib/
	@echo Installed PIB!

.PHONY: install clean
