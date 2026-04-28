$root = "C:\Users\rodri\Desktop\rounds"
$files = Get-ChildItem -Path $root -Recurse -Filter "*.html" |
  Where-Object { $_.FullName -notmatch "\\pt\\" -and $_.Name -notin @("staff.html") }

foreach ($file in $files) {
  $c = Get-Content $file.FullName -Raw -Encoding UTF8

  # PT mobile menu root
  $c = $c -replace '(<a href="schedule\.html"[^>]*>Hor[^<]+</a>)(<a href="contact\.html">Contacto</a>)',
    '$1<a href="staff.html">Staff</a>$2'

  # PT mobile menu class pages (../)
  $c = $c -replace '(<a href="\.\./schedule\.html"[^>]*>Hor[^<]+</a>)(<a href="\.\./contact\.html">Contacto</a>)',
    '$1<a href="../staff.html">Staff</a>$2'

  # EN mobile menu root
  $c = $c -replace '(<a href="schedule\.html"[^>]*>Schedule</a>)(<a href="contact\.html">Contact</a>)',
    '$1<a href="staff.html">Staff</a>$2'

  # EN mobile menu class pages (../)
  $c = $c -replace '(<a href="\.\./schedule\.html"[^>]*>Schedule</a>)(<a href="\.\./contact\.html">Contact</a>)',
    '$1<a href="../staff.html">Staff</a>$2'

  Set-Content $file.FullName -Value $c -Encoding UTF8 -NoNewline
  Write-Host "Updated mobile: $($file.Name)"
}
