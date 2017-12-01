using UnityEngine;

public class SeletedWithOutline : PostEffectsBase 
{
    [Range(0, 4)]
    public int iterations = 3;                  // 模糊迭代次数
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;             // 模糊范围，过大会造成虚影
    [Range(1, 8)]
    public int downSample = 2;                  // 减少采样倍数的平方。越大，处理像素越少，过大可能会像素化

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (TargetMaterial != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);

            // buffer0 存将要被处理的缓存，buffer1存搞好的
            for (int i = 0; i < iterations; i++)
            {
                TargetMaterial.SetFloat("_BlurSize", 1.0f + (i + 1) * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, TargetMaterial, 1);       // 竖直，存到buffer1中

                RenderTexture.ReleaseTemporary(buffer0);            // 放掉buffer0，重新存入竖直
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);  // 把buffer1存入水平

                Graphics.Blit(buffer0, buffer1, TargetMaterial, 2);

                RenderTexture.ReleaseTemporary(buffer0);            // 再放掉buffer0，重新存入水平
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
            Graphics.Blit(src, dest);
    }
}
