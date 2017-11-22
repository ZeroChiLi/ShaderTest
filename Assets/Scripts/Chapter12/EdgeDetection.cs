using UnityEngine;
using System.Collections;

public class EdgeDetection : PostEffectsBase
{
	[Range(0.0f, 1.0f)]
	public float edgesOnly = 0.0f;              // 1为只显示边缘

	public Color edgeColor = Color.black;       // 边缘色
	
	public Color backgroundColor = Color.white; // 背景色

	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (TargetMaterial != null) {
			TargetMaterial.SetFloat("_EdgeOnly", edgesOnly);
			TargetMaterial.SetColor("_EdgeColor", edgeColor);
			TargetMaterial.SetColor("_BackgroundColor", backgroundColor);

			Graphics.Blit(src, dest, TargetMaterial);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
