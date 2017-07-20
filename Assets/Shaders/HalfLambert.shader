
// 半兰伯特模型，相对逐像素漫反射，增强了黑暗处的光照效果
Shader "Custom/Chapter 6/halfLambert" {
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
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);	

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				// 将原本n·l的[-1,1]映射到[0,1]，两个常量可以变，通常都是两个0.5
				fixed halfLambert = dot(worldNormal,worldLight) * 0.5 + 0.3;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}

 			ENDCG
		}
	}
	FallBack "Diffuse"
}
