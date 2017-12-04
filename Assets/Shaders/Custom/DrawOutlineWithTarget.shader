
Shader "Custom/DrawOutlineWithTarget" {
	Properties {
		_Color ("Outline Color", Color) = (0,0,0,1)
		_Width ("Outline Width", Float) = 0.5
	}
	SubShader {
		Tags { "Queue" = "Transparent" }
		Pass {
			Cull Front

            CGPROGRAM
     
			fixed4 _Color;
			float _Width;
 
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
             
            struct v2f 
            {
                float4 pos : SV_POSITION;
            };
             
            v2f vert (appdata_base v) 
            {
                v2f o;
				v.vertex.xyz += v.normal.xyz * _Width;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

			half4 frag(v2f i) :COLOR {
				return _Color;
			}
			ENDCG
		}
	}
 
	Fallback OFF
}