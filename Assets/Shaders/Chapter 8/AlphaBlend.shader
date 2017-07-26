
// 透明混合
Shader "Custom/Chapter 8/AlphaBlend" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0,1)) = 1		// 整体透明度
	}
	SubShader {
		// 渲染队列：透明混合队列，在透明测试之后；不受投影器影响；指名这个Shader提前归入Transparent组。
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Pass {
			Tags { "LightMode"="ForwardBase" }

			ZWrite Off							// 关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha		// 开启混合模式。SrcAlpha：源颜色混合因子，OneMinusSrcAlpha：已存在颜色混合因子
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_TARGET {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex,i.uv);

				//clip(texColor.a - _Cutoff);					// 移除透明测试。

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rbg * albedo * max(0,dot(worldNormal,worldLightDir));
				return fixed4(ambient + diffuse,texColor.a * _AlphaScale);		// 透明通道乘于材质参数				
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
