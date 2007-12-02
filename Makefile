PREFIX=/usr/local
DEVICE=/dev/ttyS0

CC=gcc
CFLAGS=-O2 -Wall -Wno-unused -DDEVICE=\"$(DEVICE)\"
INSTALL=install
RAGEL=ragel
RLGEN=rlgen-cd
RLGENFLAGS=-G2

RAGELS=igc_tm.rl manufacturer.rl pbrsnp.rl pbrtl.rl set.rl
RAGEL_SRCS=$(RAGELS:%.rl=%.c)
SRCS=tini.c flytec.c $(RAGEL_SRCS)
HEADERS=tini.h
OBJS=$(SRCS:%.c=%.o)
BINS=tini
DOCS=README COPYING

.PHONY: all clean setgidinstall install reallyclean tarball
.PRECIOUS: $(RAGEL_SRCS)

all: $(BINS)

tarball: $(RAGEL_SRCS)
	mkdir tini-$(VERSION)
	cp Makefile $(SRCS) $(HEADERS) $(RAGELS) $(DOCS) tini-$(VERSION)
	tar -czf tini-$(VERSION).tar.gz tini-$(VERSION)
	rm -Rf tini-$(VERSION)

setgidinstall: install
	@echo "  CHGRP   tini"
	@chgrp --reference=$(DEVICE) $(PREFIX)/bin/tini
	@echo "  CHMOD   tini"
	@chmod g+s $(PREFIX)/bin/tini

install: $(BINS)
	@echo "  INSTALL tini"
	@mkdir -p $(PREFIX)/bin
	@cp tini $(PREFIX)/bin/tini

tini: $(OBJS)

reallyclean: clean
	@echo "  CLEAN   $(RAGEL_SRCS)"
	@rm -f $(RAGEL_SRCS)

clean:
	@echo "  CLEAN   $(BINS) $(OBJS)"
	@rm -f $(BINS) $(OBJS)

%.c: %.rl
	@echo "  RAGEL   $<"
	@$(RAGEL) $< | $(RLGEN) -o $@ $(RLGENFLAGS)

%.o: %.c $(HEADERS)
	@echo "  CC      $<"
	@$(CC) -c -o $@ $(CFLAGS) $<

%: %.o
	@echo "  LD      $<"
	@$(CC) -o $@ $(CFLAGS) $^
