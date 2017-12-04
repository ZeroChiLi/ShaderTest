
// 运动模糊（深度纹理）
Shader "Custom/Chapter 13/Motion Blur With Depth Texture" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;							// Unity传递过来的深度纹理
		float4x4 _CurrentViewProjectionInverseMatrix;			// 这两个矩阵上面属性没有提供这种属性，但可以在CG中定义，脚本设置
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurSize;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;
			
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif
					 
			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {
			// 深度值。通过摄像机的深度纹理和纹理坐标计算（映射）出来
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			// 构建像素的NDC坐标，xy像素的纹理坐标映射，
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			// 当前帧的 视角x投影 矩阵的逆矩阵变换
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			// 并除w得到世界空间坐标 
			float4 worldPos = D / D.w;
			
			// 当前视角位置 
			float4 currentPos = H;

			// 上一帧位置
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			previousPos /= previousPos.w;
			
			// 前一帧和当前帧位置差 求速度
			float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;
			
			// 邻域像素采样，相加求平均
			float2 uv = i.uv;
			float vecColRate[3] = { 0.7,0.2,0.1 };
			float4 c = tex2D(_MainTex, uv) * vecColRate[0];
			uv += velocity * _BlurSize;
			for (int it = 1; it < 3; it++, uv += velocity * _BlurSize) {
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor * vecColRate[it];
			}
			
			return fixed4(c.rgb, 1.0);
		}
		
		ENDCG
		
		Pass {      
			ZTest Always Cull Off ZWrite Off
			    	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment frag  
			  
			ENDCG  
		}
	} 
	FallBack Off
}
