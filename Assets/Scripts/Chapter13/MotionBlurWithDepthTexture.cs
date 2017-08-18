using UnityEngine;

// 使用深度纹理计算运动模糊
public class MotionBlurWithDepthTexture : PostEffectsBase {

	public Shader motionBlurShader;
	private Material motionBlurMaterial = null;

	public Material material {  
		get {
			motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
			return motionBlurMaterial;
		}  
	}

	private Camera myCamera;
    public new Camera camera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

    [Range(0.0f, 1.0f)]
	public float blurSize = 0.5f;

	private Matrix4x4 previousViewProjectionMatrix;         // 上一帧摄像机的 视角x投影 矩阵
	
	void OnEnable() {
		camera.depthTextureMode |= DepthTextureMode.Depth;  // 摄像机的深度纹理

		previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			material.SetFloat("_BlurSize", blurSize);

            // 上一帧的矩阵
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);  

            // 投影矩阵 * 视角矩阵 ，再取逆
			Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse; 
			material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			previousViewProjectionMatrix = currentViewProjectionMatrix;

			Graphics.Blit (src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
