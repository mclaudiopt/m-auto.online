' r2_link_http.vbs - Link HTTP (4h validade) - hidden launcher
If WScript.Arguments.Count = 0 Then WScript.Quit 1
Dim cmd, filePath
filePath = WScript.Arguments(0)
' Escapar aspas internas do caminho
filePath = Replace(filePath, """", """""")
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""D:\Tutorials\m-auto.online\scripts\tools\r2_link.ps1"" """ & filePath & """ -Mode HTTP"
CreateObject("WScript.Shell").Run cmd, 0, False
