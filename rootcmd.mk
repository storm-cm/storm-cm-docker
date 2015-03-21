ifeq ($(UID),0)
	ROOTCMD :=
else
	ROOTCMD := sudo
endif
