; Script by liuguanghao and Aimidi.
; Guide:
;   * Modify the code in this file on demand.
;   * SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
;
; 插件来源（相对本脚本所在目录 setup/Common）：
;   * xdl64：从各「R 系 / 年份」SDK 工程 Release 输出目录读取（见下方 XdlSdkRel）。
;     旧版 Cinema 4D 中 R/S 为同一大版本；S 系与配对 R 系 ABI 兼容（如 R25 SDK 覆盖至 S26.x），
;     故 S22/S24/S26 不再单独使用 sdk_s* 编译，安装包中复用同代 R 系（sdk_r21 / sdk_r23 / sdk_r25）产物。
;   * res：使用同一 SDK 构建产物中的完整资源树（包含验证后的 cmt_config.json）。
; 构建目录/配置可通过 ISCC 覆盖，例如：
;   /DSdkBuildDir=_build_msvc /DSdkBinConfig=Release

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
  #define PluginVersion "0.0.0.0"
#endif

#define MyAppPublisher ""
#define MyAppURL ""

; propose to use the above defines 
#define OUT_FILE_NAME PluginNameUnderlined + "_for_Cinema_4D_" + PluginVersion + "_setup"
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
#define APP_GUID "{3C5D5139-72A8-46C7-AC79-B5528066BC6D}"

#include "common_setup.iss"

[Setup]
; [optional] Do not use administrator privileges.
; PrivilegesRequired=lowest 

; 与仓库中需单独编译的 SDK 一一对应（S 系组件使用同 ABI 的 R 系 xdl，见上文注释）
#define VerCount = 11
#dim VerArray[VerCount] {'R20','R21','S22','R23','S24','R25','S26','2023','2024','2025','2026'}
#dim XdlSdkRel[VerCount] {'sdk_r20','sdk_r21','sdk_r21','sdk_r23','sdk_r23','sdk_r25','sdk_r25','sdk_2023','sdk_2024','sdk_2025','sdk_2026'}
#dim ResFolder[VerCount] {'R20-S24','R20-S24','R20-S24','R20-S24','R20-S24','S24_up','S24_up','S24_up','S24_up','S24_up','S24_up'}

#ifndef SdkBuildDir
  #define SdkBuildDir "_build_msvc"
#endif
#ifndef SdkBinConfig
  #define SdkBinConfig "Release"
#endif

#define ArrayIndex = 0

