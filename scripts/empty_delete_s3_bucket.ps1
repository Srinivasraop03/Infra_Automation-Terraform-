<#
PowerShell script to backup an S3 bucket, delete all object versions and delete-markers (for versioned buckets),
and then delete the bucket itself.

Usage:
  .\empty_delete_s3_bucket.ps1 -BucketName terraform-infra-state-bucket-srini -BackupDir .\s3-backup -AutoApprove

Requirements:
  - AWS CLI configured and reachable from this shell
  - IAM user with permissions: s3:ListBucketVersions, s3:GetObject, s3:DeleteObject, s3:DeleteObjectVersion, s3:DeleteBucket

Caution: This irreversibly removes objects. Backup before proceeding.
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$BucketName = "terraform-infra-state-bucket-srini",

    [string]$BackupDir = "./s3-backup-$((Get-Date).ToString('yyyyMMdd-HHmmss'))",

    [switch]$AutoApprove
)

function Check-AwsCli {
    try {
        aws --version > $null 2>&1
    } catch {
        Write-Error "AWS CLI not found in PATH. Install and configure AWS CLI before running this script."
        exit 2
    }
}

function Backup-Bucket {
    param($bucket, $dest)
    Write-Host "Backing up bucket s3://$bucket to $dest ..."
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    $rc = & aws s3 cp "s3://$bucket" $dest --recursive
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Backup encountered errors. Continue with deletion only if you have a separate backup."
    } else {
        Write-Host "Backup complete."
    }
}

function Delete-AllVersions {
    param($bucket)
    Write-Host "Deleting all object versions and delete markers from bucket: $bucket"

    while ($true) {
        $resp = aws s3api list-object-versions --bucket $bucket --output json 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to list object versions for bucket $bucket"
            exit 3
        }

        $json = $resp | ConvertFrom-Json

        $items = @()
        if ($null -ne $json.Versions) {
            foreach ($v in $json.Versions) {
                $items += @{ Key = $v.Key; VersionId = $v.VersionId }
            }
        }
        if ($null -ne $json.DeleteMarkers) {
            foreach ($d in $json.DeleteMarkers) {
                $items += @{ Key = $d.Key; VersionId = $d.VersionId }
            }
        }

        if ($items.Count -eq 0) {
            Write-Host "No more versions or delete markers found."
            break
        }

        # Delete in batches of 1000 (S3 API limit)
        while ($items.Count -gt 0) {
            $batch = $items[0..([math]::Min($items.Count-1,999))]
            $payload = @{ Objects = $batch }
            $tmp = [IO.Path]::Combine($env:TEMP, "s3-delete-objects-$([guid]::NewGuid()).json")
            [System.IO.File]::WriteAllText($tmp, ($payload | ConvertTo-Json -Depth 6))

            Write-Host "Deleting $($batch.Count) versions/delete-markers..."
            aws s3api delete-objects --bucket $bucket --delete file://$tmp | Out-Null
            Remove-Item $tmp -ErrorAction SilentlyContinue

            # remove processed items
            if ($batch.Count -ge $items.Count) { $items = @() } else { $items = $items[$batch.Count..($items.Count-1)] }
        }

        Start-Sleep -Seconds 1
    }
}

function Delete-Bucket {
    param($bucket)
    Write-Host "Attempting to delete S3 bucket: $bucket"
    $delResp = aws s3api delete-bucket --bucket $bucket 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to delete bucket. AWS CLI message:`n$delResp"
        exit 4
    }
    Write-Host "Bucket deleted successfully."
}

# Main
Check-AwsCli
Write-Host "Bucket: $BucketName"
Write-Host "Backup directory: $BackupDir"
if (-not $AutoApprove) {
    $ok = Read-Host "This will irreversibly remove all objects and delete the bucket. Type YES to continue"
    if ($ok -ne 'YES') { Write-Host 'Aborted.'; exit 1 }
}

Backup-Bucket -bucket $BucketName -dest $BackupDir
Delete-AllVersions -bucket $BucketName
Delete-Bucket -bucket $BucketName

Write-Host "Done."
