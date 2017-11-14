// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


// 逐顶点漫反射
Shader "Custom/Chapter 6/DiffuseVertexLevel" {
	Properties {
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}				// 光照流水线，定义了才能得到一些内置光照变量

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"						// 后面用到 _LightColor0

			fixed4 _Diffuse;								// 声明属性变量
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;	
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;							// 获得环境光

				// 等价 UnityObjectToWorldNormal(v.normal)
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));	// 将法线从模型空间转到世界空间

				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);				// 光源方向（假设场景只有一个光源且为平行光）

				// _LightColor0：光源颜色和强度，saturate：把参数限制在[0,1]
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return fixed4(i.color,1.0);
			}

 			ENDCG
		}
	}
	FallBack "Diffuse"
}
