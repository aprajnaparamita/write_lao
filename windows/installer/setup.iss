; ─────────────────────────────────────────────────────────────────────────────
; Inno Setup script for the Write It Lao Windows installer.
;
; Build (on a Windows box, after `flutter build windows --release`):
;   iscc /DAppVersion=1.0.5 windows\installer\setup.iss
;
; Output: outputs\write_it_lao-windows-setup.exe
;
; The stable output name keeps the README download link
; https://github.com/aprajnaparamita/write_lao/releases/latest/download/write_it_lao-windows-setup.exe
; valid across releases.
;
; Per-user install (no admin prompt). To install for all users instead:
;   iscc /DAppVersion=... /DAllUsers windows\installer\setup.iss
; ─────────────────────────────────────────────────────────────────────────────

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

[Setup]
AppId={{8F1A2B4C-6D3E-4A5B-9C7D-1E2F3A4B5C6D}
AppName=Write It Lao
AppVersion={#AppVersion}
AppPublisher=Maitri Group
DefaultDirName={localappdata}\Programs\Write It Lao
#ifdef AllUsers
  DefaultDirName={autopf}\Write It Lao
  PrivilegesRequired=admin
#else
  PrivilegesRequired=lowest
#endif
DefaultGroupName=Write It Lao
DisableProgramGroupPage=yes
OutputDir=..\..\outputs
OutputBaseFilename=write_it_lao-windows-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\write_it_lao.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; \
  GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Flutter release build output: app exe + required DLLs and data/
Source: "..\..\build\windows\x64\runner\Release\*"; \
  DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Write It Lao"; Filename: "{app}\write_it_lao.exe"
Name: "{autodesktop}\Write It Lao"; Filename: "{app}\write_it_lao.exe"; \
  Tasks: desktopicon

[Run]
Filename: "{app}\write_it_lao.exe"; \
  Description: "{cm:LaunchProgram,Write It Lao}"; \
  Flags: nowait postinstall skipifsilent
