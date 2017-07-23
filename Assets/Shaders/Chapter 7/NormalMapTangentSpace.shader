
// 法线纹理，切线空间下
Shader "Custom/Chapter 7/NormalMapTangentSpace" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Bump Map", 2D) = "bump" {}		// bump:内置法线纹理
		_BumpScale ("Bump Scale",Float) = 1.0		// 凹凸程度：0为没影响
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
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;	// xy存主纹理的纹理坐标
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;	// zw存凹凸感的纹理坐标

				//float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;	// 副切线
				//float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				TANGENT_SPACE_ROTATION;			// 等价上面两句。在UnityCG.cginc

				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;	// 获取模型空间下的光照和视角，转换到切线空间
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangetViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;

				// 如果法线纹理类型没有设置成Normal map
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;	// 像素映射回法线，乘于凹凸程度
				//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				// 设置了Normal map类型
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;		// 获取纹理和其坐标计算纹理值，乘于颜色，作为反射率
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;		// 反射率和环境光相乘得到环境光部分
				fixed3 diffuse = _LightColor0.rbg * albedo * max(0,dot(tangentNormal,tangentLightDir));	// 漫反射公式
				fixed3 halfDir = normalize(tangentLightDir + tangetViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);//BlinnPhong
				return fixed4(ambient + diffuse + specular,1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}
