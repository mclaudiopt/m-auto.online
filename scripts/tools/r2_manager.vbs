' r2_manager.vbs - Silent launcher for r2_manager.ps1
Dim cmd
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""D:\Tutorials\m-auto.online\scripts\tools\r2_manager.ps1"""
CreateObject("WScript.Shell").Run cmd, 0, False
