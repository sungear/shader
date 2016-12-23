Shader "Custom/Surface02" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MaskTex("Mask", 2D) = "white" {}
		_HorizontalOffset("Horizontal offset", float) = 0.0
		_VerticalOffset("Vertical offset", float) = 0.0
		_IntensityBoost("Insensity boost", Range(0,10)) = 0.1
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent"} // de type transparent //queue = donne l'ordre de rendu → ici on dit que c'est après les objets opaques, et donc dans l'ordre par défaut dans unity
		LOD 200 //level of details → permet de changer de shader selon la distance de la caméra

		Cull Front //on affiche pas les faces avant, seulement les faces arrières
		Zwrite Off //n'écrit plus dans le Z-buffer
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:blend

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MaskTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_MaskTex;
		};

		//half _Glossiness;
		//half _Metallic;
		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _IntensityBoost;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float mask = tex2D(_MaskTex, IN.uv_MaskTex).g;
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex + float2(_HorizontalOffset, _VerticalOffset)) * _Color; //accède à la texture en la décalant horizontalement et verticalement
			/*o.Albedo = c.rgb;*/
			// Metallic and smoothness come from slider variables
			/*o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;*/
			o.Emission = c.rgb * _IntensityBoost; //on multiplie la couleur de la texture par l'_IntensityBoost
			o.Alpha = c.a * mask;
		}
		ENDCG

		Cull Back //on affiche pas les faces avant, seulement les faces arrières
		Zwrite Off //n'écrit plus dans le Z-buffer
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows alpha:blend

			// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MaskTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_MaskTex;
		};

		//half _Glossiness;
		//half _Metallic;
		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _IntensityBoost;

		void surf(Input IN, inout SurfaceOutputStandard o) {
			float mask = tex2D(_MaskTex, IN.uv_MaskTex).g;
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex + float2(_HorizontalOffset, _VerticalOffset)) * _Color; 
			//accède à la texture en la décalant horizontalement et verticalement
			/*o.Albedo = c.rgb;*/
			// Metallic and smoothness come from slider variables
			/*o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;*/
			o.Emission = c.rgb * _IntensityBoost; //on multiplie la couleur de la texture par l'_IntensityBoost
			o.Alpha = c.a * mask;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
