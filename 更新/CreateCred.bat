@echo off

cd %~dp0
powershell -ExecutionPolicy "UnRestricted" "Get-Credential | Export-Clixml userCred.xml"

echo "パスワードファイル userCred.xml が作成されました。(たぶん"
echo "push any key..."
pause