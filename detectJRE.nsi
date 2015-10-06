!define JRE_VERSION "1.8"

!define TEMP $R0
!define TEMP2 $R1
!define TEMP3 $R4
!define VAL1 $R2
!define VAL2 $R3

!define DOWNLOAD_JRE_FLAG $8

;--------------------------------
;Language Strings
 
  ;Header
  LangString TEXT_JRE_TITLE ${LANG_ENGLISH} "Java Runtime Environment"
  LangString TEXT_JRE_SUBTITLE ${LANG_ENGLISH} "Installation"
  LangString TEXT_PRODVER_TITLE ${LANG_ENGLISH} \
"Installed version of JRE Test"
  LangString TEXT_PRODVER_SUBTITLE ${LANG_ENGLISH} "Installation cancelled"

Function CheckInstalledJRE
  Call DetectJRE
  Pop ${TEMP}
  StrCmp ${TEMP} "OK" NoDownloadJRE
  Pop ${TEMP2}
  StrCmp ${TEMP2} "None" NoFound FoundOld
 
FoundOld:
 ; !insertmacro MUI_INSTALLOPTIONS_WRITE "jre.ini" "Field 1" "Text" "JRE Test requires a more recent version of the Java Runtime Environment \
than the one found on your computer. \
The installation of JRE \
${JRE_VERSION} will start."
  !insertmacro MUI_HEADER_TEXT "$(TEXT_JRE_TITLE)" "$(TEXT_JRE_SUBTITLE)"
  ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "jre.ini"
  Goto DownloadJRE
 
NoFound:
  ;!insertmacro MUI_INSTALLOPTIONS_WRITE "jre.ini" "Field 1" "Text" "No Java Runtime Environment could be found on your computer \
The installation of JRE v${JRE_VERSION} will start."
  !insertmacro MUI_HEADER_TEXT "$(TEXT_JRE_TITLE)" "$(TEXT_JRE_SUBTITLE)"
  ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "jre.ini"
  Goto DownloadJRE
 
DownloadJRE:
  StrCpy ${DOWNLOAD_JRE_FLAG} "Download"
  Return
 
NoDownloadJRE:
  Pop ${TEMP2}
  StrCpy ${DOWNLOAD_JRE_FLAG} "NoDownload"
  ;!insertmacro MUI_INSTALLOPTIONS_WRITE "jre.ini" \
"UserDefinedSection" "JREPath" \
${TEMP2}
  Return
 
ExitInstall:
  Quit
 
FunctionEnd
 
 
Function DetectJRE
  ReadRegStr ${TEMP2} HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
  ;MessageBox MB_OK "Detect 32 : [ ${TEMP2} ]"
  DetailPrint "Detect 32 : [ ${TEMP2} ]"
  StrCmp ${TEMP2} "" DetectTryJDK32
  ReadRegStr ${TEMP3} HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\${TEMP2}" "JavaHome"
  StrCmp ${TEMP3} "" DetectTryJDK32
  Goto GetJRE

DetectTryJDK32:
  ReadRegStr ${TEMP2} HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
  StrCmp ${TEMP2} "" DetectJRE64
  ReadRegStr ${TEMP3} HKLM "SOFTWARE\JavaSoft\Java Development Kit\${TEMP2}" "JavaHome"
  StrCmp ${TEMP3} "" DetectJRE64
  Goto GetJRE

DetectJRE64:
  ReadRegStr ${TEMP2} HKLM "SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment" "CurrentVersion"
  ;MessageBox MB_OK "Detect JRE"
  DetailPrint "Detect JRE"
  StrCmp ${TEMP2} "" DetectTryJDK64
  ReadRegStr ${TEMP3} HKLM "SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment\${TEMP2}" "JavaHome"
  StrCmp ${TEMP3} "" DetectTryJDK64
  Goto GetJRE
 
DetectTryJDK64:
  ReadRegStr ${TEMP2} HKLM "SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit" "CurrentVersion"
  StrCmp ${TEMP2} "" NoFound
  ReadRegStr ${TEMP3} HKLM "SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit\${TEMP2}" "JavaHome"
  StrCmp ${TEMP3} "" NoFound
 
GetJRE:
  ;MessageBox MB_OK "Found JRE path : ${TEMP3}"
  DetailPrint "Found JRE path : ${TEMP3}"
  IfFileExists "${TEMP3}\bin\java.exe" 0 NoFound
  ;MessageBox MB_OK "${VAL1}"
  DetailPrint "${VAL1}"
  StrCpy ${VAL1} ${TEMP2} 1
  StrCpy ${VAL2} ${JRE_VERSION} 1
  IntCmp ${VAL1} ${VAL2} 0 FoundOld FoundNew
  StrCpy ${VAL1} ${TEMP2} 1 2
  StrCpy ${VAL2} ${JRE_VERSION} 1 2
  IntCmp ${VAL1} ${VAL2} FoundNew FoundOld FoundNew
 
NoFound:
  Push "None"
  Push "NOK"
  Return
 
FoundOld:
  Push ${TEMP2}
  Push "NOK"
  Return
 
FoundNew:
  Push "${TEMP3}\bin\java.exe"
  Push "OK"
  Return
 
FunctionEnd
