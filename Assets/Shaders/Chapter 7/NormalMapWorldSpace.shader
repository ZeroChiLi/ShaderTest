
// 法线纹理，世界空间下
Shader "Custom/Chapter 7/NormalMapWorldSpace" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Bump Map", 2D) = "bump" {}		// bump:内置法线纹理
		_BumpScale ("Bump Scale",Float) = -0.5		// 凹凸程度：0为没影响
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader {
		Pass {
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;		// S:scale, T:translation, _MainTex_ST.xy:缩放值, _MainTex_ST.zw:偏移值
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;		// 切线，不同于发现float3，tangent.w用来决定副切线的方向性。
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;		// 切线到世界空间变换矩阵3x3。w分量作为世界空间顶点位置
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;	// xy存主纹理的纹理坐标
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;	// zw存凹凸感的纹理坐标

				// 计算世界空间下的顶点切线、副切线、法线
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldNormal(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

				// 变换矩阵，类似转置，每一行按照列摆放
				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));	// 根号下 1 - (xy)2

				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));	// 转换到世界空间

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;		// 获取纹理和其坐标计算纹理值，乘于颜色，作为反射率
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;		// 反射率和环境光相乘得到环境光部分
				fixed3 diffuse = _LightColor0.rbg * albedo * max(0,dot(bump,lightDir));	// 漫反射公式
				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(bump,halfDir)),_Gloss);//BlinnPhong
				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
