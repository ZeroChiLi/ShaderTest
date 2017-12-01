Shader "Custom/DrawSimple"
{
    SubShader 
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            struct v2f
            {
                float4 pos:SV_POSITION;
            };
 
            v2f vert(v2f i)
            {
                v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target  
            {
                return fixed4(1,0,0,1);  
            }
 
            ENDCG
        }
    }
}