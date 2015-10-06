Nullsoft Installer JRE detect script
=====================================
 
## Intro ##

	Existing installer script for NSI don't seem to take into consideration 64-bit systems registry entries for JRE.
	I cleaned up some existing scripts and now they work on both MUI and MUI2.

## Files ##

* setup.nsi is generated with [Eclipse NSIS plugin](http://eclipsensis.sourceforge.net/index.shtml). It is based on MUI2 and uses the following files:
	* detectJRE.nsi
	* eclipse-license-1.0.txt
	* jre-8u60-windows-i586.exe
	* modern-install-colourful.ico
	* modern-uninstall-colourful.ico
* simple_jre.nsi is started from existing  ['Simple Installer with JRE check' on nsis sourceforge](http://nsis.sourceforge.net/Simple_installer_with_JRE_check), based on MUI with InstallOptions and uses the following files:
	* detectJRE.nsi
	* jre-8u60-windows-i586.exe
	* jre.ini


## Uninstalling ##

* 2-click the Uninstall.exe  