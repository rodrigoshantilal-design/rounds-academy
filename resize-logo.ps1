Add-Type -AssemblyName System.Drawing
$drawingAssembly = [System.Drawing.Image].Assembly.Location

Add-Type @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public class ImgResize {
    public static void Resize(string src, string dst, int size) {
        var orig = new Bitmap(src);
        var resized = new Bitmap(size, size, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(resized)) {
            g.InterpolationMode  = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            g.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
            g.SmoothingMode      = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            g.Clear(Color.Transparent);
            g.DrawImage(orig, 0, 0, size, size);
        }
        orig.Dispose();
        resized.Save(dst, ImageFormat.Png);
        resized.Dispose();
    }
}
"@ -ReferencedAssemblies $drawingAssembly

$src = "C:\Users\rodrigo.shantilal\Desktop\rounds\images\simbolorounds.png"
$tmp = "C:\Users\rodrigo.shantilal\Desktop\rounds\images\simbolorounds_resized.png"

[ImgResize]::Resize($src, $tmp, 600)

$before = [math]::Round((Get-Item $src).Length / 1KB, 1)
$after  = [math]::Round((Get-Item $tmp).Length / 1KB, 1)
Write-Host "Before: ${before} KB  →  After: ${after} KB"

Remove-Item $src
Rename-Item $tmp $src
Write-Host "Done."
