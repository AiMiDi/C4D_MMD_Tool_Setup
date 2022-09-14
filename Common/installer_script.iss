; Script by liuguanghao and Aimidi.
; Guide:
;   * Modify the code in this file on demand.
;   * SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define DCC_NAME "Cinema 4D" 

#ifndef PluginName
  #define PluginName "MMD Tool"
#endif

#ifndef PluginNameUnderlined
  #define PluginNameUnderlined "MMD_Tool"
#endif

#ifndef PluginDLLName
  #define PluginDLLName "MMDTool"
#endif

#define PluginFullName PluginName + " for " + DCC_NAME

#ifndef PluginVersion
  #define PluginVersion "0.4.5.1"
#endif

#define MyAppPublisher ""
#define MyAppURL ""

; propose to use the above defines 
#define OUT_FILE_NAME PluginNameUnderlined + "_for_Cinema_4D_" + PluginVersion + "_setup"
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
#define APP_GUID "3C5D5139-72A8-46C7-AC79-B5528066BC6D"

#include "common_setup.iss"

[Setup]
; [optional] Do not use administrator privileges.
; PrivilegesRequired=lowest 

; Define all supported versions.
#define VerCount = 8
#dim VerArray[VerCount] {'R20','R21','S22','R23','S24','R25','S26','2023'}
#define ArrayIndex = 0

; Define the installation content for each version. 
; Including installed files, files to be deleted, registry deletions, etc.
#sub AddEntries
#define C4DVersion = VerArray[ArrayIndex]      
[Components]
Name: C_{#C4DVersion}; Description:"{#PluginName} for {#DCC_NAME} {#C4DVersion}";Flags: disablenouninstallwarning;
[Files]
; All versions deal with files in the same way.
Source: "..\..\code\release\{#C4DVersion}\{#PluginDLLName}.xdl64"; DestDir: "{code:InstallDir|{#C4DVersion}}plugins\{#PluginNameUnderlined}"; Components:C_{#C4DVersion}; Flags: ignoreversion; 
Source: "..\..\code\res\*"; DestDir: "{code:InstallDir|{#C4DVersion}}plugins\{#PluginNameUnderlined}\res"; Components:C_{#C4DVersion}; Flags: ignoreversion recursesubdirs; 
[InstallDelete]
Type: filesandordirs; Name: "{code:InstallDir|{#C4DVersion}}plugins\{#PluginNameUnderlined}"; Components:C_{#C4DVersion};
#endsub

; Batch add installation information for all versions of Array.
#for {ArrayIndex=0; ArrayIndex < VerCount; ArrayIndex = ArrayIndex + 1} AddEntries

[Code]
// Global variable
var
  PathSelectionPage: TwizardPage; 
  DccVer: array of String;
  Labels: array of TLabel;
  Edits:array of TEdit;
  Buttons:array of TButton;


// Put the version definition in the macro definition into an array. 
// Since the version number in the macro definition array cannot be obtained directly from the variable index, this is the only way to do so.
procedure MapVerArray();
begin
  DccVer:=[ '{#VerArray[0]}',
            '{#VerArray[1]}',
            '{#VerArray[2]}',
            '{#VerArray[3]}',
            '{#VerArray[4]}',
            '{#VerArray[5]}',
            '{#VerArray[6]}',
            '{#VerArray[7]}' ]; 
end;

// Whether you need to install the path configuration page.
function NeedPathSelectionPage():Boolean;
begin
  // The path selection page is required. Return to true.
  result:=true;
end;

// Check that the installation path is correct.
// NOTE: This func is only needed when NeedPathSelectionPage() is true.
function VerifyDirIsDccRoot(dir: String): Boolean;
begin
  result:=FileExists(dir+'\Cinema 4D.exe');  
end;

// Configure the plug-in installation path for each version.
// Install to the dcc installation directory and check that it is correct.
function GetInitInstallDir(ver: String): String;
var
  version_str, tmp_str, install_dir, ver_in_reg:String;
  dir_valid:Boolean;
begin
  ver_in_reg:=copy(ver, 2, 2);
  if (ver_in_reg = '20') then
  begin
    if RegQueryStringValue(HKLM, 'SOFTWARE\MAXON Installer', 'Last Installation', tmp_str) then
    begin
      if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + tmp_str, 'DisplayVersion', version_str) then
      begin     
        if copy(version_str, 1, 2) = '20' then
        begin
          dir_valid:=RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+tmp_str, 'InstallLocation', install_dir) and VerifyDirIsDccRoot(install_dir)       
        end;
      end;
    end;
  end
  else
  if (ver_in_reg = '21') then
    begin
      dir_valid:=RegQueryStringValue(HKLM, 'SOFTWARE\Maxon\Maxon Cinema 4D', 'Location', install_dir) and VerifyDirIsDccRoot(install_dir)
  end 
  else
  begin         
      StringChangeEx (ver, 'S', 'R', True);
      dir_valid:=RegQueryStringValue(HKLM, 'SOFTWARE\Maxon\Maxon Cinema 4D ' + ver, 'Location', install_dir) and VerifyDirIsDccRoot(install_dir)
  end;
    if (dir_valid) then
      result:=install_dir
    else
      result:='';
end;
#include "common_code.iss"
