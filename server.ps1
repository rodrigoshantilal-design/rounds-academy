$root = 'C:\Users\rodrigo.shantilal\Desktop\rounds'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://localhost:7070/')
$listener.Start()
while ($true) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  $path = $req.Url.LocalPath.TrimStart('/')
  if ($path -eq '' -or $path -eq '/') { $path = 'index.html' }
  $file = Join-Path $root $path
  $res.Headers.Add('Cache-Control','no-store')
  $ext = [System.IO.Path]::GetExtension($file).ToLower()
  $mime = switch ($ext) {
    '.html' { 'text/html; charset=utf-8' }
    '.css'  { 'text/css' }
    '.js'   { 'application/javascript' }
    '.mp4'  { 'video/mp4' }
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.png'  { 'image/png' }
    '.svg'  { 'image/svg+xml' }
    '.ico'  { 'image/x-icon' }
    default { 'application/octet-stream' }
  }
  if (Test-Path $file -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $res.ContentType = $mime
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $res.StatusCode = 404
    $b = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
    $res.OutputStream.Write($b, 0, $b.Length)
  }
  $res.OutputStream.Close()
}
