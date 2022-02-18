# C4D_Plugin_Setup

A generic Inno Setup Script for packaging the C4D plugin as an installation package.

## Setup

```c++
// The name of the destination folder in the C4D plugins folder.
// C4D插件文件夹中目标文件夹的名称。
#define MyDirName "My Plugin Name"
// Plugin name.
// 插件名称
#define MyAppName "My Plugin"
// Plugin name (underlined).
// 插件名称（带下划线）
#define MyAppName_ "My_Plugin"
// Plug-in version.
// 插件版本
#define MyAppVersion "1.0.0"
// Publisher.
// 插件发布者
#define MyAppPublisher "Publisher"
// Plugin website.
// 插件网站
#define MyAppURL "My_Plugin.com"
```

```c++
// GUID ,The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
// GUID，AppID的值唯一标识此应用程序。不要在其他应用程序的安装程序中使用相同的AppID值。
AppId={{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}

// License file.
// 许可协议
LicenseFile=LICENSE.rtf
// Installation file icon.    
// 安装文件图标。
SetupIconFile=Icon.ico
// The icon at the top right of the installation wizard.
// 安装向导右上图标。
WizardSmallImageFile=WizardSmallImageFile.bmp
// The icon on the side of the installation wizard.
// 安装向导侧边图标。
WizardImageFile=WizardImageFile.bmp
```

## File structure

```
C4D_Plugin_Setup
├ c4d_plugin.iss
└ plugin
  ├ R20
  ├ R21
  ├ S22
  ├ R23
  ├ S24
  ├ R25
  └ common
```

**R20~R25：**

Add plugins for different C4D versions.

加入不同版本的C4D插件。

**common：**

Plug-in common files such as "res".

插件共同文件如“res”。 