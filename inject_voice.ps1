$BASE = "c:\Users\Admin\OneDrive\Documents\edu-mys-dev"
$VOICE_BASE = "$BASE\assets\audio\voice"
$TIMELINE_BASE = "$BASE\content\timelines"

$SCENE_MAP = @(
    @{ ch="Chapter 2"; dtl="c2s0.dtl"; voice="Chapter 2\c2s0 mathilda COUNCIL_ROOM" },
    @{ ch="Chapter 2"; dtl="c2s1.dtl"; voice="Chapter 2\c2s1 mathilda HALLWAY" },
    @{ ch="Chapter 2"; dtl="c2s2.dtl"; voice="Chapter 2\c2s2 narrator mathilda" },
    @{ ch="Chapter 2"; dtl="c2s3.dtl"; voice="Chapter 2\c2s3 narrator mathilda" },
    @{ ch="Chapter 2"; dtl="c2s4.dtl"; voice="Chapter 2\c2s4 mathilda" },
    @{ ch="Chapter 2"; dtl="c2s5.dtl"; voice="Chapter 2\c2s5 mathilda" },
    @{ ch="Chapter 2"; dtl="c2s6.dtl"; voice="Chapter 2\c2s6 mathilda" },
    @{ ch="Chapter 3"; dtl="c3s0.dtl"; voice="Chapter 3\c3s0" },
    @{ ch="Chapter 3"; dtl="c3s1.dtl"; voice="Chapter 3\c3s1" },
    @{ ch="Chapter 3"; dtl="c3s2.dtl"; voice="Chapter 3\c3s2" },
    @{ ch="Chapter 3"; dtl="c3s3.dtl"; voice="Chapter 3\c3s3" },
    @{ ch="Chapter 3"; dtl="c3s4.dtl"; voice="Chapter 3\c3s4" },
    @{ ch="Chapter 3"; dtl="c3s5.dtl"; voice="Chapter 3\c3s5" },
    @{ ch="Chapter 3"; dtl="c3s6.dtl"; voice="Chapter 3\c3s6" },
    @{ ch="Chapter 4"; dtl="c4s0.dtl"; voice="Chapter 4\C4S0" },
    @{ ch="Chapter 4"; dtl="c4s1.dtl"; voice="Chapter 4\C4S1" },
    @{ ch="Chapter 4"; dtl="c4s2.dtl"; voice="Chapter 4\C4S2" },
    @{ ch="Chapter 4"; dtl="c4s3.dtl"; voice="Chapter 4\C4S3" },
    @{ ch="Chapter 4"; dtl="c4s4.dtl"; voice="Chapter 4\c4S4" },
    @{ ch="Chapter 4"; dtl="c4s5.dtl"; voice="Chapter 4\C4S5" },
    @{ ch="Chapter 4"; dtl="c4s6.dtl"; voice="Chapter 4\C4S6" },
    @{ ch="Chapter 5"; dtl="c5s0.dtl"; voice="Chapter 5\C5S0" },
    @{ ch="Chapter 5"; dtl="c5s1.dtl"; voice="Chapter 5\C5S1" },
    @{ ch="Chapter 5"; dtl="c5s2.dtl"; voice="Chapter 5\c5s2" },
    @{ ch="Chapter 5"; dtl="c5s3.dtl"; voice="Chapter 5\c5s3" },
    @{ ch="Chapter 5"; dtl="c5s4.dtl"; voice="Chapter 5\C5S4" },
    @{ ch="Chapter 5"; dtl="c5s5.dtl"; voice="Chapter 5\C5S5" }
)

$COMMAND_PREFIXES = @('[', 'if ', 'elif ', 'else:', 'set ', 'join ', 'leave ', 'update ', 'jump ', 'label ', '-', '#', '...')

function Is-Narration($line) {
    $stripped = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($stripped)) { return $false }
    foreach ($p in $COMMAND_PREFIXES) {
        if ($stripped.StartsWith($p)) { return $false }
    }
    # Character dialogue: Word(s): pattern
    if ($stripped -match '^[A-Za-z][A-Za-z\s\.\-]*:') { return $false }
    return $true
}

function Is-ElevenLabs($filename) {
    return $filename -match '^ElevenLabs_'
}

$totalInjections = 0

foreach ($scene in $SCENE_MAP) {
    $dtlPath = "$TIMELINE_BASE\$($scene.ch)\$($scene.dtl)"
    $voiceDir = "$VOICE_BASE\$($scene.voice)"
    $resVoiceBase = "res://assets/audio/voice/" + ($scene.voice -replace '\\', '/')

    Write-Host "`n=== $($scene.ch)/$($scene.dtl) ==="

    if (-not (Test-Path $dtlPath)) {
        Write-Host "  DTL NOT FOUND: $dtlPath"
        continue
    }
    if (-not (Test-Path $voiceDir)) {
        Write-Host "  VOICE DIR NOT FOUND: $voiceDir"
        continue
    }

    $mp3Files = Get-ChildItem -Path $voiceDir -Filter "*.mp3" | Where-Object { -not (Is-ElevenLabs $_.Name) } | Sort-Object Name

    if ($mp3Files.Count -eq 0) {
        Write-Host "  No usable MP3 files found"
        continue
    }

    $lines = [System.IO.File]::ReadAllLines($dtlPath, [System.Text.Encoding]::UTF8)
    $resultLines = [System.Collections.ArrayList]@($lines)
    $injections = 0
    $offset = 0

    foreach ($mp3 in $mp3Files) {
        $searchText = $mp3.BaseName  # filename without .mp3
        # Normalize _s -> 's
        $searchNorm = $searchText -replace '_s ', "'s " -replace "_s'", "'s'"
        $resPath = "$resVoiceBase/$($mp3.Name)"

        # Find matching narration lines in original lines
        $matchedOrigIdx = @()
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if (-not (Is-Narration $lines[$i])) { continue }
            $content = $lines[$i].Trim()
            if ($content -like "*$searchText*" -or $content -like "*$searchNorm*") {
                $matchedOrigIdx += $i
            }
        }

        foreach ($origIdx in $matchedOrigIdx) {
            $resultIdx = $origIdx + $offset
            # Check if voice already injected above
            if ($resultIdx -gt 0) {
                $prev = $resultLines[$resultIdx - 1].Trim()
                if ($prev.StartsWith('[voice ')) {
                    Write-Host "  SKIP (already injected): $($mp3.Name)"
                    continue
                }
            }
            $narLine = $resultLines[$resultIdx]
            $indentLen = $narLine.Length - $narLine.TrimStart().Length
            $indent = $narLine.Substring(0, $indentLen)
            $voiceTag = "$indent[voice path=`"$resPath`" volume=0 bus=`"Master`"]"
            $resultLines.Insert($resultIdx, $voiceTag)
            $offset++
            $injections++
            $preview = $narLine.Trim()
            if ($preview.Length -gt 60) { $preview = $preview.Substring(0, 60) + "..." }
            Write-Host "  INJECT: $($mp3.Name) -> line $($origIdx+1): $preview"
        }
    }

    if ($injections -gt 0) {
        [System.IO.File]::WriteAllLines($dtlPath, $resultLines, [System.Text.Encoding]::UTF8)
    }
    Write-Host "  Total injected: $injections"
    $totalInjections += $injections
}

Write-Host "`n=== GRAND TOTAL: $totalInjections voice tags injected ==="
