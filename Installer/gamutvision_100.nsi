; This script installs Gamutvision
;--------------------------------

!define VER_DISPLAY     "1.3.4"  ; Must be the same as handles.version in gamutvision.m.
!define SOURCE          "..\gamutvision\installation\"
!define MATLAB          "..\Matlab\"
!define MATLAB_LIBS_PATH "toolbox\matlab\iofun\private\"
!define MATLAB_LIBS_URL  "http://www.imatest.com/packages/Imatest-lib.exe"
!define MATLAB_BIN_WIN32 "bin\win32\"
; !define BETA_PASSWORD   "unobtainium"

;--------------------------------
; Header Files

   !include "setpath.nsh"                     ; Path Set Library
   !include "MUI.nsh"                         ; Modern User Interface from "nsis\Contrib\Modern UI"
   !include "Sections.nsh"                    ; Defines macros for section control

;--------------------------------
; Configuration

   Name                 "Gamutvision"
   Caption              "Gamutvision ${VER_DISPLAY} Setup"
   OutFile              "..\packages\Gamutvision-${VER_DISPLAY}.exe"    ; Output File
   SetCompressor        lzma                                         ; Compression
   !insertmacro         MUI_RESERVEFILE_INSTALLOPTIONS               ; Reserve beta password ini
;    ReserveFile          "betaPassword.ini"

;--------------------------------
; Parameters

   SetDateSave          on
   SetDatablockOptimize on
   ShowInstDetails      show
   CRCCheck             on
   SilentInstall        normal
   AutoCloseWindow      false

;--------------------------------
; Destination

   InstallDir "$PROGRAMFILES\Gamutvision"
   InstallDirRegKey HKLM "Software\Gamutvision" ""

;--------------------------------
; Interface Settings

   !define MUI_ABORTWARNING
   !define MUI_WELCOMEFINISHPAGE_BITMAP "..\images\Gamutvision_welcome.bmp"       ; Welcome image
   !define MUI_HEADERIMAGE
   !define MUI_HEADERIMAGE_BITMAP       "..\images\Gamutvision150x57.bmp"             ; Header Image

   XPStyle on
   Icon        "Icons\nsis1-install.ico"                                          ; Installer Icon
   CheckBitmap "icons\classic-cross.bmp"                                          ; checkbox images
   UninstallText "This will uninstall Gamutvision. Hit next to continue."
   UninstallIcon "Icons\nsis1-uninstall.ico"

;--------------------------------
; Installer Pages

   !define MUI_WELCOMEPAGE_TITLE "Welcome to the Gamutvision ${VER_DISPLAY} Setup Wizard"
   !define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of Gamutvision ${VER_DISPLAY}.\r\n\nThere is no need to uninstall your previous version: you should be able to install the new version over the old one.\r\n\nIf a previous version of Gamutvision is running, Exit now.\r\n\nThis installation uses the Nullsoft NSIS 2 installer/uninstaller, available from http://nsis.sourceforge.net/.\r\n\n$_CLICK"
   !define MUI_COMPONENTSPAGE_SMALLDESC

   !insertmacro MUI_PAGE_WELCOME                                    ; Welcome
   !insertmacro MUI_PAGE_LICENSE "${SOURCE}license.txt"             ; License
   ; Page custom betaPassword checkBetaPassword                       ; Beta Password

   !insertmacro MUI_PAGE_COMPONENTS                                 ; Components Selection
   !insertmacro MUI_PAGE_DIRECTORY                                  ; Directory Selection
   !insertmacro MUI_PAGE_INSTFILES                                  ; Complete Install

   ; Finish
   !define MUI_FINISHPAGE_LINK "Visit www.gamutvision.com for the latest news and support"
   !define MUI_FINISHPAGE_LINK_LOCATION "http://www.gamutvision.com/"
;   !define MUI_FINISHPAGE_RUN "$INSTDIR\Gamutvision.exe"  ; This works. .lnk (Shortcut) files don't.
;   !define MUI_FINISHPAGE_RUN "call $INSTDIR\Gamutvision.lnk"  ; Start, call fail.
;   !define MUI_FINISHPAGE_RUN "$INSTDIR\gamutstart.bat"  ; Works! But DOS window is visible.
   !define MUI_FINISHPAGE_NOREBOOTSUPPORT
   !insertmacro MUI_PAGE_FINISH

   ; Uninstaller
   !insertmacro MUI_UNPAGE_CONFIRM
   !insertmacro MUI_UNPAGE_COMPONENTS
   !insertmacro MUI_UNPAGE_INSTFILES

   !insertmacro MUI_LANGUAGE "English"                           ; Language(s)

