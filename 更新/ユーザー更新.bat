@echo off

rem ���s�p�����[�^(���ʃp�����[�^)
set SCRIPT1=���[�U�[�X�V.ps1
set LOG=���[�U�[�X�V.log

rem ���s�p�����[�^(�X�N���v�g�ʃp�����[�^)
set DOMAIN="contoso"
set CRED_FILE_PATH="userCred.xml"
set CSV_PATH="���[�U�[�ꗗ.csv"

echo bat�t�@�C�����J�n���܂��B > "%~dp0%LOG%"

rem bat�t�@�C���̔z�u�f�B���N�g���ֈړ�
echo %~dp0�Ɉړ����܂��B >> %LOG%
cd %~dp0

rem ���s
powershell -ExecutionPolicy "ByPass" -Command %~dp0%SCRIPT1% -domain %DOMAIN% -credFilePath %CRED_FILE_PATH% -csvPath %CSV_PATH% >> %LOG%

echo bat�t�@�C�����I�����܂��B >> %LOG%

@echo on