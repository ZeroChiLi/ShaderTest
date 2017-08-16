using UnityEngine;

/// <summary>
/// 对shader进行亮度、饱和度、对比度修改
/// </summary>
public class BrightnessSaturationAndContrast : PostEffectsBase
{

    public Shader briSatConShader;
    private Material briSatConMaterial;     // 获取shader的材质
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

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
        if (material != null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
