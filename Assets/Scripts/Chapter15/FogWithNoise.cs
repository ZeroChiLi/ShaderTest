using UnityEngine;
using System.Collections;

// 使用噪声的雾效
public class FogWithNoise : PostEffectsBase
{
    private Camera targetCamera;
    public Camera TargetCamera { get { return targetCamera = targetCamera == null ? GetComponent<Camera>() : targetCamera; } }

    private Transform cameraTransform;
    public Transform CameraTransform { get { return cameraTransform = cameraTransform == null ? TargetCamera.transform : cameraTransform; } }

    [Range(0.1f, 3.0f)]
    public float fogDensity = 1.0f;

    public Color fogColor = Color.white;

    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    public Texture noiseTexture;        // 噪声纹理

    [Range(-0.5f, 0.5f)]
    public float fogXSpeed = 0.1f;      // 移动速度

    [Range(-0.5f, 0.5f)]
    public float fogYSpeed = 0.1f;

    [Range(0.0f, 3.0f)]
    public float noiseAmount = 1.0f;    // 0为不用噪声，1为全局雾效

    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (TargetMaterial != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = TargetCamera.fieldOfView;
            float near = TargetCamera.nearClipPlane;
            float aspect = TargetCamera.aspect;

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

            TargetMaterial.SetTexture("_NoiseTex", noiseTexture);
            TargetMaterial.SetFloat("_FogXSpeed", fogXSpeed);
            TargetMaterial.SetFloat("_FogYSpeed", fogYSpeed);
            TargetMaterial.SetFloat("_NoiseAmount", noiseAmount);
            Graphics.Blit(src, dest, TargetMaterial);
        }
        else
            Graphics.Blit(src, dest);
    }
}
