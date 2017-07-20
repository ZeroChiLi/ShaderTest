
// 逐像素漫反射，类似逐顶点漫反射，不同处会有注释
Shader "Custom/Chapter 6/DiffusePixelLevel" {
	Properties {
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;				// 获取纹理坐标
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// 不需要计算光照模型，直接把世界空间法线传给着色器
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);	

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;					// 获取环境光
				
				fixed3 worldNormal = normalize(i.worldNormal);					// 获取世界坐标的法线

				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);		// 光源方向

				// _LightColor0：光源颜色和强度，saturate：把参数限制在[0,1]
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}

 			ENDCG
		}
	}
	FallBack "Diffuse"
}
