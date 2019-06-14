# ---------------------------------------
# �@�\  �FSharePoint ���[�U�[�v���t�@�C���X�V
# �쐬�ҁF�n��
# �X�V�ҁF
# �쐬���F2019/06/14
# �X�V���F
# ���l�@�F���X�N���v�g�͂�����x�̓���m�F���s���Ă���܂����A
#	�@�@ ���ׂĂ̊��œ��삷�邱�Ƃ�ۏ؂�����̂ł͂���܂���B
#		 ���p�͎��ȐӔC�ł��肢���܂��B
# ---------------------------------------

# --------------------------------------------------------------------------------------
# �X�N���v�g�t�@�C���ւ̖��O�t�������̒�`
# --------------------------------------------------------------------------------------
	Param(
		# �ڑ���h���C���� (��: techdev
		[string] $domain,
		
		# �p�X���[�h�t�@�C���p�X (���O��CreateCred.bat�ō쐬���邱��
		[string] $credFilePath,

		# �폜�Ώۃ��[�U�[�ꗗCSV�t�@�C����
		[System.Uri] $csvPath
	)
	
# --------------------------------------------------------------------------------------
# �������Ŏg�p����֐��̒�`
# --------------------------------------------------------------------------------------

# �����̃`�F�b�N
function CheckArgs($parameters)
{
	# �߂�l
	$ret = $true

	# ���b�Z�[�W�o��
	[Console]::WriteLine("")
	[Console]::WriteLine("�����`�F�b�N�����{���܂��B")
	[Console]::WriteLine("   -----")

	# �����`�F�b�N
	if($null -eq $domain)
	{
		[Console]::WriteLine("domain�p�����[�^�͏ȗ��ł��܂���B�ڑ���h���C�������w�肵�Ă��������B (��: techdev")
		
		$ret = $false
	}
	else
	{
		[Console]::WriteLine("   domain�p�����[�^	�F" + $domain)
	}
	
	if($null -eq $credFilePath)
	{
		[Console]::WriteLine("credFilePath�p�����[�^�͏ȗ��ł��܂���B�p�X���[�h�t�@�C���p�X���w�肵�Ă��������B (�p�X���[�h�t�@�C���͎��O��CreateCred.bat�ō쐬���Ă�������")
		
		$ret = $false
	}
	else
	{
		[Console]::WriteLine("   credFilePath�p�����[�^	�F" + $credFilePath)
	}

	if($null -eq $csvPath)
	{
		[Console]::WriteLine("csvName�p�����[�^�͏ȗ��ł��܂���B�폜�Ώۂ̃��[�U�[���L�q����CSV�t�@�C�������w�肵�Ă��������B")
		
		$ret = $false
	}
	else
	{
		[Console]::WriteLine("   csvName�p�����[�^	�F" + $csvPath)
	}
	
	# ���b�Z�[�W�o��
	[Console]::WriteLine("   -----")
	[Console]::WriteLine("�����`�F�b�N���ʁF" + $ret)
	[Console]::WriteLine("")
	
	# �`�F�b�N���ʂ�ԋp
	return $ret
}

# --------------------------------------------------------------------------------------
# ���C������
# --------------------------------------------------------------------------------------
function Main()
{
	# �K�v�ȃX�i�b�v�C���̓ǂݍ���
	$scriptPath = (Convert-Path .)
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.SharePoint.Client.dll")
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.SharePoint.Client.Runtime.dll")
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.Online.SharePoint.Client.Tenant.dll")
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.SharePoint.Client.UserProfiles.dll")
	[Console]::WriteLine("")

	[Console]::WriteLine("�e�i���g�ɐڑ����܂��B�h���C���F" + $domain + "�p�X���[�h�t�@�C���F" + $credFilePath)
	$credFile = Import-Clixml $credFilePath

	$siteUrl = "https://" + $domain + "-admin.sharepoint.com"
	$account = $credFile.UserName
	$password = $credFile.Password

	$context = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($account, $password)
	$context.ExecuteQuery()

	# ���[�U�[�X�V�̏���
	$manager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($context)
	
	# �X�V�Ώۃ��[�U�[�̓ǎ�
	[Console]::WriteLine("CSV�t�@�C���̎w��ǂ���Ƀ��[�U�[�̐ݒ���s���܂��BCSV�t�@�C���F" + $csvPath)
	[int] $row = 1;
	Import-Csv $csvPath | Foreach-Object {
		
		# ���[�U�[�A�J�E���g�擾
		$user = $_.���[�U�[�A�J�E���g
		
		# ���[�U�[�A�J�E���g�w��L���̊m�F
		if([String]::IsNullOrEmpty($user))
		{
			[Console]::WriteLine("�u���[�U�[�A�J�E���g�v��̒l���w�肳��Ă��܂���BCSV�s�ԍ��F" + $row)
		}
		else
		{
			try
			{
				# ���[�U�[�X�V
				$user = "i:0#.f|membership|" + $user
				[Console]::WriteLine("���[�U�[���X�V���܂��BCSV�s�ԍ��F" + $row + " ���[�U�[�A�J�E���g�F" + $user + " �g�ѓd�b�ԍ�" + $_.�g�ѓd�b�ԍ�)
				
				$manager.SetSingleValueProfileProperty($user, "cellPhone", $_.�g�ѓd�b�ԍ�)
				$context.Load($manager)
				$context.ExecuteQuery()

				[Console]::WriteLine("")
			}
			catch
			{
				[Console]::WriteLine($user + "�̍X�V���ɃG���[���������܂����BCSV�s�ԍ��F" + $row + " �G���[���e�F" + $_.Exception.Message)
			}
		}
		
		# �J�E���g�A�b�v
		$row++
	}

	# ���b�Z�[�W
	$now = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
	[Console]::WriteLine($now + " " + "�������������܂����B")
}


# --------------------------------------------------------------------------------------
# �X�N���v�g�J�n���Ɏ��s����閽��
# --------------------------------------------------------------------------------------
[Console]::WriteLine("")
[Console]::WriteLine("------------------------------------")
[Console]::WriteLine("PowerShell�X�N���v�g���J�n���܂��B")
[Console]::WriteLine("")

try
{
	# �����̃`�F�b�N
	if(CheckArgs)
	{
		# ���C������
		Main
	}
}
catch
{
	[Console]::WriteLine("�G���[���������܂����B" + $_.Exception.Message)
}
finally
{
	[Console]::WriteLine("")
	[Console]::WriteLine("PowerShell�X�N���v�g���I�����܂��B")
	[Console]::WriteLine("------------------------------------")
	[Console]::WriteLine("")
}
