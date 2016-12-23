Shader "Custom/Surface03" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_BumpTex("Normal", 2D) = "bump" {}
	_BumpIntensity("Normal intensity", Range(0.0, 2.0)) = 1.0
		_HorizontalOffset("Horizontal offset", float) = 0.0
		_VerticalOffset("Vertical offset", float) = 0.0
		_HorizontalOffset2("Horizontal offset 2", float) = 0.0
		_VerticalOffset2("Vertical offset 2", float) = 0.0
		_AnimSpeed("Animation speed", float) = 0.0
		_AnimAmplitude("Animation amplitude", float) = 0.0
		_Smoothness("Smoothness", Range(0.0, 1.0)) = 0.8
		_DistortionIntensity("Distortion intensity", Range(-2.0, 2.0)) = 0.1
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" } // de type transparent //queue = donne l'ordre de rendu → ici on dit que c'est après les objets opaques, et donc dans l'ordre par défaut dans unity
		LOD 200 //level of details → permet de changer de shader selon la distance de la caméra

				//Zwrite Off //n'écrit plus dans le Z-buffer
				//Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

		sampler2D _MainTex;
	sampler2D _BumpTex;

	struct Input {
		float2 uv_MainTex;
		float2 uv_BumpTex;
	};

	//half _Glossiness;
	//half _Metallic;
	fixed4 _Color;
	float _HorizontalOffset;
	float _VerticalOffset;
	float _HorizontalOffset2;
	float _VerticalOffset2;
	float _AnimSpeed;
	float _AnimAmplitude;
	float _Smoothness;
	float _BumpIntensity;
	float _DistortionIntensity;

	void vert(inout appdata_full v) {
		float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
		float offset = sin(_Time.y * _AnimSpeed + worldPosition.x)
			* sin(_Time.y * _AnimSpeed + worldPosition.z) * _AnimAmplitude;
		v.vertex.xyz += v.normal*offset;
	}

	void surf(Input IN, inout SurfaceOutputStandard o) {
		float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex + float2(_HorizontalOffset, _VerticalOffset) * _Time.y), _BumpIntensity);
		float3 normal2 = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex - float2(_HorizontalOffset2, _VerticalOffset2) * _Time.y + normal.xy * _DistortionIntensity)
			, _BumpIntensity);

		//normal = normalize(normal + normal2);
		// Albedo comes from a texture tinted by color
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex + float2(_HorizontalOffset, _VerticalOffset)) * _Color;

		o.Normal = normal2;
		o.Albedo = c.rgb;
		o.Smoothness = _Smoothness;
	}
	ENDCG
	}
		FallBack "Diffuse"
}
