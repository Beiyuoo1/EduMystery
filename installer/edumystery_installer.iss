#define MyAppName "EduMystery"
#define MyAppVersion "1.0"
#define MyAppPublisher "EduMystery Team"
#define MyAppExeName "EduMystery.exe"
#define MyAppIcon "..\edumystery_logo.ico"
#define SourceDir "..\export"

[Setup]
AppId={{E1A2B3C4-D5E6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=.
OutputBaseFilename=EduMystery_Installer
SetupIconFile={#MyAppIcon}
Compression=lzma2/fast
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}
MinVersion=10.0
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
; Main game files
Source: "{#SourceDir}\EduMystery.exe";        DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\EduMystery.pck";        DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\EduMystery.console.exe"; DestDir: "{app}"; Flags: ignoreversion
; DLLs
Source: "{#SourceDir}\libvosk.dll";           DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\libvosk_godot.windows.template_debug.x86_64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\libgcc_s_seh-1.dll";    DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\libstdc++-6.dll";       DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\libwinpthread-1.dll";   DestDir: "{app}"; Flags: ignoreversion
; Vosk model (entire folder, recursive)
Source: "{#SourceDir}\addons\vosk\models\vosk-model-en-us-0.22\*"; DestDir: "{app}\addons\vosk\models\vosk-model-en-us-0.22"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}";         Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}";   Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

