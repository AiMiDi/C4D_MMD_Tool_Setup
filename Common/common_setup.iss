; common info

[Setup]
AppId={{#APP_GUID}}
AppName={#PluginFullName}
AppVersion={#PluginVersion}
;AppVerName={#PluginFullName} {#PluginVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#PluginFullName}
DisableDirPage=yes
DefaultGroupName={#PluginName}\{#PluginFullName}
DisableProgramGroupPage=yes
OutputDir=.\Output
OutputBaseFilename={#OUT_FILE_NAME}
UninstallFilesDir={group}

; Remove the following line to run in administrative install mode (install for all users.)
; PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline

WizardStyle=modern
SetupIconFile=Icon.ico
WizardSmallImageFile=WizardSmallImageFile.bmp
;WizardImageFile=WizardImageFile.bmp

Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64 arm64
; 在插件代码中创建同名的Mutex，再加上下面的配置就可以实现安装和卸载时检测插件是否在运行
AppMutex={#PluginFullName},Global\{#PluginFullName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "License_en.txt";
Name: "armenian"; MessagesFile: "compiler:Languages\Armenian.isl"; LicenseFile: "License_en.txt";
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"; LicenseFile: "License_en.txt";
Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"; LicenseFile: "License_en.txt";
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"; LicenseFile: "License_en.txt";
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"; LicenseFile: "License_ch.txt";
Name: "chinesetraditional"; MessagesFile: "compiler:Languages\ChineseTraditional.isl"; LicenseFile: "License_ch.txt";
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"; LicenseFile: "License_en.txt";
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"; LicenseFile: "License_en.txt";
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"; LicenseFile: "License_en.txt";
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"; LicenseFile: "License_en.txt";
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"; LicenseFile: "License_en.txt";
Name: "french"; MessagesFile: "compiler:Languages\French.isl"; LicenseFile: "License_en.txt";
Name: "german"; MessagesFile: "compiler:Languages\German.isl"; LicenseFile: "License_en.txt";
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"; LicenseFile: "License_en.txt";
Name: "icelandic"; MessagesFile: "compiler:Languages\Icelandic.isl"; LicenseFile: "License_en.txt";
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"; LicenseFile: "License_en.txt";
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"; LicenseFile: "License_en.txt";
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"; LicenseFile: "License_en.txt";
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"; LicenseFile: "License_en.txt";
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"; LicenseFile: "License_en.txt";
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"; LicenseFile: "License_en.txt";
Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"; LicenseFile: "License_en.txt";
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"; LicenseFile: "License_en.txt";
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"; LicenseFile: "License_en.txt";
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"; LicenseFile: "License_en.txt";
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"; LicenseFile: "License_en.txt";

[Run]
;Filename: "{app}\clear.bat"; Description: "Clear files created by ver2.9.5 or elder"; 

[CustomMessages]
;english.simplemessage=example%nmsg
;chinesesimplified.simplemessage=示例%n信息

[Icons]
Name: "{group}\{cm:UninstallProgram,{#PluginFullName}}"; Filename: "{uninstallexe}"