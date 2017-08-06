using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 程序纹理生成
/// </summary>
[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{

    public Material material = null;

    #region 材质属性面板设置
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth
    {
        get
        {
            return m_textureWidth;
        }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;
    public float blurFactor
    {
        get
        {
            return m_blurFactor;
        }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTexture = null;        // 保存生成的程序纹理

    /// <summary>
    /// 初始化材质
    /// </summary>
    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Cannot find a renderer.");
                return;
            }

            material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }

    /// <summary>
    /// 更新材质
    /// </summary>
    private void _UpdateMaterial()
    {
        if (material != null)
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }
    
    /// <summary>
    /// 混合插值颜色
    /// </summary>
    /// <param name="color0">颜色1</param>
    /// <param name="color1">颜色2</param>
    /// <param name="mixFactor">混合因子</param>
    /// <returns></returns>
    private Color _MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    /// <summary>
    /// 生成程序纹理
    /// </summary>
    /// <returns>纹理</returns>
    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4.0f;             // 圆于圆之间的间距
        float radius = textureWidth / 10.0f;                    // 圆的半径
        float edgeBlur = 1.0f / blurFactor;                     // 模糊系数

        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;                  // 背景颜色初始化

                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        // 计算每个圆的圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));

                        // 当前像素与圆心的距离
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        // 模糊圆的边界
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));

                        // 与之前的颜色混合
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }

                proceduralTexture.SetPixel(w, h, pixel);
            }
        }

        proceduralTexture.Apply();

        return proceduralTexture;
    }
}
