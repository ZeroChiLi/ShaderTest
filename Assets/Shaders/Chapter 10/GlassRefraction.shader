
// 玻璃纹理模拟
Shader "Custom/Chapter 10/Glass Refraction" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}						// 法线纹理
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}		// 反射纹理
		_Distortion ("Distortion", Range(0, 100)) = 10				// 折射扭曲程度
		_RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0	// 控制折射程度（0:只反射，1：只折射）
	}
	SubShader {
		// Transparent：在所有不透明物体渲染后再渲染。Opaque：确保在着色器替换时，该物体在需要时正确渲染。
		Tags { "Queue"="Transparent" "RenderType"="Opaque" }
		
		// 抓取屏幕图像的Pass，存入到纹理变量中。
		GrabPass { "_RefractionTex" }
		
		Pass {		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;			// 对应GrabPass指定的纹理名
			float4 _RefractionTex_TexelSize;	// 纹理大小。如256x512的纹理，值为（1/256, 1/512）

			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4; 
			};
			
			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.scrPos = ComputeGrabScreenPos(o.pos);			// 计算抓取的屏幕图像采样坐标，在UnityCG.cginc中定义。
				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);	// 计算采样坐标
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				// 把法线方向从切线空间转到世界空间
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {		
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				// 获取切线空间下的法线方向
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));	
				
				// 对屏幕图像采样坐标进行偏移，模拟折射
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;		// 透射除法 4.9.3
				
				// 法线再转到世界空间
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				// 计算反射方向
				fixed3 reflDir = reflect(-worldViewDir, bump);
				// 主纹理的采样，和立方体纹理的采样
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
				
				fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
				
				return fixed4(finalColor, 1);
			}
			
			ENDCG
		}
	}
	
	FallBack "Diffuse"
}
