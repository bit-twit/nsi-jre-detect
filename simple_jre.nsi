; Credit given to so many people of the NSIS forum.
 
!include "MUI.nsh"
!include "Sections.nsh"
!include "detectJRE.nsi"
 
; define your own download path
!define JRE_URL "<path to a jre install>/jre.exe"
 
;--------------------------------
;Configuration
 
  ;General
  Name "JRE Test"
  OutFile "jretest.exe"
 
  ;Folder selection page
  InstallDir "$PROGRAMFILES\JRE Test"
 
  ;Get install folder from registry if available
  InstallDirRegKey HKLM "SOFTWARE\JRE Test" ""
 
;--------------------------------
;Pages
 
  Page custom CheckInstalledJRE
  !insertmacro MUI_PAGE_INSTFILES
  !define MUI_PAGE_CUSTOMFUNCTION_PRE myPreInstfiles
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE RestoreSections
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
 
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
 
;--------------------------------
;Modern UI Configuration
 
  !define MUI_ABORTWARNING
 
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"
 
;--------------------------------
;Language Strings
 
  ;Description
  LangString DESC_SecJRETest ${LANG_ENGLISH} "Application files copy"

;--------------------------------
;Reserve Files
 
  ;Only useful for BZIP2 compression
 
  ReserveFile "jre.ini"
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
 
;--------------------------------
;Installer Sections
 
Section -installjre jre
  DetailPrint "Starting the JRE installation"
  !ifdef WEB_INSTALL
    DetailPrint "Downloading the JRE setup"
    NSISdl::download /TIMEOUT=30000 ${JRE_URL} "$TEMP\jre_setup.exe"
    Pop $0 ;Get the return value
    StrCmp $0 "success" InstallJRE 0
    StrCmp $0 "cancel" 0 +3
    Push "Download cancelled."
    Goto ExitInstallJRE
    Push "Unkown error during download."
    Goto ExitInstallJRE
  !else
    File /oname=$TEMP\jre_setup.exe jre-8u60-windows-i586.exe
  !endif
InstallJRE:
  DetailPrint "Launching JRE setup"
  ExecWait "$TEMP\jre_setup.exe" $0
  DetailPrint "Setup finished"
  Delete "$TEMP\jre_setup.exe"
  StrCmp $0 "0" InstallVerif 0
  Push "The JRE setup has been abnormally interrupted."
  Goto ExitInstallJRE
 
InstallVerif:
  DetailPrint "Checking the JRE Setup's outcome"
  Call DetectJRE
  Pop $0
  StrCmp $0 "OK" JavaExeVerif 0
  Push "The JRE setup failed"
  Goto ExitInstallJRE
 
JavaExeVerif:
  Pop $1
  IfFileExists $1 JREPathStorage 0
  Push "The following file : $1, cannot be found."
  Goto ExitInstallJRE
 
JREPathStorage:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "jre.ini" \
"UserDefinedSection" "JREPath" $1
  Goto End
 
ExitInstallJRE:
  Pop $2
  MessageBox MB_OK "The setup is about to be interrupted for the following reason : $2"
  Quit

End:
SectionEnd
 
Section /o "Installation of JRE Test" SecJRETest
 
  SetOutPath $INSTDIR
;  File /r "*"
    File "readme.txt"
 
  !insertmacro MUI_INSTALLOPTIONS_READ $0 "jre.ini" "UserDefinedSection" "JREPath"
  ;Store install folder
  WriteRegStr HKLM "SOFTWARE\JRE Test" "" $INSTDIR
 
  WriteRegStr HKLM \
"Software\Microsoft\Windows\CurrentVersion\Uninstall\JRE Test" \
"DisplayName" "JRE Test"
  WriteRegStr HKLM \
"Software\Microsoft\Windows\CurrentVersion\Uninstall\JRE Test" \
"UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM \
"Software\Microsoft\Windows\CurrentVersion\Uninstall\JRE Test" \
"NoModify" "1"
  WriteRegDWORD HKLM \
"Software\Microsoft\Windows\CurrentVersion\Uninstall\JRE Test" \
"NoRepair" "1"
 
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
 
SectionEnd
 
Section /o "Start menu shortcuts" SecCreateShortcut
 
  CreateDirectory "$SMPROGRAMS\JRE Test"
  CreateShortCut "$SMPROGRAMS\JRE Test\Uninstall.lnk" \
"$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\JRE Test\JRE Test.lnk" \
"$INSTDIR\jretext.exe" "" "$INSTDIR\jretest.exe" 0
 
SectionEnd
 
;--------------------------------
;Descriptions
 
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecJRETest} $(DESC_SecJRETest)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Installer Functions
 
Function .onInit
 
  ;Extract InstallOptions INI Files
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "jre.ini"
  Call SetupSections
 
FunctionEnd
 
Function myPreInstfiles
 
  Call RestoreSections
  SetAutoClose true
 
FunctionEnd 
 
Function RestoreSections
  !insertmacro UnselectSection ${jre}
  !insertmacro SelectSection ${SecJRETest}
  !insertmacro SelectSection ${SecCreateShortcut}
 
FunctionEnd
 
Function SetupSections
  !insertmacro SelectSection ${jre}
  !insertmacro UnselectSection ${SecJRETest}
  !insertmacro UnselectSection ${SecCreateShortcut}
FunctionEnd
 
;--------------------------------
;Uninstaller Section
 
Section "Uninstall"
 
  ; remove registry keys
  DeleteRegKey HKLM \
"Software\Microsoft\Windows\CurrentVersion\Uninstall\JRE Test"
  DeleteRegKey HKLM  "SOFTWARE\JRE Test"
  ; remove shortcuts, if any.
  Delete "$SMPROGRAMS\JRE Test\*.*"
  ; remove files
  RMDir /r "$INSTDIR"
 
SectionEnd