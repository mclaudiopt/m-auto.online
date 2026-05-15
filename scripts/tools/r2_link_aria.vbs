' r2_link_aria.vbs - Link Aria (24h validade) - hidden launcher
If WScript.Arguments.Count = 0 Then WScript.Quit 1
Dim cmd
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""D:\Tutorials\m-auto.online\scripts\tools\r2_link.ps1"" """ & WScript.Arguments(0) & """ -Mode Aria"
CreateObject("WScript.Shell").Run cmd, 0, False
