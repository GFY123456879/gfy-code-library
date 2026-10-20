$ErrorActionPreference = "Continue"
$Repo = Join-Path $HOME "Code\My-Code-Library"

while ($true) {
    Clear-Host

    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "         GFY DEVOPS TOOLBOX" -ForegroundColor Cyan
    Write-Host "===================================="
    Write-Host ""
    Write-Host "1. Show repository folders"
    Write-Host "2. Search commands"
    Write-Host "3. Open repository"
    Write-Host "4. Check Git status"
    Write-Host "5. Push changes to GitHub"
    Write-Host "0. Exit"
    Write-Host ""

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" {
            Get-ChildItem -Path $Repo -Directory |
                Select-Object Name, FullName |
                Format-Table -AutoSize

            Read-Host "Press Enter to return"
        }

        "2" {
            $keyword = Read-Host "Enter search keyword"

            if (-not [string]::IsNullOrWhiteSpace($keyword)) {
                Get-ChildItem -Path $Repo -Recurse -File |
                    Where-Object {
                        $_.FullName -notmatch '[\\/]\.git[\\/]' -and
                        $_.FullName -notmatch '[\\/]references[\\/]'
                    } |
                    Select-String -SimpleMatch $keyword |
                    Select-Object Path, LineNumber, Line
            }

            Read-Host "Press Enter to return"
        }

        "3" {
            if (Test-Path $Repo) {
                Start-Process explorer.exe $Repo
            }
            else {
                Write-Host "Repository not found." -ForegroundColor Red
                Read-Host "Press Enter to return"
            }
        }

        "4" {
            Push-Location $Repo
            try {
                git status
            }
            finally {
                Pop-Location
            }

            Read-Host "Press Enter to return"
        }

        "5" {
            Write-Host "Review your changes before uploading." -ForegroundColor Yellow
            $confirm = Read-Host "Type YES to continue"

            if ($confirm -ceq "YES") {
                Push-Location $Repo

                try {
                    git status --short
                    git add .

                    if ($LASTEXITCODE -ne 0) {
                        throw "git add failed"
                    }

                    git diff --cached --quiet

                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "No changes to commit." -ForegroundColor Yellow
                    }
                    else {
                        git commit -m "Update operations toolbox"

                        if ($LASTEXITCODE -ne 0) {
                            throw "git commit failed"
                        }

                        git push

                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "Push successful." -ForegroundColor Green
                        }
                        else {
                            Write-Host "Push failed." -ForegroundColor Red
                        }
                    }
                }
                catch {
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
                finally {
                    Pop-Location
                }
            }

            Read-Host "Press Enter to return"
        }

        "0" {
            break
        }

        default {
            Write-Host "Invalid option." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}