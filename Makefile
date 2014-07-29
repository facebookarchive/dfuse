#
# Copyright (c) 2014, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the Boost-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
VERSION=0.3.0
INTERNAL_VERSION=0003

product=libdfuse-$(VERSION)

PREFIX=/usr/local
DMD=dmd
DMDFLAGS=

sources = source/c/fuse/fuse.d source/c/fuse/common.d source/dfuse/fuse.d
uname := $(shell uname -s)

# Define variables and buildmodes depending on ENABLE_DEBUG, ENABLE_64BIT and
# operating system.
buildmode=release
ifeq ($(ENABLE_DEBUG),1)
	MODE=-debug -g
	buildmode=debug
else
	MODE=-release -O -inline
	buildmode=release
endif

bitmode=64
ifeq ($(uname),Darwin)
ifeq ($(ENABLE_64BIT),1)
	MODE+=-version=DARWIN_USE_64_BIT_INODE
	LIBS=-L-losxfuse
	bitmde=64
else
	LIBS=-L-losxfuse_i32
	bitmode=32
endif
endif

ifeq ($(uname),Linux)
	LIBS=-L-lfuse
	bitmode=64
endif

# Define build directories and main target for libs
builddir=build/$(buildmode)/$(bitmode)

ifeq ($(uname),Linux)
	artifact=$(builddir)/$(product).so
endif
ifeq ($(uname),Darwin)
	artifact=$(builddir)/$(product).dylib
endif

all:: dfuse

$(builddir):
	mkdir -p $(builddir)

$(builddir)/$(product).so: $(sources)
	$(DMD) -w $(MODE) -shared $(LIBS) -version=$(INTERNAL_VERSION) -of$@ $(sources)

$(builddir)/$(product).dylib: $(sources)
	$(DMD) -w $(MODE) -shared $(LIBS) -version=$(INTERNAL_VERSION) -of$@ $(sources)

simplefs: example/simplefs.d $(sources)
	$(DMD) -w -debug -g $(LIBS) -of$@ example/simplefs.d $(sources)

examples: simplefs

dfuse: $(artifact)

clean:
	@(rm simplefs 2>/dev/null || exit 0)
	@(rm -r $(artifact) || exit 0)
	@(rmdir -p build/ || exit 0)

.PHONY: dfuse all clean examples
