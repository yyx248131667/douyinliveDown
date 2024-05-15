@echo off
chcp 65001 > nul

REM 获取当前日期时间，用于创建文件夹
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set "year=%%c"
    set "month=%%a"
    set "day=%%b"
)

for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "hour=%%a"
    set "minute=%%b"
)

REM 删除日期中的0开头
if "%month:~0,1%" == "0" set "month=%month:~1%"
if "%day:~0,1%" == "0" set "day=%day:~1%"

set "date=%year%-%month%-%day%_%hour%-%minute%"

set /p m3u8_link=请输入.m3u8链接: 

REM 从输入的链接中提取时间信息
for /f "tokens=5 delims=/-." %%a in ("%m3u8_link%") do (
    set "year=%%a"
    set "month=%%b"
    set "day=%%c"
    set "hour=%%d"
    set "minute=%%e"
)

REM 创建时间文件夹
mkdir "%year%-%month%-%day%_%hour%-%minute%" > nul

:DOWNLOAD
REM 使用 PowerShell 测量下载速度
for /f %%a in ('powershell -Command "(Measure-Command {wget --quiet --output-document=nul '%m3u8_link%'}).TotalMilliseconds"') do set "download_time=%%a"

REM 如果下载速度低于2ms，则暂停10秒并重新开始下载
if %download_time% LSS 2 (
    echo 下载速度低于2ms，暂停10秒后重新下载...
    timeout /t 10 > nul
    goto :DOWNLOAD
)

REM 否则继续下载
ffmpeg -i "%m3u8_link%" -c copy "%year%-%month%-%day%_%hour%-%minute%/1.mp4"

pause
