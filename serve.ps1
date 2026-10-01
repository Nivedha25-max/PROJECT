# Solli Tharu AI - Local Development & Demo Server
# Runs a zero-dependency local HTTP server using .NET HttpListener

param(
    [int]$Port = 5500
)

$Host.UI.RawUI.WindowTitle = "Solli Tharu AI Server (Port $Port)"
$rootPath = $PSScriptRoot

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  Solli Tharu AI (சொல்லித் தரு) Local Server Started" -ForegroundColor Yellow
    Write-Host "  URL: $prefix" -ForegroundColor Cyan
    Write-Host "  SpeechRecognition & Web Audio unlocked on localhost" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green

    # Launch browser (prefer Chrome if present, otherwise default browser)
    $chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (Test-Path $chromePath) {
        Start-Process $chromePath -ArgumentList $prefix
    } else {
        Start-Process $prefix
    }

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $relPath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($relPath)) {
            $relPath = "index.html"
        }

        $fullPath = Join-Path $rootPath $relPath

        if (Test-Path $fullPath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $response.ContentLength64 = $bytes.Length

            if ($fullPath.EndsWith(".html")) {
                $response.ContentType = "text/html; charset=utf-8"
            } elseif ($fullPath.EndsWith(".css")) {
                $response.ContentType = "text/css; charset=utf-8"
            } elseif ($fullPath.EndsWith(".js")) {
                $response.ContentType = "application/javascript; charset=utf-8"
            } elseif ($fullPath.EndsWith(".json")) {
                $response.ContentType = "application/json; charset=utf-8"
            } else {
                $response.ContentType = "application/octet-stream"
            }

            $response.StatusCode = 200
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
}
catch {
    Write-Host "Server error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($listener -and $listener.IsListening) {
        $listener.Stop()
    }
}
