using UnityEngine;

/// <summary>
/// 边缘检测（法线和深度纹理上进行，之前的是对颜色处理）
/// </summary>
public class EdgeDetectNormalsAndDepth : PostEffectsBase
{
    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;         // 采样距离（描边宽度）

    public float sensitivityDepth = 1.0f;       // 深度灵敏度（差多会被认为是一条边）

    public float sensitivityNormals = 1.0f;     // 法线灵敏度

    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]     // 不透明物体渲染完后执行（不影响透明物体）
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (TargetMaterial != null)
        {
            TargetMaterial.SetFloat("_EdgeOnly", edgesOnly);
            TargetMaterial.SetColor("_EdgeColor", edgeColor);
            TargetMaterial.SetColor("_BackgroundColor", backgroundColor);
            TargetMaterial.SetFloat("_SampleDistance", sampleDistance);
            TargetMaterial.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));
        }
        Graphics.Blit(src, dest, TargetMaterial);
    }
}
