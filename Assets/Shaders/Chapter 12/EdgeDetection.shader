
// 边缘检测
Shader "Custom/Chapter 12/Edge Detection" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Float) = 1.0							// 1：只要边缘
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass {  
			ZTest Always Cull Off ZWrite Off
			
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex vert  
			#pragma fragment fragSobel
			
			sampler2D _MainTex;  
			uniform half4 _MainTex_TexelSize;			// 访问_MainTex纹理对应的每个纹素大小。如一张512x512，值为 1/512
			fixed _EdgeOnly;
			fixed4 _EdgeColor;
			fixed4 _BackgroundColor;
			
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv[9] : TEXCOORD0;
			};
			  
			v2f vert(appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				half2 uv = v.texcoord;
				
				o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
				o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
				o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
				o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
				o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
				o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
				o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
				o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
						 
				return o;
			}
			
			// 亮度
			fixed luminance(fixed4 color) {
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
			}
			
			// Sobel算子采样，计算当前像的梯度值
			half Sobel(v2f i) {
				// 水平卷积核
				const half Gx[9] = {-1,  0,  1,
										-2,  0,  2,
										-1,  0,  1};
				const half Gy[9] = {-1, -2, -1,
										0,  0,  0,
										1,  2,  1};		
				
				half texColor;
				half edgeX = 0;		// 边缘值越大，越可能是边缘
				half edgeY = 0;
				for (int it = 0; it < 9; it++) {
					texColor = luminance(tex2D(_MainTex, i.uv[it]));
					edgeX += texColor * Gx[it];
					edgeY += texColor * Gy[it];
				}
				
				// 越小，越可能是边缘点
				half edge = 1 - abs(edgeX) - abs(edgeY);
				
				return edge;
			}
			
			fixed4 fragSobel(v2f i) : SV_Target {

				half edge = Sobel(i);
				
				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);	// 计算原图颜色值
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);			// 计算传入背景色颜色值
				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);						// 插值
 			}
			
			ENDCG
		} 
	}
	FallBack Off
}
