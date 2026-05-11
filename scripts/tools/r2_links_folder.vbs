' r2_links_folder.vbs - Silent launcher for r2_links_folder.ps1
If WScript.Arguments.Count = 0 Then WScript.Quit 1

Dim folderPath, scriptPath, cmd
folderPath = WScript.Arguments(0)
scriptPath = "D:\Tutorials\m-auto.online\scripts\tools\r2_links_folder.ps1"

cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & scriptPath & """ """ & folderPath & """"
CreateObject("WScript.Shell").Run cmd, 0, False
