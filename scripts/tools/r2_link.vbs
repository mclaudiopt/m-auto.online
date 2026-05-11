' r2_link.vbs - Silent launcher for r2_link.ps1 (no PowerShell window flash)
' Called by Explorer right-click menu
' Argument: file path

If WScript.Arguments.Count = 0 Then
    MsgBox "Erro: nenhum ficheiro indicado.", vbCritical, "R2 Link"
    WScript.Quit 1
End If

Dim filePath, scriptPath, cmd
filePath   = WScript.Arguments(0)
scriptPath = "D:\Tutorials\m-auto.online\scripts\tools\r2_link.ps1"

cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & scriptPath & """ """ & filePath & """"

' Run with WindowStyle=0 (hidden), bWaitOnReturn=False (don't wait)
CreateObject("WScript.Shell").Run cmd, 0, False
