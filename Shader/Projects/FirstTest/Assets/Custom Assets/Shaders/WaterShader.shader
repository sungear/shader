Shader "Custom/WaterShader" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MaskTex("Mask", 2D) = "white" {}
		_HorizontalOffset("Horizontal offset", float) = 0.0
		_VerticalOffset("Vertical offset", float) = 0.0
		_IntensityBoost("Insensity boost", Range(0,10)) = 0.1
		_AnimSpeed("Animation speed", float) = 0.0
		_AnimAmplitude("Animation amplitude", float) = 0.0
		_GhostPower("Ghost power", float) = 1.0
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	
	SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" } // de type transparent //queue = donne l'ordre de rendu → ici on dit que c'est après les objets opaques, et donc dans l'ordre par défaut dans unity
		LOD 200 //level of details → permet de changer de shader selon la distance de la caméra

		Cull Front //on affiche pas les faces avant, seulement les faces arrières
		Zwrite Off //n'écrit plus dans le Z-buffer
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MaskTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_MaskTex;
			float3 viewDir; //Unity sait automatiquement qu'on lui demande la direction de la vue avec viewDir
		};

		//half _Glossiness;
		//half _Metallic;
		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _IntensityBoost;
		float _AnimSpeed;
		float _AnimAmplitude;
		float _GhostPower;

		void vert(inout appdata_full v) {
			float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
			float offset = sin(_Time.y * _AnimSpeed + worldPosition.x) 
				* sin(_Time.y * _AnimSpeed + worldPosition.z) * _AnimAmplitude;
			v.vertex.xyz += v.normal*offset;
		}

		void surf(Input IN, inout SurfaceOutputStandard o) {
			float fresnel = 1 - abs(dot(o.Normal, normalize(IN.viewDir.xyz)));
			fresnel = pow(fresnel, _GhostPower); //permet d'adoucir les bords - on voit mieux quand on le regarde de haut et semble presque invisibe sur les bors → baisse l'intensité sur les bords
			float mask = tex2D(_MaskTex, IN.uv_MaskTex).g;
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex + float2(_HorizontalOffset, _VerticalOffset)) * _Color; //accède à la texture en la décalant horizontalement et verticalement
																											 /*o.Albedo = c.rgb;*/
																											 // Metallic and smoothness come from slider variables
																											 /*o.Metallic = _Metallic;
																											 o.Smoothness = _Glossiness;*/
			o.Emission = c.rgb * _IntensityBoost; //on multiplie la couleur de la texture par l'_IntensityBoost
			o.Alpha = c.a * mask * (1-fresnel);
		}
		ENDCG

		Cull Back //on affiche pas les faces avant, seulement les faces arrières
		Zwrite Off //n'écrit plus dans le Z-buffer
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MaskTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_MaskTex;
			float3 viewDir;
		};

		//half _Glossiness;
		//half _Metallic;
		fixed4 _Color;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _IntensityBoost;
		float _AnimSpeed;
		float _AnimAmplitude;
		float _GhostPower;

		void vert(inout appdata_full v) {
			float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
			float offset = sin(_Time.y * _AnimSpeed + worldPosition.x)
				* sin(_Time.y * _AnimSpeed + worldPosition.z) * _AnimAmplitude;
			v.vertex.xyz += v.normal*offset;
		}

		void surf(Input IN, inout SurfaceOutputStandard o) {
			float fresnel = 1 - abs(dot(o.Normal, normalize(IN.viewDir.xyz)));
			fresnel = pow(fresnel, _GhostPower); 
			float mask = tex2D(_MaskTex, IN.uv_MaskTex).g;
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex + float2(_HorizontalOffset, _VerticalOffset)) * _Color; //accède à la texture en la décalant horizontalement et verticalement
																											 /*o.Albedo = c.rgb;*/
																											 // Metallic and smoothness come from slider variables
																											 /*o.Metallic = _Metallic;
																											 o.Smoothness = _Glossiness;*/
			o.Emission = c.rgb * _IntensityBoost; //on multiplie la couleur de la texture par l'_IntensityBoost
			o.Alpha = c.a * mask * (1-fresnel);
		}
		ENDCG
	}
		FallBack "Diffuse"
}
