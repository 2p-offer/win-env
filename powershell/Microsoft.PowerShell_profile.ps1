$OutputEncoding = [System.Text.Encoding]::UTF8


#https://github.com/Kudostoy0u/pwsh10k
Import-Module posh-git
oh-my-posh init pwsh --config ~/pwsh10k.omp.json | Invoke-Expression

function color-ls
{
    $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase `
          -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
    $fore = $Host.UI.RawUI.ForegroundColor
    $compressed = New-Object System.Text.RegularExpressions.Regex(
          '\.(zip|tar|gz|rar|jar|war)$', $regex_opts)
    $executable = New-Object System.Text.RegularExpressions.Regex(
          '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$', $regex_opts)
    $text_files = New-Object System.Text.RegularExpressions.Regex(
          '\.(txt|cfg|conf|ini|csv|log|xml|java|c|cpp|cs)$', $regex_opts)

    Invoke-Expression ("Get-ChildItem $args") | ForEach-Object {
        if ($_.GetType().Name -eq 'DirectoryInfo') 
        {
            $Host.UI.RawUI.ForegroundColor = 'Cyan'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        }
        elseif ($compressed.IsMatch($_.Name)) 
        {
            $Host.UI.RawUI.ForegroundColor = 'darkgreen'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        }
        elseif ($executable.IsMatch($_.Name))
        {
            $Host.UI.RawUI.ForegroundColor = 'Red'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        }
        elseif ($text_files.IsMatch($_.Name))
        {
            $Host.UI.RawUI.ForegroundColor = 'Yellow'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        }
        else
        {
            echo $_
        }
    }
}

# 调用shell脚本
Set-Alias -Name sh -Value "D:\software\Git\bin\bash.exe"

# 删除现有的 ls 别名
Remove-Item Alias:ls -Force
# 设置新的别名
Set-Alias ls color-ls

# uw 同步server的proto修改到common仓库【仅commit 不 push 】
function syncp{
     param(
        [string]$commitMsg
    )
    git add .
    if (-not $commitMsg) {
       echo "shell need param [commit msg]"
       return
    }else {
        sh C:\Users\admin\Documents\shell\syncproto.sh $commitMsg
        cd C:/Users/admin/UW/code/uwcommon
    }
}

function gll {
    git pull
}
Remove-Item Alias:gl -Force
Set-Alias gl gll


function gla {
    git pull
    git submodule update
}

function gsd {
    param(
        [string]$stashName
    )
    git add .
    if (-not $stashName) {
        git stash
    }else {
        git stash save $stashName
    }
}


function gsddd {
    git add .
    git stash 
    git stash drop
}



function gst {
    git status
}


function z {
    param(
        [string]$subdir = ""
    )

    # 根路径
    $basePath = "C:\Users\admin\UW\code"

    # 根据参数决定目标路径
    switch ($subdir) {
        "s" { $targetPath = Join-Path -Path $basePath -ChildPath "uwserver" }
        "c" { $targetPath = Join-Path -Path $basePath -ChildPath "uwclient" }
        "m" { $targetPath = Join-Path -Path $basePath -ChildPath "uwcommon" }
        default { $targetPath = $basePath }
    }
 # 检查路径是否存在
    if (Test-Path -Path $targetPath) {
        Set-Location -Path $targetPath
    } else {
        Write-Host "目录不存在: $targetPath"
    }
}

# git TAB 补全
if (Test-Path "$env:ProgramFiles\Git\etc\profile.d\git-prompt.sh") {
    . "$env:ProgramFiles\Git\etc\profile.d\git-prompt.sh"
}

Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView


function gmr {
    param(
        [string]$targetBranch
    )

    # 获取当前目录的 Git 分支
    $sourceBranch = git rev-parse --abbrev-ref HEAD
    if (-not $sourceBranch) {
        return
    }

    # 构造 URL
    $url = "http://lf-git.im30.lan/uw/uwserver/-/merge_requests/new?merge_request%5Bsource_project_id%5D=6&merge_request%5Bsource_branch%5D=$sourceBranch&merge_request%5Btarget_project_id%5D=6&merge_request%5Btarget_branch%5D=$targetBranch"

    # 检查谷歌浏览器是否安装
    $chromePath = "C:\Users\admin\AppData\Local\Google\Chrome\Application\chrome.exe"
    if (Test-Path $chromePath) {
        Start-Process -FilePath $chromePath -ArgumentList @($url)
    }
}