;--------------------------------
; Beta Password Functions

;   Function .onInit
;      !insertmacro MUI_INSTALLOPTIONS_EXTRACT "betaPassword.ini"
;   FunctionEnd

;   Function betaPassword
;      !insertmacro MUI_HEADER_TEXT "Beta Password" "please enter beta password"
;      !insertmacro MUI_INSTALLOPTIONS_DISPLAY "betaPassword.ini"
;   FunctionEnd

;   Function checkBetaPassword
;      !insertmacro MUI_PAGE_FUNCTION_CUSTOM LEAVE
;      ReadIniStr $0 "$PLUGINSDIR\betaPassword.ini" "Field 2" "State"
;      strcmp "${BETA_PASSWORD}" "$0" done
;      MessageBox MB_ICONEXCLAMATION|MB_OK "Beta Password Invalid... Please try again"
;      abort
;   done:
;   FunctionEnd

;--------------------------------
;  Install Types  (currently disabled)

   !define NOINSTTYPES
   !ifndef NOINSTTYPES ; only if not defined
      InstType "Most"
      InstType "Full"
      InstType "More"
      InstType "Base"
   !endif

;##############################################################################
;############# Installer Sections #############################################
;##############################################################################

;--------------------------------
; Main Section

Section "" ;  
  ; Write Install Dir to Registry
  WriteRegStr HKLM SOFTWARE\Gamutvision "Install_Dir" "$INSTDIR"

  ; Add / Remove program registry key
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Gamutvision" "DisplayName" "Gamutvision ${VER_DISPLAY}"
  
  ; Register path to uninstaller
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Gamutvision" "UninstallString" '"$INSTDIR\uninstall.exe"'
SectionEnd

;--------------------------------
; Gamutvision Section

