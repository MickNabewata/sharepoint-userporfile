@echo off

rem 実行パラメータ(共通パラメータ)
set SCRIPT1=ユーザー更新.ps1
set LOG=ユーザー更新.log

rem 実行パラメータ(スクリプト個別パラメータ)
set DOMAIN="contoso"
set CRED_FILE_PATH="userCred.xml"
set CSV_PATH="ユーザー一覧.csv"

echo batファイルを開始します。 > "%~dp0%LOG%"

rem batファイルの配置ディレクトリへ移動
echo %~dp0に移動します。 >> %LOG%
cd %~dp0

rem 実行
powershell -ExecutionPolicy "ByPass" -Command %~dp0%SCRIPT1% -domain %DOMAIN% -credFilePath %CRED_FILE_PATH% -csvPath %CSV_PATH% >> %LOG%

echo batファイルを終了します。 >> %LOG%

@echo on