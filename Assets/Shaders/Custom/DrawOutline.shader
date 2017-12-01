
Shader "Custom/DrawOutline" {
	Properties {
        _MainTex("Base (RGB)", 2D) = "white" {}  
        _BlurTex("Blur", 2D) = "white"{}  
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		CGINCLUDE  
		#include "UnityCG.cginc"  
		
		float _Outline;
        fixed4 _OutlineColor;  
		sampler2D _MainTex;

        struct v2f  
        {  
            float4 pos : SV_POSITION;  
			float4 color : COLOR;  
			float2 uv : TEXCOORD0;

        };  
              
        v2f vert_outline(appdata_full v)  
        {  
            v2f o;
			v.vertex.xyz += v.normal * _Outline;
            o.pos = UnityObjectToClipPos(v.vertex);  
			//o.color = v.color;
            return o;  
        }  

        fixed4 frag_outline(v2f i) : SV_Target  
        {  
            return _OutlineColor;  
        }
		
		v2f vert (appdata_full v) {
			v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);  
			return o;
		}

        fixed4 frag(v2f i) : SV_Target  
        {
            return i.color;  
        }


		
        ENDCG  

		//UsePass "Custom/Chapter 14/Toon Shading/OUTLINE"
		
		Pass  
        {     
            CGPROGRAM  
            #pragma vertex vert_outline 
            #pragma fragment frag_outline  
            ENDCG  
        }  
		UsePass "Custom/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"
		UsePass "Custom/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"
		
		//GrabPass {"_MainTex"}

		//Pass
		//{
  //          CGPROGRAM  
  //          #pragma vertex vert  
  //          #pragma fragment frag  
  //          ENDCG  
		//}
		

	} 
	FallBack Off
}
