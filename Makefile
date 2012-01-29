# Preliminary makefile for Awesome-Menu
aw-main: aw-main.vala
	valac-0.14 --pkg=gtk+-3.0 --pkg=gio-2.0 aw-main.vala

clean:
	-rm -f aw-main
