// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter 5/FalseColor" {
	SubShader {
		Pass {
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
			};
			
			v2f vert(appdata_full v) {				// "UnityCG.cginc"中，Unity内置结构
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				//o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);		// 法线方向

				o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);	// 切线方向

				//fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				//o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);		// 副切线
				
				//o.color = fixed4(v.texcoord.xy, 0.0, 1.0);							// 第一组纹理坐标
				
				//o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);							// 第二组纹理坐标
				
				//o.color = frac(v.texcoord);											// 第一组纹理坐标小数部分
				//if (any(saturate(v.texcoord) - v.texcoord)) {
				//	o.color.b = 0.5;
				//}
				//o.color.a = 1.0;
				
				//o.color = frac(v.texcoord1);											// 第二组纹理坐标小数部分
				//if (any(saturate(v.texcoord1) - v.texcoord1)) {
				//	o.color.b = 0.5;
				//}
				//o.color.a = 1.0;
				
				//o.color = v.color;													// 顶点颜色
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				return i.color;
			}
			
			ENDCG
		}
	}
}