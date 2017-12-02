using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOutline : PostEffectsBase
{
    public Camera additionalCamera;
    public MeshFilter targetMesh;

    public Shader blurShader;
    private Material blurMaterial = null;
    public Material BlurMaterial { get { return CheckShaderAndCreateMaterial(blurShader, ref blurMaterial); } }

    public Shader outlineShader;
    private Material outlineMaterial = null;
    public Material OutlineMaterial { get { return CheckShaderAndCreateMaterial(outlineShader, ref outlineMaterial); } }

    public Shader drawSimple;

    [Range(0, 2)]
    public float outlineWidth = 1f;
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
        RenderTexture TempRT = new RenderTexture(source.width, source.height, 0, RenderTextureFormat.R8);
        TempRT.Create();
        additionalCamera.targetTexture = TempRT;
        OutlineMaterial.SetTexture("_SceneTex", source);
        OutlineMaterial.SetColor("_Color", outlineColor);

        additionalCamera.RenderWithShader(drawSimple, "");
        //Graphics.Blit(TempRT, destination);

        Graphics.Blit(TempRT, destination, OutlineMaterial, 0);


        TempRT.Release();

    }

}
