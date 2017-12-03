using UnityEngine;

public class DrawOutline : PostEffectsBase
{
    public Camera additionalCamera;
    public Shader drawSimple;

    public Color outlineColor = Color.green;
    [Range(0, 10)]
    public int outlineWidth = 4;
    [Range(0, 9)]
    public int iterations = 1;

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
            TargetMaterial.SetInt("_Width", outlineWidth);
            TargetMaterial.SetInt("_Iterations", iterations);

            additionalCamera.RenderWithShader(drawSimple, "");

            Graphics.Blit(TempRT, destination, TargetMaterial, 0);

            TempRT.Release();
        }
        else
            Graphics.Blit(source, destination);
    }

}
