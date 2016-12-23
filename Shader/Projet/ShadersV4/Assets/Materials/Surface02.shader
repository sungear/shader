Shader "Custom/Surface02" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MaskTex ("Mask", 2D) = "white" {}
		_HorizontalOffset("Horizontal offset", float) = 0.0
		_VerticalOffset("Vertical offset", float) = 0.0
		_IntensityBoost("Intensity boost", Range(0, 50)) = 1.0
		_AnimSpeed("Anim speed", float) = 0.0
		_AnimAmplitude("Anim amplitude", float) = 0.0
		_GhostPower("Ghost power", Range(0.1, 5.0)) = 1.0
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200
		
		// N'effectue que le rendu des faces arrières de l'objet (retire les faces avants)
		// Les valeurs possibles sont :
		//		Front (n'affiche que les faces arrières)
		//		Back (n'affiche que les faces avant)
		//		Off (affiche les faces avant ET arrières)
		// Pour plus de détails : http://docs.unity3d.com/Manual/SL-CullAndDepth.html
		Cull Front

		// N'écrit pas dans le Z buffer
		ZWrite Off

		// Force le mode de blending à être en alpha-blend, lors du rendu de la surface, le GPU
		// mélange automatiquement l'arrière plan et l'avant plan en fonction de la valeur d'alpha
		// pour plus d'informations : https://docs.unity3d.com/Manual/SL-Blend.html
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MaskTex;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_MaskTex;
			float3 viewDir;
		};

		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _IntensityBoost;
		float _AnimSpeed;
		float _AnimAmplitude;
		float _GhostPower;


		// Fonction vert utilisée comme vertex shader
		// la structure appdata_full reprend position, normal, tangent, vertex color + 2 sets d'uv
		// Pour plus de détails : http://docs.unity3d.com/Manual/SL-VertexProgramInputs.html
		void vert(inout appdata_full v)
		{
			float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
			float offset = sin(_Time.y * _AnimSpeed + worldPosition.x) *
						sin(_Time.y * _AnimSpeed + worldPosition.z) *
										_AnimAmplitude;
			// On déplace la position des vertices le long de la normale en fonction de l'intensité 
			// calculée préalablement
			v.vertex.xyz += v.normal*offset;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float fresnel = 1.0f - abs(dot(o.Normal, normalize(IN.viewDir.xyz)));
			fresnel = pow(fresnel, _GhostPower);

			float mask = tex2D(_MaskTex, IN.uv_MaskTex).g;
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex
								+float2(_HorizontalOffset, _VerticalOffset)) * _Color;
			o.Emission = c.rgb * _IntensityBoost * (1.0f - fresnel);
			o.Alpha = c.a * mask * (1.0f - fresnel);
		}
		ENDCG

		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MaskTex;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_MaskTex;
			float3 viewDir;
		};

		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _IntensityBoost;

		float _AnimSpeed;
		float _AnimAmplitude;
		float _GhostPower;

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
			float fresnel = 1.0f - abs(dot(o.Normal, normalize(IN.viewDir.xyz)));
			fresnel = pow(fresnel, _GhostPower);

			float mask = tex2D(_MaskTex, IN.uv_MaskTex).g;

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex
								+float2(_HorizontalOffset, _VerticalOffset)) * _Color;
			o.Emission = c.rgb * _IntensityBoost * (1.0f - fresnel);
			o.Alpha = c.a * mask * (1.0f - fresnel);
		}
		ENDCG

	}
	FallBack "Diffuse"
}
