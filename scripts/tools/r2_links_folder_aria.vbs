' r2_links_folder_aria.vbs - Links Aria (24h) - hidden launcher
If WScript.Arguments.Count = 0 Then WScript.Quit 1
Dim cmd
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""D:\Tutorials\m-auto.online\scripts\tools\r2_links_folder.ps1"" """ & WScript.Arguments(0) & """ -Mode Aria"
CreateObject("WScript.Shell").Run cmd, 0, False
