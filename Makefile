TARGET := gpsp/gpsp.dge

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC          := $(CROSS_COMPILE)gcc
STRIP       := $(CROSS_COMPILE)strip

SYSROOT     := $(shell $(CC) --print-sysroot)
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

OBJS := main.o cpu.o memory.o video.o input.o sound.o gui.o \
	cheats.o zip.o cpu_threaded.o mips_stub.o

INCLUDE     := -I. -I$(CHAINPREFIX)/usr/include/ -I$(SYSROOT)/usr/include/  -I$(SYSROOT)/usr/include/SDL/

CFLAGS := $(SDL_CFLAGS) $(INCLUDE) -Wall -fomit-frame-pointer -DZAURUS
CFLAGS      += -ggdb -O0
ASFLAGS := $(CFLAGS)
LDFLAGS := $(SDL_LIBS) -lpthread -lz -lm
LDFLAGS      += -ggdb -O0

.PHONY: all $(TARGET) clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

ipk: $(TARGET)
	@rm -rf /tmp/.gpsp-ipk/ && mkdir -p /tmp/.gpsp-ipk/root/home/retrofw/emus/gpsp /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/systems
	@cp gpsp/gpsp.dge gpsp/game_config.txt gpsp/gpsp.png /tmp/.gpsp-ipk/root/home/retrofw/emus/gpsp
	@cp gpsp/gpsp.lnk /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators
	@cp gpsp/gba.gpsp.lnk /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/systems
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" gpsp/control > /tmp/.gpsp-ipk/control
	@tar --owner=0 --group=0 -czvf /tmp/.gpsp-ipk/control.tar.gz -C /tmp/.gpsp-ipk/ control
	@tar --owner=0 --group=0 -czvf /tmp/.gpsp-ipk/data.tar.gz -C /tmp/.gpsp-ipk/root/ .
	@echo 2.0 > /tmp/.gpsp-ipk/debian-binary
	@ar r gpsp/gpsp.ipk /tmp/.gpsp-ipk/control.tar.gz /tmp/.gpsp-ipk/data.tar.gz /tmp/.gpsp-ipk/debian-binary

clean:
	rm -f $(TARGET) $(OBJS)
