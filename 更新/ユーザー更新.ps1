# ---------------------------------------
# 機能  ：SharePoint ユーザープロファイル更新
# 作成者：渡辺
# 更新者：
# 作成日：2019/06/14
# 更新日：
# 備考　：当スクリプトはある程度の動作確認を行っておりますが、
#	　　 すべての環境で動作することを保証するものではありません。
#		 利用は自己責任でお願いします。
# ---------------------------------------

# --------------------------------------------------------------------------------------
# スクリプトファイルへの名前付き引数の定義
# --------------------------------------------------------------------------------------
	Param(
		# 接続先ドメイン名 (例: techdev
		[string] $domain,
		
		# パスワードファイルパス (事前にCreateCred.batで作成すること
		[string] $credFilePath,

		# 削除対象ユーザー一覧CSVファイル名
		[System.Uri] $csvPath
	)
	
# --------------------------------------------------------------------------------------
# 処理内で使用する関数の定義
# --------------------------------------------------------------------------------------

# 引数のチェック
function CheckArgs($parameters)
{
	# 戻り値
	$ret = $true

	# メッセージ出力
	[Console]::WriteLine("")
	[Console]::WriteLine("引数チェックを実施します。")
	[Console]::WriteLine("   -----")

	# 引数チェック
	if($null -eq $domain)
	{
		[Console]::WriteLine("domainパラメータは省略できません。接続先ドメイン名を指定してください。 (例: techdev")
		
		$ret = $false
	}
	else
	{
		[Console]::WriteLine("   domainパラメータ	：" + $domain)
	}
	
	if($null -eq $credFilePath)
	{
		[Console]::WriteLine("credFilePathパラメータは省略できません。パスワードファイルパスを指定してください。 (パスワードファイルは事前にCreateCred.batで作成してください")
		
		$ret = $false
	}
	else
	{
		[Console]::WriteLine("   credFilePathパラメータ	：" + $credFilePath)
	}

	if($null -eq $csvPath)
	{
		[Console]::WriteLine("csvNameパラメータは省略できません。削除対象のユーザーを記述したCSVファイル名を指定してください。")
		
		$ret = $false
	}
	else
	{
		[Console]::WriteLine("   csvNameパラメータ	：" + $csvPath)
	}
	
	# メッセージ出力
	[Console]::WriteLine("   -----")
	[Console]::WriteLine("引数チェック結果：" + $ret)
	[Console]::WriteLine("")
	
	# チェック結果を返却
	return $ret
}

# --------------------------------------------------------------------------------------
# メイン処理
# --------------------------------------------------------------------------------------
function Main()
{
	# 必要なスナップインの読み込み
	$scriptPath = (Convert-Path .)
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.SharePoint.Client.dll")
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.SharePoint.Client.Runtime.dll")
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.Online.SharePoint.Client.Tenant.dll")
	[System.Reflection.Assembly]::LoadFile($scriptPath + "\modules\Microsoft.SharePoint.Client.UserProfiles.dll")
	[Console]::WriteLine("")

	[Console]::WriteLine("テナントに接続します。ドメイン：" + $domain + "パスワードファイル：" + $credFilePath)
	$credFile = Import-Clixml $credFilePath

	$siteUrl = "https://" + $domain + "-admin.sharepoint.com"
	$account = $credFile.UserName
	$password = $credFile.Password

	$context = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($account, $password)
	$context.ExecuteQuery()

	# ユーザー更新の準備
	$manager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($context)
	
	# 更新対象ユーザーの読取
	[Console]::WriteLine("CSVファイルの指定どおりにユーザーの設定を行います。CSVファイル：" + $csvPath)
	[int] $row = 1;
	Import-Csv $csvPath | Foreach-Object {
		
		# ユーザーアカウント取得
		$user = $_.ユーザーアカウント
		
		# ユーザーアカウント指定有無の確認
		if([String]::IsNullOrEmpty($user))
		{
			[Console]::WriteLine("「ユーザーアカウント」列の値が指定されていません。CSV行番号：" + $row)
		}
		else
		{
			try
			{
				# ユーザー更新
				$user = "i:0#.f|membership|" + $user
				[Console]::WriteLine("ユーザーを更新します。CSV行番号：" + $row + " ユーザーアカウント：" + $user + " 携帯電話番号" + $_.携帯電話番号)
				
				$manager.SetSingleValueProfileProperty($user, "cellPhone", $_.携帯電話番号)
				$context.Load($manager)
				$context.ExecuteQuery()

				[Console]::WriteLine("")
			}
			catch
			{
				[Console]::WriteLine($user + "の更新時にエラーが発生しました。CSV行番号：" + $row + " エラー内容：" + $_.Exception.Message)
			}
		}
		
		# カウントアップ
		$row++
	}

	# メッセージ
	$now = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
	[Console]::WriteLine($now + " " + "処理を完了しました。")
}


# --------------------------------------------------------------------------------------
# スクリプト開始時に実行される命令
# --------------------------------------------------------------------------------------
[Console]::WriteLine("")
[Console]::WriteLine("------------------------------------")
[Console]::WriteLine("PowerShellスクリプトを開始します。")
[Console]::WriteLine("")

try
{
	# 引数のチェック
	if(CheckArgs)
	{
		# メイン処理
		Main
	}
}
catch
{
	[Console]::WriteLine("エラーが発生しました。" + $_.Exception.Message)
}
finally
{
	[Console]::WriteLine("")
	[Console]::WriteLine("PowerShellスクリプトを終了します。")
	[Console]::WriteLine("------------------------------------")
	[Console]::WriteLine("")
}
