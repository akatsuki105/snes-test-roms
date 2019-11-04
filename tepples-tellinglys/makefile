#!/usr/bin/make -f
#
# Makefile for Telling LYs
# Copyright 2011-2019 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#

# These are used in the title of the Super NES program and the zip file.
title = tellinglys
version = 0.01

# Space-separated list of assembly language files that make up the
# PRG ROM.  If it gets too long for one line, you can add a backslash
# (the \ character) at the end of the line and continue on the next.
objlist = \
  snesheader telling init main ppuclear unpb16


AS65 = ca65
LD65 = ld65
CFLAGS65 = -g
objdir = obj/snes
srcdir = src
imgdir = tilesets


EMU := bsnes
DEBUGEMU := Mesen-S
# other options for EMU are start (Windows) or xdg-open (*n?x)

# Occasionally, you need to make "build tools", or programs that run
# on a PC that convert, compress, or otherwise translate PC data
# files into the format that the Super NES program expects.  Some
# write build tools in C or C++; others prefer to write them in
# Perl, PHP, or Python.  This program doesn't use any C build tools,
# but if yours does, it might include definitions of variables that
# Make uses to call a C compiler.
CC = gcc
CFLAGS = -std=gnu99 -Wall -DNDEBUG -O

# Windows needs .exe suffixed to the names of executables; UNIX does
# not.  COMSPEC will be set to the name of the shell on Windows and
# not defined on UNIX.  Also the Windows Python installer puts
# py.exe in the path, but not python3.exe, which confuses MSYS Make.
ifdef COMSPEC
DOTEXE:=.exe
PY:=py -3
else
DOTEXE:=
PY:=python3
endif

.PHONY: run debug all dist zip clean

run: $(title).sfc
	$(EMU) $<
debug: $(title).sfc
	$(DEBUGEMU) $<

all: $(title).sfc

# Packaging
dist: zip
zip: $(title)-$(version).zip

# The zipfile depends on every file in zip.in, but as a shortcut,
# mention only files on which the ROM doesn't itself depend.
$(title)-$(version).zip: zip.in $(title).sfc README.md CHANGES.txt $(objdir)/index.txt
	$(PY) tools/zipup.py $< $(title)-$(version) -o $@
	-advzip -z3 $@

# Build zip.in from the list of files in the Git tree
# Enable if actually using Git
#zip.in:
#	git ls-files | grep -e "^[^.]" > $@
#	echo zip.in >> $@

$(objdir)/index.txt: makefile
	echo Files produced by build tools go here > $@

clean:
	-rm $(objdir)/*.o $(objdir)/*.s $(objdir)/*.chr $(objdir)/*.nam
	-rm $(objdir)/*.pb16

# Rules for PRG ROM

objlistntsc = $(foreach o,$(objlist),$(objdir)/$(o).o)

map.txt $(title).sfc: lorom256k.cfg $(objlistntsc)
	$(LD65) -o $(title).sfc --dbgfile $(title).dbg -m map.txt -C $^

$(objdir)/%.o: $(srcdir)/%.s $(srcdir)/snes.inc $(srcdir)/global.inc
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

# Files that depend on .incbin'd files
$(objdir)/main.o: \
  $(objdir)/text.u.chr.pb16 $(objdir)/text.nam.pb16 \
  $(objdir)/convo.u.chr.pb16 $(objdir)/convo.nam.pb16 \
  $(objdir)/pass.u.chr.pb16 $(objdir)/pass.nam.pb16

# Rules for CHR ROM

$(objdir)/%.chr: $(imgdir)/%.png
	$(PY) tools/pilbmp2nes.py --planes "0,1" $< $@

$(objdir)/%16.chr: $(imgdir)/%.png
	$(PY) tools/pilbmp2nes.py --planes "0,1" -H 16 $< $@

$(objdir)/%.u.chr: $(objdir)/%.chr
	$(PY) tools/uniq.py $< $@ $(<:.chr=.nam)

# workaround for Make's multi-output parallelism failure
$(objdir)/%.nam: $(objdir)/%.u.chr
	touch $@

%.pb16: tools/pb16.py %
	$(PY) $^ $@
