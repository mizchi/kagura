@echo off
setlocal EnableExtensions
node "%~dp0moon-native-cc-win.cjs" %*
exit /b %ERRORLEVEL%