Section "Gamutvision (required)" SecCore

  SetDetailsPrint textonly
  DetailPrint "Installing Gamutvision Core Files..."
  SetDetailsPrint listonly

  SectionIn RO
  SetOutPath $INSTDIR
  WriteUninstaller "uninstall.exe"

  SetOverwrite on
  file ${SOURCE}gamutvision.exe
  file ${SOURCE}Gamutvision_icon_32.ico  ; Added by Norman 7/3/2004.
  file ${SOURCE}icctrans.dll  ; Added by Norman 2/18/2006.
  ; file ${SOURCE}documentation.url
  ; file ${SOURCE}jhead.exe
  file ${SOURCE}CmdDumpProfile.exe
  file ${SOURCE}md5.exe
  file ${SOURCE}License.txt
  ; file /r ${SOURCEIM}Imatest_ital_logo_66W.png
  file /r ${SOURCE}images
  ; file /r ${SOURCE}samples

  ; Create a batch file to start Gamutvision. Added by N. Koren  8/9/2004
  ; For " in a string you can either use \$"  a different type of quote such as ` or '.
  FileOpen  $2 gamutstart.bat "w"
  FileWrite $2 '@cd "$INSTDIR"$\r$\n'
  FileWrite $2 '@path="$INSTDIR;$INSTDIR\bin\win32;$INSTDIR\toolbox\matlab;%path%"$\r$\n'
  FileWrite $2 "@title Gamutvision DOS window$\r$\n"
  FileWrite $2 '@cls\r$\n'
  FileWrite $2 "@echo Loading Gamutvision...$\r$\n"
  FileWrite $2 "gamutvision.exe$\r$\n"
  FileClose $2

  ; Create a batch file for Gamutvision diagnostics. Added by N. Koren  8/9/2004
  FileOpen  $2 diagnostics.bat "w"
  FileWrite $2 '@cd "$INSTDIR"$\r$\n'
  FileWrite $2 'path="$INSTDIR;$INSTDIR\bin\win32;$INSTDIR\toolbox\matlab;%path%"$\r$\n'
  FileWrite $2 "title Gamutvision Diagnostics DOS window$\r$\n"
  FileWrite $2 "echo Loading Gamutvision...$\r$\n"
  FileWrite $2 "gamutvision.exe$\r$\n"
  FileWrite $2 "%SystemRoot%\system32\cmd.exe$\r$\n"
  FileClose $2

  ; Registration and Status dlls
  file ${MATLAB}register.dll
  file ${MATLAB}status.dll

  ; Copy Link file only if it doesn't exist
  IfFileExists    "$INSTDIR\Gamutvision.lnk"   sc1    ; NLK 07/18/04.
  CreateShortCut  "$INSTDIR\Gamutvision.lnk" "$INSTDIR\gamutstart.bat" "" "$INSTDIR\Gamutvision_icon_32.ico" 0 "SW_SHOWMINIMIZED"

sc1:
  CreateShortCut  "$INSTDIR\Diagnostics.lnk" "$INSTDIR\diagnostics.bat" "" "$INSTDIR\Gamutvision_icon_32.ico" 0 "SW_SHOWNORMAL"


  SetOutPath "$INSTDIR\bin"
  file ${SOURCE}bin\*.fig
  

  SetOutPath "$INSTDIR\bin\win32"

  ; file /oname=${MATLAB_LIBS_PATH}uigetfolder_win32.dll${SOURCE}status.dll
  ; file ${SOURCE}register.dll
  ; file ${SOURCE}ibrowse.dll
  ; file ${SOURCE}uigetfolder_win32.dll
  ; file /oname=${MATLAB_BIN_WIN32}uigetfolder_win32.dll ${SOURCE}uigetfolder_win32.dll
  ; file ${SOURCE}bin\win32\status.dll
  ; file ${SOURCE}bin\win32\register.dll
  ; copy status and reg dlls over

  SetOutPath "$INSTDIR"
SectionEnd

;--------------------------------
; MatLab Libraries Section

Var HasMatlab

Section "Matlab Libraries" SecMatlabLib

   SetDetailsPrint textonly
   DetailPrint "Installing Matlab Libraries..."
   SetDetailsPrint listonly
  
   ; Size of library in kilobytes
   AddSize 33000

   SectionIn 1
   ;----------- Check Matlab Libraries -----------
; libcheck:                          ; Search for existing matlab lib path
   StrCpy $HasMatlab 0
   ReadEnvStr $1 PATH
   Push "$1"
   Push "matlab"
   Call StrStr
   Pop $R0
   StrCmp "" $R0 checkLocalImatestLibCopy checkForToolbox
checkForToolbox:                   ; Rule Out that it is toolbox path
   Push "$1"
   Push "toolbox"
   Call StrStr
   Pop $R0
   StrCmp "" $R0 hasMatlabInPath checkInstImatestLibCopy
hasMatlabInPath:                    ; There is a conflicting version of matlab
   StrCpy $HasMatlab 1
   ; See startimatest.bat, above. Added by N. Koren  8/9/2004

    ;----------- Copy archive -----------



checkInstImatestLibCopy:
   IfFileExists  "$INSTDIR\Imatest-lib.exe" checktoolbox

checkLocalImatestLibCopy:
   IfFileExists  "$EXEDIR\Imatest-lib.exe"  copy download

copy:
   CopyFiles $EXEDIR\Imatest-lib.exe $INSTDIR\Imatest-lib.exe

checktoolbox:
   IfFileExists "$INSTDIR\toolbox"   checkbin install    ; NLK 07/11/04.

checkbin:
   IfFileExists "$INSTDIR\bin\win32" libdone install     ; NLK 07/11/04.
   ; Go to libdone only if 3 criteria are met: Imatest-lib.exe, toolbox, and win32 all exist.

download:
   NSISDLSmooth::download "${MATLAB_LIBS_URL}" "$INSTDIR\Imatest-lib.exe"
  
install:
   RMDir /r   "$INSTDIR\bin\win32"   ; Borrowed from Uninstall. Seems to work here.
   RMDir /r   "$INSTDIR\toolbox"     ; Want clean install of both these folders.
   execwait  '"$INSTDIR\Imatest-lib.exe"'

libdone:  ; Place AddToPath(s) here so they are executed AFTER Library installation.

   ; Fixes  Move here so it always runs.
   file /oname=${MATLAB_LIBS_PATH}jpeg_depth.dll   ${SOURCE}${MATLAB_LIBS_PATH}jpeg_depth.dll
   file /oname=${MATLAB_LIBS_PATH}imjpg8.dll       ${SOURCE}${MATLAB_LIBS_PATH}imjpg8.dll
   file /oname=${MATLAB_LIBS_PATH}rjpg8c.dll       ${SOURCE}${MATLAB_LIBS_PATH}rjpg8c.dll
   file /oname=${MATLAB_BIN_WIN32}ibrowse.dll      ${SOURCE}ibrowse.dll
   file /oname=${MATLAB_BIN_WIN32}sortcellchar.dll ${SOURCE}sortcellchar.dll
   file /oname=${MATLAB_BIN_WIN32}uigetfolder_win32.dll  ${SOURCE}uigetfolder_win32.dll
   file /oname=${MATLAB_BIN_WIN32}uigetfiles.dll   ${SOURCE}uigetfiles.dll
   Push "$INSTDIR"
   Call AddToPath
   Push "$INSTDIR\bin\win32"
   Call AddToPath
   Push "$INSTDIR\toolbox\matlab"
   Call AddToPath

SectionEnd

;--------------------------------
; Start Menu Shortcuts Section

Section "Start Menu Shortcuts" SecShortcuts
  SetDetailsPrint textonly
  DetailPrint "Installing Start Menu Shortcuts..."
  SetDetailsPrint listonly
  
  SectionIn 1
  CreateDirectory "$SMPROGRAMS\Gamutvision"
  CreateShortCut  "$SMPROGRAMS\Gamutvision\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0 "SW_SHOWMINIMIZED"
  CreateShortCut  "$SMPROGRAMS\Gamutvision\Gamutvision.lnk" "$INSTDIR\gamutstart.bat" "" "$INSTDIR\Gamutvision_icon_32.ico" 0 "SW_SHOWMINIMIZED"
  CreateShortCut  "$SMPROGRAMS\Gamutvision\Documentation.lnk" "$INSTDIR\documentation.url" "" "" 0
SectionEnd

;--------------------------------
; Desktop Shortcut Section

Section "Desktop Shortcut" SecDesktop
  SetDetailsPrint textonly
  DetailPrint "Installing Desktop Shortcut..."
  SetDetailsPrint listonly
  
  SectionIn 1
  CreateDirectory "$SMPROGRAMS\Gamutvision"  ; ???????????????
  IfFileExists    "$DESKTOP\Gamutvision.lnk"   sc3    ; NLK 07/18/04.
  CreateShortCut  "$DESKTOP\Gamutvision.lnk" "$INSTDIR\gamutstart.bat" "" "$INSTDIR\Gamutvision_icon_32.ico" 0 "SW_SHOWMINIMIZED"
sc3:
SectionEnd

;--------------------------------
; Component Description

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "The core files required to use Gamutvision"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMatlabLib} "Matlab libraries"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Adds icons to your start menu"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Adds an Gamutvision icon to your desktop for easy access"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;##############################################################################
;############# Uninstall ######################################################
;##############################################################################

Section "Uninstall"
  ; Remove Registry Keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Gamutvision"
  DeleteRegKey HKLM "SOFTWARE\Gamutvision"

  ; Remove Shortcuts and Desktop
  Delete "$DESKTOP\Gamutvision.lnk"
  RMDir /r "$SMPROGRAMS\Gamutvision"

  ;Remove Files and Uninstaller.  Leave Imatest-lib.exe.
  ; Delete "$INSTDIR\ima*"  ; Unintentionally removes Imatest-lib.exe
  Delete "$INSTDIR\Gamutvision_icon_32.ico"
  Delete "$INSTDIR\gamutvision.ini"
  Delete "$INSTDIR\Gamutvision.exe"
  Delete "$INSTDIR\Gamutvision.lnk"
  Delete "$INSTDIR\Gamutvision"
  Delete "$INSTDIR\Gamutvision.pif"  ; Win 98???

  Delete "$INSTDIR\diagnostics*"
  Delete "$INSTDIR\CmdDumpProfile.exe"
  Delete "$INSTDIR\md5.exe"
  Delete "$INSTDIR\uninstall.exe"
  Delete "$INSTDIR\dcraw.exe"
  Delete "$INSTDIR\*.pif"
  Delete "$INSTDIR\*.ini"
  Delete "$INSTDIR\*.txt"
  Delete "$INSTDIR\*.bat"
  Delete "$INSTDIR\*.fig"
  Delete "$INSTDIR\*.jpg"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\documentation*"
  RMDir /r "$INSTDIR\samples"
  RMDir /r "$INSTDIR\images"
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\toolbox"

  Push "$INSTDIR"
  Call un.RemoveFromPath
  Push "$INSTDIR\bin\win32"                                           ; Remove path entries
  Call un.RemoveFromPath
  Push "$INSTDIR\toolbox\matlab"
  Call un.RemoveFromPath

  RMDir "$INSTDIR"                           ; remove main folder, if empty.

  IfFileExists "$INSTDIR" 0 NoErrorMsg
    MessageBox MB_OK "Note: $INSTDIR was not removed." IDOK 0 ; skipped if file doesn't exist
  NoErrorMsg:

SectionEnd

Section /o "un.Matlab Libraries"
  delete "$INSTDIR\Imatest-lib.exe"

  RMDir /r "$INSTDIR\bin"                                             ; remove matlab libraries
  RMDir /r "$INSTDIR\toolbox"
SectionEnd

