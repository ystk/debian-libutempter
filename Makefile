#
# Copyright (C) 2001-2005  Dmitry V. Levin <ldv@altlinux.org>
#
# Makefile for the libutempter project.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

PROJECT = utempter
VERSION = $(shell sed '/^Version: */!d;s///;q' libutempter.spec)
MAJOR = 0

SHAREDLIB = lib$(PROJECT).so
SONAME = $(SHAREDLIB).$(MAJOR)
STATICLIB = lib$(PROJECT).a
MAP = lib$(PROJECT).map

TARGETS = $(PROJECT) $(SHAREDLIB) $(STATICLIB)

INSTALL = install
libdir = /usr/lib
libexecdir = /usr/lib
includedir = /usr/include
DESTDIR =

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 $(WARNINGS) -DLIBEXECDIR=\"$(libexecdir)\"
CFLAGS = $(RPM_OPT_FLAGS)
LDLIBS =

all: $(TARGETS)

%.os: %.c
	$(COMPILE.c) -fPIC $< $(OUTPUT_OPTION)

$(PROJECT): utempter.c
	$(LINK.c) -Wl,-z,now,-stats $(LDLIBS) $< $(OUTPUT_OPTION)

$(SHAREDLIB): iface.os $(MAP)
	$(LINK.o) -shared \
		-Wl,-soname,$(SONAME),--version-script=$(MAP),-z,defs,-stats \
		-lc $< $(OUTPUT_OPTION)

$(STATICLIB): iface.o
	$(AR) $(ARFLAGS) $@ $<
	-ranlib $@

iface.o: iface.c utempter.h

install:
	mkdir -p $(DESTDIR)$(libexecdir)/$(PROJECT) $(DESTDIR)$(includedir) \
		$(DESTDIR)$(libdir)
	$(INSTALL) -p -m2711 $(PROJECT) $(DESTDIR)$(libexecdir)/$(PROJECT)/
	$(INSTALL) -p -m644 $(PROJECT).h $(DESTDIR)$(includedir)/
	$(INSTALL) -p -m755 $(SHAREDLIB) $(DESTDIR)$(libdir)/$(SHAREDLIB).$(VERSION)
	$(INSTALL) -p -m644 $(STATICLIB) $(DESTDIR)$(libdir)/
	ln -s $(SHAREDLIB).$(VERSION) $(DESTDIR)$(libdir)/$(SONAME)
	ln -s $(SONAME) $(DESTDIR)$(libdir)/$(SHAREDLIB)

clean:
	$(RM) $(TARGETS) iface.o iface.os core *~
