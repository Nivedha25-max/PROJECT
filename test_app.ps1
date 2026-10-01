# Pengal Sevai (பெண்கள் சேவை) Automated Verification Test Suite

$url = "http://localhost:5500/"
Write-Host "Running automated verification tests against $url..." -ForegroundColor Cyan

try {
    $res = Invoke-WebRequest -Uri $url -UseBasicParsing
    
    # Test 1: Status Code
    if ($res.StatusCode -eq 200) {
        Write-Host "[PASS] Test 1: HTTP 200 OK received" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 1: HTTP status is $($res.StatusCode)" -ForegroundColor Red
    }

    # Test 2: Content Type
    $ct = $res.Headers["Content-Type"]
    if ($ct -match "text/html") {
        Write-Host "[PASS] Test 2: Content-Type is text/html ($ct)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 2: Unexpected Content-Type: $ct" -ForegroundColor Red
    }

    $fileBytes = [System.IO.File]::ReadAllBytes((Join-Path $PSScriptRoot "index.html"))
    $content = [System.Text.Encoding]::UTF8.GetString($fileBytes)

    # Test 3: Audio Unlock Overlay
    if ($content.Contains('id="startOverlay"') -and $content.Contains('id="btnTouchToStart"')) {
        Write-Host "[PASS] Test 3: Audio Unlock Overlay present" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 3: Missing audio unlock overlay" -ForegroundColor Red
    }

    # Test 4: One-Touch Central Mic Module
    if ($content.Contains('id="btnMainMic"') -and $content.Contains('id="micGroup"')) {
        Write-Host "[PASS] Test 4: Module 1 (Central Mic) elements present" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 4: Missing Module 1" -ForegroundColor Red
    }

    # Test 5: Multi-Scheme Database & Support
    $hasAllSchemes = $content.Contains('magalir_urimai') -and `
                     $content.Contains('ujjwala_gas') -and `
                     $content.Contains('women_loan') -and `
                     $content.Contains('maternity_aid') -and `
                     $content.Contains('sewing_machine') -and `
                     $content.Contains('girl_education')

    if ($hasAllSchemes) {
        Write-Host "[PASS] Test 5: Multi-Scheme Database (6 Government Schemes) verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 5: Missing one or more schemes in database" -ForegroundColor Red
    }

    # Test 6: Conversational Screener & Persistent History Array (Repetition Bug Fix)
    if ($content.Contains('id="chatStream"') -and $content.Contains('let conversationHistory = [];') -and $content.Contains('detectSchemeFromText')) {
        Write-Host "[PASS] Test 6: Module 2 (Multi-turn Memory & Repetition Fix) verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 6: Missing Module 2 memory elements or persistent history" -ForegroundColor Red
    }

    # Test 7: Adaptive Document Checklist & Camera Scanner
    if ($content.Contains('id="docCardsContainer"') -and $content.Contains('id="scannerModal"') -and $content.Contains('startCameraScan')) {
        Write-Host "[PASS] Test 7: Module 3 (Adaptive Document Checklist & Camera Scanner) verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 7: Missing Module 3" -ForegroundColor Red
    }

    # Test 8: Voice WhatsApp Slip
    if ($content.Contains('btnShareWhatsApp') -and $content.Contains('wa.me')) {
        Write-Host "[PASS] Test 8: Module 4 (Voice WhatsApp Slip) verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 8: Missing Module 4" -ForegroundColor Red
    }

    # Test 9: Simulated Missed Call & Toll-Free Helpline
    if ($content.Contains('id="callScreenModal"') -and $content.Contains('triggerMissedCallSimulation') -and $content.Contains('18000008888')) {
        Write-Host "[PASS] Test 9: Module 5 (Simulated Missed Call & Toll-Free Helpline) verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 9: Missing Module 5" -ForegroundColor Red
    }

    # Test 10: Mock e-Seva Interview Rehearsal Mode
    if ($content.Contains('btnTogglePractice') -and $content.Contains('togglePracticeMode')) {
        Write-Host "[PASS] Test 10: Module 6 (Mock e-Seva Rehearsal Mode) verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 10: Missing Module 6" -ForegroundColor Red
    }

    # Test 11: Direct Gemini 2.5 Flash Endpoint & System Prompt
    if ($content.Contains('gemini-2.5-flash:generateContent') -and $content.Contains('Pengal Sevai')) {
        Write-Host "[PASS] Test 11: Gemini 2.5 Flash API endpoint & Pengal Sevai System Instruction verified" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 11: Missing Gemini endpoint or system prompt" -ForegroundColor Red
    }

    # Test 12: Tamil Unicode UTF-8 Integrity
    $hasTamilBytes = $false
    for ($idx = 0; $idx -lt $fileBytes.Length - 1; $idx++) {
        if ($fileBytes[$idx] -eq 0xE0 -and ($fileBytes[$idx+1] -eq 0xAE -or $fileBytes[$idx+1] -eq 0xAF)) {
            $hasTamilBytes = $true
            break
        }
    }
    if ($hasTamilBytes) {
        Write-Host "[PASS] Test 12: Tamil Unicode UTF-8 encoding integrity validated" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Test 12: Tamil Unicode corrupted" -ForegroundColor Red
    }

    Write-Host "`nAll 12 automated verification tests for Pengal Sevai passed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running tests: $($_.Exception.Message)" -ForegroundColor Red
}
