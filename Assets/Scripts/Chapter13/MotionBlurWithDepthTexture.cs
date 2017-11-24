using UnityEngine;

// 使用深度纹理计算运动模糊
public class MotionBlurWithDepthTexture : PostEffectsBase
{
    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;

    private Camera targetCamera;
    public Camera TargetCamera { get { return targetCamera = targetCamera == null ? GetComponent<Camera>() : targetCamera; } }

    private Matrix4x4 previousViewProjectionMatrix;         // 上一帧摄像机的 视角x投影 矩阵

    void OnEnable()
    {
        TargetCamera.depthTextureMode |= DepthTextureMode.Depth;  // 设置状态以获取摄像机的深度纹理
        previousViewProjectionMatrix = TargetCamera.projectionMatrix * TargetCamera.worldToCameraMatrix;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (TargetMaterial != null)
        {
            TargetMaterial.SetFloat("_BlurSize", blurSize);

            // 上一帧的矩阵
            TargetMaterial.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);

            // 投影矩阵 * 视角矩阵 ，用于给下一帧计算该帧时的位置
            Matrix4x4 currentViewProjectionMatrix = TargetCamera.projectionMatrix * TargetCamera.worldToCameraMatrix;
            // 矩阵取逆，用于计算该帧的位置
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            TargetMaterial.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;
        }
        Graphics.Blit(src, dest, TargetMaterial);
    }
}
