@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "compiler=%MOON_CC%"
if not defined compiler set "compiler=clang"

set "args="
:collect
if "%~1"=="" goto invoke
set "arg=%~1"
if "%arg%"=="-lm" (
  shift
  goto collect
)
if /I "%arg:~0,12%"=="-Wl,-rpath," (
  shift
  goto collect
)
set "args=!args! "%arg%""
shift
goto collect

:invoke
"%compiler%" %args%
exit /b %ERRORLEVEL%
