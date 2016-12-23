Shader "Custom/Surface01" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_LogoTex ("Logo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_GlossinessLogo ("Smoothness logo", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ScrollSpeedHorizontal ("Horizontal scroll speed", Range(-1, 1)) = 0.1
		_ScrollSpeedVertical ("Vertical scroll speed", Range(-1, 1)) = 0.1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		#pragma target 5.0

		sampler2D _MainTex;
		sampler2D _LogoTex;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_LogoTex;
		};

		float _Glossiness;
		float _GlossinessLogo;
		float _Metallic;
		float4 _Color;
		float _ScrollSpeedHorizontal;
		float _ScrollSpeedVertical;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 logoColor = tex2D(_LogoTex, IN.uv_LogoTex);
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex + _Time.y * 
							float2(_ScrollSpeedHorizontal, _ScrollSpeedVertical));
			c.rgb = lerp(c.rgb, c.rgb* _Color, logoColor.a);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			//o.Smoothness = _Glossiness*logoColor.a;
			o.Smoothness = lerp(_Glossiness, _GlossinessLogo, logoColor.a);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
