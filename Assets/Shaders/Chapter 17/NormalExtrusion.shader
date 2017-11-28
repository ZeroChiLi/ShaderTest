
// 法线膨胀
Shader "Custom/Chapter 17/Normal Extrusion" {
	Properties {
		_ColorTint ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_Amount ("Extrusion Amount", Range(-0.5, 0.5)) = 0.1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		
		// surf - 表面函数
		// CustomLambert - 光照模式（兰伯特漫反射）
		// vertex:myvert - 自定义顶点修改函数
		// finalcolor:mycolor - 自定义最后颜色修改函数
		// addshadow - 生成阴影捕获的Pass.因为修改了顶点位置，需要重新投射
		// exclude_path:deferred/exclude_path:prepass - 不要为延迟渲染路径生成相应的Pss
		// nometa - 不要生成元数据的Pass (that’s used by lightmapping & dynamic global illumination to extract surface information).
		#pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow exclude_path:deferred exclude_path:prepass nometa
		#pragma target 3.0
		
		fixed4 _ColorTint;
		sampler2D _MainTex;
		sampler2D _BumpMap;
		half _Amount;
		
		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};
		
		// 自定义顶点修改函数：把顶点延法线方向扩展。
		void myvert (inout appdata_full v) {
			v.vertex.xyz += v.normal * _Amount;
		}
		
		// 表面函数
		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Alpha = tex.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}
		
		// 自定义兰伯特光照
		half4 LightingCustomLambert (SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
			c.a = s.Alpha;
			return c;
		}
		
		// 自定义最后颜色修改函数
		void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
			color *= _ColorTint;
		}
		
		ENDCG
	}
	FallBack "Legacy Shaders/Diffuse"
}
