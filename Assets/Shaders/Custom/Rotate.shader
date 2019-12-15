Shader "Custom/Rotate"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Speed("Speed",float) = 1
	}
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _Speed;

			fixed4 frag (v2f i) : SV_Target
			{
				// 坐标转到原点，原点为中心旋转
				i.uv -= float2(0.5, 0.5);

				float2 tempUV = i.uv;

				//// 超出UV范围
				//if (length(tempUV) > 0.5)
				//{
				//	return fixed4(0, 0, 0, 0);
				//}

				// 绕z轴旋转
				i.uv.x = cos(_Speed * _Time.y) * tempUV.x - sin(_Speed * _Time.y) * tempUV.y;
				i.uv.y = sin(_Speed * _Time.y) * tempUV.x + cos(_Speed * _Time.y) * tempUV.y;

				if (abs(i.uv.x) > 0.5 || abs(i.uv.y) > 0.5)
				{
					return fixed4(0, 0, 0, 0);
				}

				// 恢复坐标
				i.uv += float2(0.5, 0.5);

				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}
			ENDCG
		}
	}
}
