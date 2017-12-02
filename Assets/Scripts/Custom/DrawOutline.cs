using UnityEngine;

public class DrawOutline : PostEffectsBase
{
    public Camera additionalCamera;

    [Range(1, 8)]
    public int downSample = 2;                  // 减少采样倍数的平方。越大，处理像素越少，过大可能会像素化

    public Shader drawSimple;

    public Color outlineColor = Color.green;

    private void Awake()
    {
        SetupAddtionalCamera();
    }

    private void SetupAddtionalCamera()
    {
        additionalCamera.CopyFrom(MainCamera);
        additionalCamera.clearFlags = CameraClearFlags.Color;
        additionalCamera.backgroundColor = Color.black;
        additionalCamera.cullingMask = 1 << LayerMask.NameToLayer("Outline");
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (TargetMaterial != null && drawSimple != null && additionalCamera != null)
        {
            RenderTexture TempRT = RenderTexture.GetTemporary(source.width, source.height, 0);
            TempRT.Create();
            additionalCamera.targetTexture = TempRT;

            TargetMaterial.SetTexture("_SceneTex", source);
            TargetMaterial.SetColor("_Color", outlineColor);

            additionalCamera.RenderWithShader(drawSimple, "");

            Graphics.Blit(TempRT, destination, TargetMaterial, 0);

            TempRT.Release();
        }
        else
            Graphics.Blit(source, destination);
    }

}