; Define the installation content for each version. 
; Including installed files, files to be deleted, registry deletions, etc.
#sub AddEntries
#define C4DVersion = VerArray[ArrayIndex]
#define SdkRootName = XdlSdkRel[ArrayIndex]
#define ResFolderName = ResFolder[ArrayIndex]
[Components]
Name: C_{#C4DVersion}; Description:"{#PluginName} for {#DCC_NAME} {#C4DVersion}";Flags: disablenouninstallwarning;
[Files]
; xdl：CMake 输出一般为 mmdtool.xdl64，安装目标文件名由 PluginDLLName 决定时需与之一致（此处复制为插件目录下主模块名）
Source: "..\..\{#SdkBuildDir}\{#SdkRootName}\bin\{#SdkBinConfig}\plugins\mmdtool\mmdtool.xdl64"; DestName: "{#PluginDLLName}.xdl64"; DestDir: "{code:InstallDir|{#C4DVersion}}plugins\{#PluginNameUnderlined}"; Components:C_{#C4DVersion}; Flags: ignoreversion; 
Source: "..\..\{#SdkBuildDir}\{#SdkRootName}\bin\{#SdkBinConfig}\plugins\mmdtool\res\*"; DestDir: "{code:InstallDir|{#C4DVersion}}plugins\{#PluginNameUnderlined}\res"; Components:C_{#C4DVersion}; Flags: ignoreversion recursesubdirs;
[InstallDelete]
Type: filesandordirs; Name: "{code:InstallDir|{#C4DVersion}}plugins\{#PluginNameUnderlined}"; Components:C_{#C4DVersion};
#endsub

; Batch add installation information for all versions of Array.
#for {ArrayIndex=0; ArrayIndex < VerCount; ArrayIndex = ArrayIndex + 1} AddEntries

[Code]
// Global variable
var
  PathSelectionPages: array of TwizardPage;
  PathSelectionPageEndID: Integer;
  DccVer: array of String;
  DccComponentName: array of String;
  Labels: array of TLabel;
  Edits: array of TEdit;
  Buttons: array of TButton;


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
            '{#VerArray[7]}',
            '{#VerArray[8]}',
            '{#VerArray[9]}',
            '{#VerArray[10]}' ];
  DccComponentName:=[ 'C_{#VerArray[0]}',
                      'C_{#VerArray[1]}',
                      'C_{#VerArray[2]}',
                      'C_{#VerArray[3]}',
                      'C_{#VerArray[4]}',
                      'C_{#VerArray[5]}',
                      'C_{#VerArray[6]}',
                      'C_{#VerArray[7]}',
                      'C_{#VerArray[8]}',
                      'C_{#VerArray[9]}',
                      'C_{#VerArray[10]}' ];
end;

// Whether you need to install the path configuration page.
function NeedPathSelectionPage():Boolean;
begin
  result:=true;
end;

// Check that the installation path is correct.
// NOTE: This func is only needed when NeedPathSelectionPage() is true.
function VerifyDirIsDccRoot(dir: String): Boolean;
begin
  result:=FileExists(dir+'\Cinema 4D.exe');  
end;

function InitializeSetup: Boolean;
begin
  Result:=true;
end;

// Find Cinema 4D install dir for year-based versions (2024+).
// Enumerates SOFTWARE\Maxon subkeys, picks the highest version within [year, year+1).
function FindInstallDirByYear(year: String): String;
var
  version_str, install_dir, subkey, next_year, max_version: String;
  i: Integer;
  subkeys: TArrayOfString;
begin
  Result := '';
  next_year := IntToStr(StrToInt(year) + 1);
  if RegGetSubkeyNames(HKLM, 'SOFTWARE\Maxon', subkeys) then
  begin
    max_version := '';
    for i := 0 to GetArrayLength(subkeys) - 1 do
    begin
      subkey := 'SOFTWARE\Maxon\' + subkeys[i];
      if RegQueryStringValue(HKLM, subkey, 'Version', version_str) then
      begin
        if (Pos('S', version_str) = 0) and (Pos('R', version_str) = 0) then
        begin
          if (CompareStr(version_str, year) >= 0) and (CompareStr(version_str, next_year) < 0) then
          begin
            if CompareStr(version_str, max_version) > 0 then
            begin
              if RegQueryStringValue(HKLM, subkey, 'Location', install_dir) and VerifyDirIsDccRoot(install_dir) then
              begin
                max_version := version_str;
                Result := install_dir;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

// Configure the plug-in installation path for each version.
// Install to the dcc installation directory and check that it is correct.
function GetInitInstallDir(ver: String): String;
var
  version_str, tmp_str, install_dir, lookup_ver: String;
  dir_valid: Boolean;
begin
  dir_valid := false;

  if ver = 'R20' then
  begin
    if RegQueryStringValue(HKLM, 'SOFTWARE\MAXON Installer', 'Last Installation', tmp_str) then
    begin
      if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + tmp_str, 'DisplayVersion', version_str) then
      begin
        if Copy(version_str, 1, 2) = '20' then
          dir_valid := RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + tmp_str, 'InstallLocation', install_dir) and VerifyDirIsDccRoot(install_dir);
      end;
    end;
  end
  else if ver = 'R21' then
  begin
    dir_valid := RegQueryStringValue(HKLM, 'SOFTWARE\Maxon\Maxon Cinema 4D', 'Location', install_dir) and VerifyDirIsDccRoot(install_dir);
  end
  else if (ver = '2024') or (ver = '2025') or (ver = '2026') then
  begin
    install_dir := FindInstallDirByYear(ver);
    dir_valid := install_dir <> '';
  end
  else
  begin
    lookup_ver := ver;
    StringChangeEx(lookup_ver, 'S', 'R', True);
    dir_valid := RegQueryStringValue(HKLM, 'SOFTWARE\Maxon\Maxon Cinema 4D ' + lookup_ver, 'Location', install_dir) and VerifyDirIsDccRoot(install_dir);
  end;

  if dir_valid then
    Result := install_dir
  else
    Result := '';
end;
#include "common_code.iss"
