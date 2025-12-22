.PHONY: install uninstall

install:
	sudo install -v -m 755 ./99duress/* -Dt /lib/dracut/modules.d/99duress
	sudo install -v -m 755 ./create-cryptsetup-duress-signal -t /usr/bin/

uninstall:
	sudo rm -rf /lib/dracut/modules.d/99duress /usr/bin/create-cryptsetup-duress-signal /etc/dracut-cryptsetup-duress-signals
