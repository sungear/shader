Shader "Custom/Surface03" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpTex("Normal", 2D) = "bump" {}
		_BumpIntensity("Normal intensity", Range(0.0, 2.0)) = 1.0
		_HorizontalOffset("Horizontal offset", float) = 0.0
		_VerticalOffset("Vertical offset", float) = 0.0
		_HorizontalOffset2("Horizontal offset 2", float) = 0.0
		_VerticalOffset2("Vertical offset 2", float) = 0.0
		_AnimSpeed("Anim speed", float) = 0.0
		_AnimAmplitude("Anim amplitude", float) = 0.0
		_Glossiness("Glossiness", Range(0.0, 1.0)) = 0.8
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpTex;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_BumpTex;
		};

		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _HorizontalOffset2;
		float _VerticalOffset2;
		float _AnimSpeed;
		float _AnimAmplitude;
		float _Glossiness;
		float _BumpIntensity;

		void vert(inout appdata_full v)
		{
			float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
			float offset = sin(_Time.y * _AnimSpeed + worldPosition.x) *
						sin(_Time.y * _AnimSpeed + worldPosition.z) *
										_AnimAmplitude;
			v.vertex.xyz += v.normal*offset;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex
								+float2(_HorizontalOffset, _VerticalOffset)*_Time.y)
								, _BumpIntensity);
			float3 normal2 = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex
								+float2(_HorizontalOffset2, _VerticalOffset2)*_Time.y)
								, _BumpIntensity);

			normal = normalize(normal + normal2);

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex
								+float2(_HorizontalOffset, _VerticalOffset)) * _Color;

			o.Normal = normal;
			o.Albedo = c.rgb;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
