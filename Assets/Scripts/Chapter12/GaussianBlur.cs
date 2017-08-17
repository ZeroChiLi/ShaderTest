using UnityEngine;

/// <summary>
/// 高斯模糊
/// </summary>
public class GaussianBlur : PostEffectsBase
{

    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;

    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;                  // 模糊迭代次数

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;             // 模糊范围，过大会造成虚影

    [Range(1, 8)]
    public int downSample = 2;                  // 缩放系数。越大，处理像素越少，过大可能会像素化

    /// 版本1（不调用）： 普通模糊
    void OnRenderImage1(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            int rtW = src.width;
            int rtH = src.height;
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0); // 屏幕大小的缓冲区，存第一个Pass执行后的模糊结果

            // 渲染第一个竖直Pass，存到buffer
            Graphics.Blit(src, buffer, material, 0);
            // 渲染第二个水平Pass，送到屏幕
            Graphics.Blit(buffer, dest, material, 1);

            RenderTexture.ReleaseTemporary(buffer);         // 释放掉缓冲
        }
        else
            Graphics.Blit(src, dest);
    }

    /// 版本2（不调用）： 加上缩放系数
    void OnRenderImage2(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            int rtW = src.width / downSample;           // 使用小于原屏幕尺寸，减少处理像素个数，提高性能，可能更好模糊效果
            int rtH = src.height / downSample;
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

            buffer.filterMode = FilterMode.Bilinear;    // 滤波设置双线性。

            Graphics.Blit(src, buffer, material, 0);
            Graphics.Blit(buffer, dest, material, 1);

            RenderTexture.ReleaseTemporary(buffer);
        }
        else
            Graphics.Blit(src, dest);
    }

    /// 版本3 ： 使用迭代
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);                            // 用到所有Pass块

            // buffer0 存将要被处理的缓存，buffer1存搞好的
            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 0);       // 竖直，存到buffer1中

                RenderTexture.ReleaseTemporary(buffer0);            // 放掉buffer0，重新存入竖直
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);  // 把buffer1存入水平

                Graphics.Blit(buffer0, buffer1, material, 1);       

                RenderTexture.ReleaseTemporary(buffer0);            // 再放掉buufer0，重新存入水平
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
