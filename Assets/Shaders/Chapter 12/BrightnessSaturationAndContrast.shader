
Shader "Custom/Chapter 12/Brightness Saturation And Contrast" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Brightness ("Brightness", Float) = 1		// 下面这三个值从脚本传入
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
	SubShader {
		Pass { 
			// 关掉深度写入，避免挡住后面物体渲染，（如果OnRenderImage在所有不透明Pass后直接执行（而非所有都渲染完）） 
			ZTest Always Cull Off ZWrite Off
			
			CGPROGRAM  
			#pragma vertex vert  
			#pragma fragment frag  
			  
			#include "UnityCG.cginc"  
			  
			sampler2D _MainTex;  
			half _Brightness;
			half _Saturation;
			half _Contrast;
			  
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv: TEXCOORD0;
			};
			  
			// appdata_img ：在UnityCG.cginc中，只包含图像处理的顶点和纹理坐标
			v2f vert(appdata_img v) {
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv = v.texcoord;
						 
				return o;
			}
		
			fixed4 frag(v2f i) : SV_Target {
				fixed4 renderTex = tex2D(_MainTex, i.uv);  
				  
				// 亮度
				fixed3 finalColor = renderTex.rgb * _Brightness;
				
				// 饱和度
				// 计算亮度值
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);	// 饱和度为0的颜色值
				finalColor = lerp(luminanceColor, finalColor, _Saturation);	
				
				// 对比度
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);		// 对比度为0的颜色值
				finalColor = lerp(avgColor, finalColor, _Contrast);
				
				return fixed4(finalColor, renderTex.a);  
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
