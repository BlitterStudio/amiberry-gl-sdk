# SPDX-FileCopyrightText: 2026 Dimitris Panokostas
# SPDX-License-Identifier: MIT
# Builds the import libraries into lib/ with m68k-amigaos-gcc.
CC := m68k-amigaos-gcc
AR := m68k-amigaos-ar
OBJDIR := obj
BASE_CFLAGS := -m68020 -m68881 -O2 -fno-strict-aliasing -noixemul -std=c99 -Wall -Wextra

MINIGL_CFLAGS := $(BASE_CFLAGS) -fsigned-char -Iminigl/include -DMINIGL_DISPATCH_ABI_TYPES
OGLES_CFLAGS := $(BASE_CFLAGS) -fno-builtin -Iogles/include \
	-Iogles/ogles2-interface/include -Iogles/ogles3-interface/include

MINIGL_OBJS := $(OBJDIR)/minigl/minigl_base.o $(OBJDIR)/minigl/minigl_open.o \
	$(OBJDIR)/minigl/minigl_dispatch_stub_gcc.o
ogles_objs = $(patsubst ogles/client/%.c,$(OBJDIR)/ogles/%.o,$(wildcard ogles/client/ogles$(1)/*.c)) \
	$(patsubst ogles/client/%.s,$(OBJDIR)/ogles/%.o,$(wildcard ogles/client/ogles$(1)/*.s))

LIBS := lib/libminigl_dispatch.a lib/libogles2.a lib/libogles3.a

.PHONY: all clean
all: $(LIBS)

$(OBJDIR)/minigl/%.o: minigl/client/%.c
	mkdir -p $(dir $@)
	$(CC) $(MINIGL_CFLAGS) -c $< -o $@
$(OBJDIR)/minigl/%.o: minigl/client/%.s
	mkdir -p $(dir $@)
	$(CC) -m68020 -c $< -o $@
$(OBJDIR)/ogles/%.o: ogles/client/%.c
	mkdir -p $(dir $@)
	$(CC) $(OGLES_CFLAGS) -c $< -o $@
$(OBJDIR)/ogles/%.o: ogles/client/%.s
	mkdir -p $(dir $@)
	$(CC) -m68020 -c $< -o $@

lib/libminigl_dispatch.a: $(MINIGL_OBJS)
	mkdir -p lib
	rm -f $@
	$(AR) rcs $@ $^
lib/libogles2.a: $(call ogles_objs,2)
	mkdir -p lib
	rm -f $@
	$(AR) rcs $@ $^
lib/libogles3.a: $(call ogles_objs,3)
	mkdir -p lib
	rm -f $@
	$(AR) rcs $@ $^

clean:
	rm -rf $(OBJDIR) lib
