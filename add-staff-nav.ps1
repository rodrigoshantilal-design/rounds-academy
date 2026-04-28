$root = "C:\Users\rodri\Desktop\rounds"
$files = Get-ChildItem -Path $root -Recurse -Filter "*.html" |
  Where-Object { $_.FullName -notmatch "\\pt\\" -and $_.Name -notin @("staff.html") }

foreach ($file in $files) {
  $c = Get-Content $file.FullName -Raw -Encoding UTF8

  # PT root pages
  $c = $c -replace '(<li><a href="schedule\.html"[^>]*>[^<]+</a></li>)(<li><a href="contact\.html">Contacto</a></li>)',
    '$1<li><a href="staff.html">Staff</a></li>$2'

  # PT class pages (../ prefix)
  $c = $c -replace '(<li><a href="\.\./schedule\.html"[^>]*>[^<]+</a></li>)(<li><a href="\.\./contact\.html">Contacto</a></li>)',
    '$1<li><a href="../staff.html">Staff</a></li>$2'

  # EN root pages (en/ folder, no ../)
  $c = $c -replace '(<li><a href="schedule\.html"[^>]*>[^<]+</a></li>)(<li><a href="contact\.html">Contact</a></li>)',
    '$1<li><a href="staff.html">Staff</a></li>$2'

  # EN class pages (../ prefix)
  $c = $c -replace '(<li><a href="\.\./schedule\.html"[^>]*>[^<]+</a></li>)(<li><a href="\.\./contact\.html">Contact</a></li>)',
    '$1<li><a href="../staff.html">Staff</a></li>$2'

  Set-Content $file.FullName -Value $c -Encoding UTF8 -NoNewline
  Write-Host "Updated: $($file.Name)"
}
