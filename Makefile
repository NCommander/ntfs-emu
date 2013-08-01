include config.mk

SRC += ntfs-emu.c
OBJ = ${SRC:.c=.o}

all: clean options ntfs-emu

options:
	@echo ntfs-emu build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	@echo CC $<
	@${CC} -c ${CFLAGS} $<

${OBJ}: config.mk

ntfs-emu: ${OBJ}
	@echo CC -o $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

debug: clean
	@make CFLAGS='${DEBUG_CFLAGS}'

ascii: clean
	@make CFLAGS_UNICODE='' LDFLAGS_UNICODE=''

unicode-glib: clean
	@make CFLAGS_UNICODE='${CFLAGS_GLIB}' LDFLAGS_UNICODE='${LDFLAGS_GLIB}'

unicode-icu: clean
	@make CFLAGS_UNICODE='${CFLAGS_ICU}' LDFLAGS_UNICODE='${LDFLAGS_ICU}'

clean:
	@echo cleaning
	@rm -f ntfs-emu ${OBJ} ntfs-emu-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p ntfs-emu-${VERSION}
	@cp -R Makefile config.mk ntfs-emu.c ascii.c unicode-icu.c unicode-glib.c ntfs-emu-${VERSION}
	@tar -cf ntfs-emu-${VERSION}.tar ntfs-emu-${VERSION}
	@gzip ntfs-emu-${VERSION}.tar
	@rm -rf ntfs-emu-${VERSION}

install: ntfs-emu
	@echo stripping executable
	@strip -s ntfs-emu
	@echo installing executable file to ${DESTDIR}${PREFIX}/bin
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f ntfs-emu ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/ntfs-emu
	@echo creating symlink ${DESTDIR}/sbin/mount.ntfs-emu
	@mkdir -p ${DESTDIR}/sbin
	@ln -sf ${PREFIX}/bin/ntfs-emu ${DESTDIR}/sbin/mount.ntfs-emu
#	@echo installing manual page to ${DESTDIR}${MANPREFIX}/man1
#	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
#	@sed "s/VERSION/${VERSION}/g" < ntfs-emu.1 > ${DESTDIR}${MANPREFIX}/man1/ntfs-emu.1
#	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/ntfs-emu.1

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/ntfs-emu
	@echo removing symlink from ${DESTDIR}/sbin/mount.ntfs-emu
	@rm -f ${DESTDIR}/sbin/mount.ntfs-emu
#	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
#	@rm -f ${DESTDIR}${MANPREFIX}/man1/ntfs-emu.1

.PHONY: all options clean dist install uninstall debug ascii unicode-glib unicode-icu
