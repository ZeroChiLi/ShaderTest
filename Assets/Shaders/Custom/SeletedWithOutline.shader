
Shader "Custom/SeletedWithOutline" {
	Properties {
        _MainTex("Base (RGB)", 2D) = "white" {}  
        _BlurTex("Blur", 2D) = "white"{}  
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		CGINCLUDE  
		#include "UnityCG.cginc"  
        fixed4 _OutlineCol;  
      
        struct v2f  
        {  
            float4 pos : SV_POSITION;  
        };  
              
        v2f vert(appdata_full v)  
        {  
            v2f o;  
            o.pos = UnityObjectToClipPos(v.vertex);  
            return o;  
        }  
              
        fixed4 frag(v2f i) : SV_Target  
        {  
            //这个Pass直接输出描边颜色  
            return fixed4(1,0,0,1);  
        }  

		//用于剔除中心留下轮廓  
		struct v2f_cull  
		{  
			float4 pos : SV_POSITION;  
			float2 uv : TEXCOORD0;  
		};  
  
		//用于最后叠加  
		struct v2f_add  
		{  
			float4 pos : SV_POSITION;  
			float2 uv  : TEXCOORD0;  
			float2 uv1 : TEXCOORD1;  
		};  
  
		sampler2D _MainTex;  
		float4 _MainTex_TexelSize;  
		sampler2D _BlurTex;  
		float4 _BlurTex_TexelSize;  
		float4 _offsets;  
  
		//Blur图和原图进行相减获得轮廓  
		v2f_cull vert_cull(appdata_img v)  
		{  
			v2f_cull o;  
			o.pos = UnityObjectToClipPos(v.vertex);  
			o.uv = v.texcoord.xy;  
			//dx中纹理从左上角为初始坐标，需要反向  
			#if UNITY_UV_STARTS_AT_TOP  
			if (_MainTex_TexelSize.y < 0)  
				o.uv.y = 1 - o.uv.y;  
			#endif    
			return o;  
		}  
  
		fixed4 frag_cull(v2f_cull i) : SV_Target  
		{  
			fixed4 colorMain = tex2D(_MainTex, i.uv);  
			fixed4 colorBlur = tex2D(_BlurTex, i.uv);  
			//最后的颜色是_BlurTex - _MainTex，周围0-0=0，黑色；边框部分为描边颜色-0=描边颜色；中间部分为描边颜色-描边颜色=0。最终输出只有边框  
			//return fixed4((colorBlur - colorMain).rgb, 1);  
			return colorBlur - colorMain;  
		}  

		
		//最终叠加 vertex shader  
		v2f_add vert_add(appdata_img v)  
		{  
			v2f_add o;  
			o.pos = UnityObjectToClipPos(v.vertex);  
			o.uv.xy = v.texcoord.xy;  
			o.uv1.xy = o.uv.xy;  
			#if UNITY_UV_STARTS_AT_TOP  
			if (_MainTex_TexelSize.y < 0)  
				o.uv.y = 1 - o.uv.y;  
			#endif    
			return o;  
		}  
  
		fixed4 frag_add(v2f_add i) : SV_Target  
		{  
			//取原始场景图片进行采样  
			fixed4 ori = tex2D(_MainTex, i.uv1);  
			//取得到的轮廓图片进行采样  
			fixed4 blur = tex2D(_BlurTex, i.uv);  
			//输出：直接叠加  
			fixed4 final = ori + blur;  
			return final;  
		}  
  
        ENDCG  

		Pass  
        {     
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            ENDCG  
        }  

		UsePass "Custom/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"

		UsePass "Custom/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"
		
        Pass  
        {  
            ZTest Off  
            Cull Off  
            ZWrite Off  
            Fog{ Mode Off }  
  
            CGPROGRAM  
            #pragma vertex vert_cull  
            #pragma fragment frag_cull  
            ENDCG  
        }  

        Pass  
        {  
  
            ZTest Off  
            Cull Off  
            ZWrite Off  
            Fog{ Mode Off }  
  
            CGPROGRAM  
            #pragma vertex vert_add  
            #pragma fragment frag_add  
            ENDCG  
        }  
	} 
	FallBack Off
}
