Shader "Custom/Surface04" 
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
		_DistortionIntensity("Distortion", Range(-0.1, 0.1)) = 0.01
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
		float _DistortionIntensity;

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
			// Les normales dans unity sont stockée dans un format particulier 
			// permettant de les compresser plus efficacement
			// Si vous voulez modifier l'importance de la normale map, utilisez
			// UnpackScaleNormal qui demande en paramètre la couleur de la normale map
			// et le facteur de scale. Si vous voulez juste la valeur de la normale
			// sans modification de scale : UnpackNormal qui ne prend que le premier
			// paramètre de couleur de normale

			float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex * 1.5
								+float2(_HorizontalOffset, _VerticalOffset)*_Time.y)
								, _BumpIntensity);
			float3 normal2 = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex
								+float2(_HorizontalOffset2, _VerticalOffset2)*_Time.y+
								normal.xy * _DistortionIntensity)
								, _BumpIntensity);

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex
								+float2(_HorizontalOffset, _VerticalOffset)) * _Color;

			o.Normal = normal2;
			o.Albedo = c.rgb;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
