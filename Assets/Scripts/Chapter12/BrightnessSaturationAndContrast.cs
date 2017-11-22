using UnityEngine;

/// <summary>
/// 对shader进行亮度、饱和度、对比度修改
/// </summary>
public class BrightnessSaturationAndContrast : PostEffectsBase
{
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    /// <summary>
    /// 抓取屏幕图像
    /// </summary>
    /// <param name="src">源</param>
    /// <param name="dest">目标</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (TargetMaterial != null)
        {
            TargetMaterial.SetFloat("_Brightness", brightness);
            TargetMaterial.SetFloat("_Saturation", saturation);
            TargetMaterial.SetFloat("_Contrast", contrast);
        }
        Graphics.Blit(src, dest, TargetMaterial);
    }
}
