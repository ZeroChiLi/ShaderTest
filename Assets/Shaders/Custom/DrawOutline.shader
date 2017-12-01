
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
      
        struct v2f  
        {  
            float4 pos : SV_POSITION;  
			float4 color : COLOR;  
        };  
              
        v2f vert(appdata_full v)  
        {  
            v2f o;
			//v.vertex.xyz += v.normal * _Outline;
            o.pos = UnityObjectToClipPos(v.vertex);  
			o.color = v.color;
            return o;  
        }  

        fixed4 frag_outline(v2f i) : SV_Target  
        {  
            return _OutlineColor;  
        }
		
		v2f vert_cull (appdata_full v) {
			v2f o;
				
			// 顶点和法线变换到视角空间下，让描边可以在观察空间达到最好的效果
			float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
			float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
			normal.z = -0.5;	// 让法线向视角方向外扩，避免物体有背面遮挡正面
			pos = pos + float4(normalize(normal), 0) * _Outline;		//对外扩展，出现轮廓
			o.pos = mul(UNITY_MATRIX_P, pos);
				
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
            #pragma vertex vert_cull  
            #pragma fragment frag  
            ENDCG  
		}
		
		//Pass  
  //      {     
  //          CGPROGRAM  
  //          #pragma vertex vert  
  //          #pragma fragment frag_outline  
  //          ENDCG  
  //      }  

	} 
	FallBack Off
}
