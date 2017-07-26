
// 开启深度写入的透明混合
Shader "Custom/Chapter 8/AlphaBlendZWrite" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0,1)) = 1
	}
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		// 新加一个Pass块，先把深度信息写入深度缓冲，剔除掉了被自身遮挡的片元。
		Pass {
			ZWrite On
			ColorMask 0			// 颜色通道掩码。为0：不写入任何颜色通道，不输出任何颜色。
		}

		Pass {
			Tags { "LightMode"="ForwardBase" }

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
		
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
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rbg * albedo * max(0,dot(worldNormal,worldLightDir));
				return fixed4(ambient + diffuse,texColor.a * _AlphaScale);				
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
