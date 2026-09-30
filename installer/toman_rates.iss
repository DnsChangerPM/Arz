#ifndef AppVersion
#define AppVersion "1.0.0"
#endif
#define AppName "Toman Rates"
#define AppExe "toman_rates.exe"
[Setup]
AppId={{A72B0F4E-86A7-49D8-97D8-FEB50CDF1209}
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={autopf}\Toman Rates
DefaultGroupName=Toman Rates
OutputDir=..\build\installer
OutputBaseFilename=TomanRates-{#AppVersion}-Windows
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#AppExe}
PrivilegesRequired=lowest
[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "background_refresh.cmd"; DestDir: "{app}"; Flags: ignoreversion
[Icons]
Name: "{group}\Toman Rates"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\Toman Rates"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon
[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; Flags: unchecked
Name: dailyupdate; Description: "Refresh rates daily around 09:00"; Flags: checkedonce
[Run]
Filename: "{sys}\schtasks.exe"; Parameters: "/Create /F /SC DAILY /ST 09:00 /TN ""TomanRatesRefresh"" /TR ""{app}\background_refresh.cmd"""; Flags: runhidden; Tasks: dailyupdate
[UninstallRun]
Filename: "{cmd}"; Parameters: "/C schtasks /Delete /F /TN TomanRatesRefresh"; Flags: runhidden; RunOnceId: "RemoveTask"
