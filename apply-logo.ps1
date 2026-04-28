$base = "C:\Users\rodrigo.shantilal\Desktop\rounds"
$utf8 = [System.Text.UTF8Encoding]::new($false)
$rx   = [System.Text.RegularExpressions.Regex]
$so   = [System.Text.RegularExpressions.RegexOptions]::Singleline

$logoPattern = '<div class="nav-logo-wrap">\s*<span class="logo-main">ROUNDS</span>\s*<span class="logo-sub">Academy</span>\s*</div>'
$heroPattern = '<h1 class="hero-title">\s*<span class="line-1">ROUNDS</span>\s*<span class="line-2">ACADEMY</span>\s*</h1>'

$files = Get-ChildItem -Path $base -Recurse -Filter *.html |
    ForEach-Object { $_.FullName.Substring($base.Length + 1).Replace('\','/') }

foreach ($f in $files) {
    $path    = Join-Path $base ($f -replace '/', '\')
    $content = [System.IO.File]::ReadAllText($path, $utf8)
    $orig    = $content

    # Image path relative to this file
    $depth   = ($f -split '/').Count - 1
    $imgPath = ("../" * $depth) + "images/simbolorounds.png"
    $logoImg = "<img src=`"$imgPath`" alt=`"Rounds Academy`" class=`"site-logo-img`">"

    # Replace all nav-logo-wrap / footer nav-logo-wrap with the image
    $content = $rx::Replace($content, $logoPattern, $logoImg, $so)

    # On index pages only: replace the big hero title with the logo
    if ($f -match '(?:^|/)index\.html$') {
        $heroRepl = "<div class=`"hero-logo-wrap`">$logoImg</div>"
        $content  = $rx::Replace($content, $heroPattern, $heroRepl, $so)
    }

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($path, $content, $utf8)
        Write-Host "Updated: $f"
    }
}

Write-Host "`nDone."
