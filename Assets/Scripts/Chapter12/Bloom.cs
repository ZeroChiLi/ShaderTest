using UnityEngine;
using System.Collections;

// 光晕（在高斯模糊基础上实现）
public class Bloom : PostEffectsBase {

	public Shader bloomShader;
	private Material bloomMaterial = null;
	public Material material {  
		get {
			bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
			return bloomMaterial;
		}  
	}

	[Range(0, 4)]
	public int iterations = 3;          // 模糊迭代次数
    
    [Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;     // 模糊跨度

    [Range(1, 8)]
	public int downSample = 2;          // 模糊大小

	[Range(0.0f, 4.0f)]
	public float luminanceThreshold = 0.6f;     // 亮度阈值（一般不超过1，开了HDR可以存更高精度）

	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			material.SetFloat("_LuminanceThreshold", luminanceThreshold);

			int rtW = src.width/downSample;
			int rtH = src.height/downSample;
			
			RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			buffer0.filterMode = FilterMode.Bilinear;
			
			Graphics.Blit(src, buffer0, material, 0);               // 直接先把第一个Pass的较亮区域存到buffer0
			
			for (int i = 0; i < iterations; i++) {
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
				
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				Graphics.Blit(buffer0, buffer1, material, 1);       // 第二个Pass，高斯模糊
				
				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				Graphics.Blit(buffer0, buffer1, material, 2);       // 第三个Pass
				
				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;
			}

			material.SetTexture ("_Bloom", buffer0);                // 较亮区域存到_Bloom
			Graphics.Blit (src, dest, material, 3);                 // 第四个Pass最后混合

			RenderTexture.ReleaseTemporary(buffer0);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
