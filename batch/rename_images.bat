@echo off
setlocal

rem 元のフォルダ名
set SRC=images

rem タイムスタンプでユニーク化
for /f "tokens=1-6 delims=/-:. " %%a in ("%date% %time%") do (
    set TS=%%a%%b%%c_%%d%%e%%f
)

set DST=%SRC%_%TS%

rem images が存在しないなら終了
if not exist "%SRC%" (
    echo "%SRC%" フォルダがありません。
    exit /b 1
)

echo Renaming "%SRC%" → "%DST%"
rename "%SRC%" "%DST%"

echo Creating new "%SRC%"
mkdir "%SRC%"

echo Done