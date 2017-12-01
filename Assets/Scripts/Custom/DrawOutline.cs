using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOutline : PostEffectsBase
{
    public Camera additionalCamera;
    public MeshFilter targetMesh;

    public Shader postOutline;
    public Shader drawSimple;

    [Range(0, 2)]
    public float outlineWidth = 3f;
    public Color outlineColor = Color.green;


    [Range(0, 4)]
    public int iterations = 3;                  // 模糊迭代次数
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;             // 模糊范围，过大会造成虚影
    [Range(1, 8)]
    public int downSample = 2;                  // 减少采样倍数的平方。越大，处理像素越少，过大可能会像素化

    private RenderTexture temRT;

    private void Awake()
    {
        SetupAddtionalCamera();
    }

    void OnEnable()
    {
        SetupAddtionalCamera();
        additionalCamera.enabled = true;
    }

    void OnDisable()
    {
        additionalCamera.enabled = false;
    }

    void OnDestroy()
    {
        if (temRT)
            RenderTexture.ReleaseTemporary(temRT);
        DestroyImmediate(additionalCamera.gameObject);
    }


    private void SetupAddtionalCamera()
    {
        //addtionalCamera.CopyFrom(MainCamera);
        //addtionalCamera.clearFlags = CameraClearFlags.Color;
        //addtionalCamera.backgroundColor = Color.black;
        //addtionalCamera.cullingMask = 1 << LayerMask.NameToLayer("Outline");


        if (additionalCamera)
        {
            additionalCamera.transform.parent = MainCamera.transform;
            additionalCamera.transform.localPosition = Vector3.zero;
            additionalCamera.transform.localRotation = Quaternion.identity;
            additionalCamera.transform.localScale = Vector3.one;
            additionalCamera.farClipPlane = MainCamera.farClipPlane;
            additionalCamera.nearClipPlane = MainCamera.nearClipPlane;
            additionalCamera.fieldOfView = MainCamera.fieldOfView;
            additionalCamera.backgroundColor = Color.clear;
            additionalCamera.clearFlags = CameraClearFlags.Color;
            additionalCamera.cullingMask = 1 << LayerMask.NameToLayer("Outline");
            additionalCamera.depth = -999;
            if (temRT == null)
                temRT = RenderTexture.GetTemporary(additionalCamera.pixelWidth >> downSample, additionalCamera.pixelHeight >> downSample, 0);
        }
    }

    private void OnPreRender()
    {
        if (additionalCamera && additionalCamera.enabled)
        {
            //渲染到RT上  
            //首先检查是否需要重设RT，比如屏幕分辨率变化了  
            if (temRT != null && (temRT.width != Screen.width >> downSample || temRT.height != Screen.height >> downSample))
            {
                RenderTexture.ReleaseTemporary(temRT);
                temRT = RenderTexture.GetTemporary(Screen.width >> downSample, Screen.height >> downSample, 0);
            }
            additionalCamera.targetTexture = temRT;
            additionalCamera.RenderWithShader(drawSimple, "");
        }
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (TargetMaterial && temRT)
        {

            //temRT.width = 111;  
            //对RT进行Blur处理  
            RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);
            RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);

            //高斯模糊，两次模糊，横向纵向，使用pass0进行高斯模糊  
            TargetMaterial.SetVector("_offsets", new Vector4(0, blurSpread, 0, 0));
            Graphics.Blit(temRT, temp1, TargetMaterial, 0);
            TargetMaterial.SetVector("_offsets", new Vector4(blurSpread, 0, 0, 0));
            Graphics.Blit(temp1, temp2, TargetMaterial, 0);

            //如果有叠加再进行迭代模糊处理  
            for (int i = 0; i < iterations; i++)
            {
                TargetMaterial.SetVector("_offsets", new Vector4(0, blurSpread, 0, 0));
                Graphics.Blit(temp2, temp1, TargetMaterial, 0);
                TargetMaterial.SetVector("_offsets", new Vector4(blurSpread, 0, 0, 0));
                Graphics.Blit(temp1, temp2, TargetMaterial, 0);
            }

            //用模糊图和原始图计算出轮廓图  
            TargetMaterial.SetTexture("_BlurTex", temp2);
            Graphics.Blit(temRT, temp1, TargetMaterial, 1);

            //轮廓图和场景图叠加  
            TargetMaterial.SetTexture("_BlurTex", temp1);
            Graphics.Blit(source, destination, TargetMaterial, 2);

            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
