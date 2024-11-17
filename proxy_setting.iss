; -- CodeExample1.iss --
;
; This script shows various things you can achieve using a [Code] section.

[Setup]
AppName=Proxy Configuration
AppVersion=1.0
WizardStyle=modern
DefaultDirName={pf}\Proxy Configuration
DefaultGroupName=Proxy Configuration
OutputDir=userdocs:Inno Setup Examples Output

[Files]
Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Icons]
Name: "{group}\Proxy Configuration"; Filename: "{app}\MyApp.exe"

[Run]
Filename: "{src}\timer.bat"; Description: "{cm:LaunchProgram,My Application}"; Flags: nowait postinstall skipifsilent

[Code]
var
  ProxyPage: TInputQueryWizardPage;
  RunExecuted: Boolean;

procedure InitializeWizard;
begin
  // Create a new input query page
  ProxyPage := CreateInputQueryPage(wpSelectTasks, 'Proxy Settings', 'Enter your proxy settings', 'Please enter the HTTP and HTTPS proxy settings below:');
  // Add HTTP Proxy input
  ProxyPage.Add('&HTTP Proxy:', False);
  // Add HTTPS Proxy input
  ProxyPage.Add('&HTTPS Proxy:', False);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  Log('CurPageChanged(' + IntToStr(CurPageID) + ') called');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  HTTPProxy: string;
  HTTPSProxy: string;
  ResultCode: Integer;
begin
  Log('NextButtonClick(' + IntToStr(CurPageID) + ') called');

  if CurPageID = ProxyPage.ID then
  begin
    HTTPProxy := ProxyPage.Values[0];
    HTTPSProxy := ProxyPage.Values[1];

    try
      SaveStringToFile(ExpandConstant('{app}\proxy_settings.ini'), '[PROXY]' + #13#10 + 'HTTP_PROXY=' + HTTPProxy + #13#10 + 'HTTPS_PROXY=' + HTTPSProxy, False);
    except
      MsgBox('Failed to save proxy settings', mbError, MB_OK);
    end;

    MsgBox('Proxy settings have been saved to proxy_settings.ini' + #13#10 + ExpandConstant('{app}\proxy_settings.ini'), mbInformation, MB_OK);

    // Execute the first line of the Run section
    if not RunExecuted then
    begin
      if not Exec(ExpandConstant('{src}\timer.bat'), '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
      begin
        Log('Failed to execute timer.bat' + #13#10 + 'Code: ' + IntToStr(ResultCode));
        MsgBox('Failed to execute timer.bat', mbError, MB_OK);
        WizardForm.BackButton;
        Result := False;
        Exit;
      end;
      MsgBox('timer.bat has been executed', mbInformation, MB_OK);
      RunExecuted := True;
    end;
  end;

  Result := True;
end;
