' r2_links_folder_http.vbs - Links HTTP (4h) - hidden launcher
If WScript.Arguments.Count = 0 Then WScript.Quit 1
Dim cmd, folderPath
folderPath = WScript.Arguments(0)
' Escapar aspas internas do caminho
folderPath = Replace(folderPath, """", """""")
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""D:\Tutorials\m-auto.online\scripts\tools\r2_links_folder.ps1"" """ & folderPath & """ -Mode HTTP"
CreateObject("WScript.Shell").Run cmd, 0, False
