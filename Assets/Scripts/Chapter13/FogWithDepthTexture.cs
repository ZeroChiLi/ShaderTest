using UnityEngine;

/// <summary>
/// 雾效
/// </summary>
public class FogWithDepthTexture : PostEffectsBase
{
    private Camera targetCamera;
    public Camera TargetCamera { get { return targetCamera = targetCamera == null ? GetComponent<Camera>() : targetCamera; } }

    private Transform cameraTransform;
    public Transform CameraTransform { get { return cameraTransform = cameraTransform == null ? TargetCamera.transform : cameraTransform; } }

    [Range(0.0f, 3.0f)]
    public float fogDensity = 1.0f;         // 雾的密度

    public Color fogColor = Color.white;    // 雾的颜色

    public float fogStart = 0.0f;           // 起始高度
    public float fogEnd = 2.0f;             // 终止高度

    void OnEnable()
    {
        TargetCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (TargetMaterial != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;  // 存近裁切平面的四个角

            float fov = TargetCamera.fieldOfView;         // 竖直方向视角范围（角度）
            float near = TargetCamera.nearClipPlane;      // 近平面距离 
            float aspect = TargetCamera.aspect;           // 宽高比

            // 计算四个角对应的向量，存到frustumCorners
            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;
            Vector3 toTop = CameraTransform.up * halfHeight;

            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = CameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = CameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            TargetMaterial.SetMatrix("_FrustumCornersRay", frustumCorners);

            TargetMaterial.SetFloat("_FogDensity", fogDensity);
            TargetMaterial.SetColor("_FogColor", fogColor);
            TargetMaterial.SetFloat("_FogStart", fogStart);
            TargetMaterial.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(src, dest, TargetMaterial);
        }
        else
            Graphics.Blit(src, dest);
    }
}
