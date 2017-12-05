using UnityEngine;

public class DrawOutline1 : PostEffectsBase
{
    public Camera additionalCamera;

    public Shader drawOccupied;
    private Material occupiedMaterial = null;
    public Material OccupiedMaterial { get { return CheckShaderAndCreateMaterial(drawOccupied, ref occupiedMaterial); } }

    public Color outlineColor = Color.green;
    [Range(0, 10)]
    public int outlineWidth = 4;
    [Range(0, 9)]
    public int iterations = 1;

    public GameObject[] targets;

    private MeshFilter[] meshFilters;

    private void Awake()
    {
        SetupAddtionalCamera();
    }

    private void SetupAddtionalCamera()
    {
        additionalCamera.CopyFrom(MainCamera);
        additionalCamera.clearFlags = CameraClearFlags.Color;
        additionalCamera.backgroundColor = Color.black;
        //additionalCamera.cullingMask = 1 << LayerMask.NameToLayer("Outline");       // 只渲染"Outline"层的物体
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (TargetMaterial != null && drawOccupied != null && additionalCamera != null && targets != null)
        {
            RenderTexture TempRT = RenderTexture.GetTemporary(source.width, source.height, 0);
            additionalCamera.targetTexture = TempRT;

            for (int i = 0; i < targets.Length; i++)
            {
                if (targets[i] == null)
                    continue;
                meshFilters = targets[i].GetComponentsInChildren<MeshFilter>();
                for (int j = 0; j < meshFilters.Length; j++)
                    Graphics.DrawMesh(meshFilters[j].sharedMesh, meshFilters[j].transform.localToWorldMatrix, OccupiedMaterial, 0,additionalCamera);
            }
            additionalCamera.Render();

            //// 额外相机中使用shader，绘制出物体所占面积
            //additionalCamera.RenderWithShader(drawOccupied, "");

            TargetMaterial.SetTexture("_SceneTex", source);
            TargetMaterial.SetColor("_Color", outlineColor);
            TargetMaterial.SetInt("_Width", outlineWidth);
            TargetMaterial.SetInt("_Iterations", iterations);

            // 使用描边混合材质实现描边效果
            Graphics.Blit(TempRT, destination, TargetMaterial);

            TempRT.Release();
        }
        else
            Graphics.Blit(source, destination);
    }

}
