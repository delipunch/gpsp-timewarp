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

CFLAGS := $(SDL_CFLAGS) $(INCLUDE) -Wall -Ofast -fomit-frame-pointer -DZAURUS -mplt -mips32 -fdata-sections -ffunction-sections
CFLAGS += -mno-relax-pic-calls -mlong32 -mlocal-sdata -mframe-header-opt -mno-check-zero-division -mfp32 -mgp32 -mno-embedded-data -fno-pic -mno-interlink-compressed -mno-mt -mno-micromips -mno-interlink-mips16
CFLAGS += -fdata-sections -ffunction-sections -fno-threadsafe-statics  -fno-math-errno -funsafe-math-optimizations -fassociative-math -ffinite-math-only -fsingle-precision-constant -fsection-anchors -falign-functions=2 -mno-check-zero-division
# CFLAGS += -fprofile-use
# CFLAGS      += -ggdb -O0
ASFLAGS := $(CFLAGS)
# LDFLAGS := $(SDL_LIBS) -lpthread -lz -lm
LDFLAGS := $(SDL_LIBS) -lpthread -lz -lm -Wl,--as-needed -Wl,--gc-sections -flto -s
# LDFLAGS      += -ggdb -O0

.PHONY: all $(TARGET) clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

ipk: $(TARGET)
	@rm -rf /tmp/.gpsp-ipk/ && mkdir -p /tmp/.gpsp-ipk/root/home/retrofw/emus/gpsp /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators.systems
	@cp gpsp/gpsp.dge gpsp/game_config.txt gpsp/gpsp.png /tmp/.gpsp-ipk/root/home/retrofw/emus/gpsp
	@cp gpsp/gpsp.lnk /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators
	@cp gpsp/gba.gpsp.lnk /tmp/.gpsp-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators.systems
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" gpsp/control > /tmp/.gpsp-ipk/control
	@cp gpsp/conffiles gpsp/postinst /tmp/.gpsp-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.gpsp-ipk/control.tar.gz -C /tmp/.gpsp-ipk/ control conffiles postinst
	@tar --owner=0 --group=0 -czvf /tmp/.gpsp-ipk/data.tar.gz -C /tmp/.gpsp-ipk/root/ .
	@echo 2.0 > /tmp/.gpsp-ipk/debian-binary
	@ar r gpsp/gpsp.ipk /tmp/.gpsp-ipk/control.tar.gz /tmp/.gpsp-ipk/data.tar.gz /tmp/.gpsp-ipk/debian-binary

clean:
	rm -f $(TARGET) $(OBJS)
