Add-Type -AssemblyName System.Drawing

$drawingAssembly = [System.Drawing.Image].Assembly.Location

Add-Type @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public class BgRemover {
    public static void Remove(string path, int minBrightness, int maxVariance) {
        Bitmap bmp = new Bitmap(path);
        Rectangle rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
        BitmapData data = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        int stride = data.Stride;
        byte[] px = new byte[stride * bmp.Height];
        Marshal.Copy(data.Scan0, px, 0, px.Length);
        for (int i = 0; i < px.Length; i += 4) {
            int b = px[i], g = px[i+1], r = px[i+2];
            int avg = (r + g + b) / 3;
            int variance = Math.Abs(r-avg) + Math.Abs(g-avg) + Math.Abs(b-avg);
            if (avg >= minBrightness && variance <= maxVariance)
                px[i+3] = 0;
        }
        Marshal.Copy(px, 0, data.Scan0, px.Length);
        bmp.UnlockBits(data);
        string tmp = path + ".tmp.png";
        bmp.Save(tmp, ImageFormat.Png);
        bmp.Dispose();
        System.IO.File.Delete(path);
        System.IO.File.Move(tmp, path);
    }
}
"@ -ReferencedAssemblies $drawingAssembly

$path = "C:\Users\rodrigo.shantilal\Desktop\rounds\images\simbolorounds.png"
[BgRemover]::Remove($path, 175, 25)

$bmp = [System.Drawing.Bitmap]::new($path)
$tl = $bmp.GetPixel(0,0); $tr = $bmp.GetPixel($bmp.Width-1,0)
Write-Host "Top-left alpha:  $($tl.A)  (0 = transparent)"
Write-Host "Top-right alpha: $($tr.A)  (0 = transparent)"
$bmp.Dispose()
Write-Host "Done."
