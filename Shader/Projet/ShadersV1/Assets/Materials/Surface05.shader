Shader "Custom/Surface05" 
{
	Properties 
	{
		_Color1 ("Color deep water", Color) = (0,0,0.5,1)
		_Color2 ("Color mid water", Color) = (0,.7,.9,1)
		_Color3 ("Color shallow water", Color) = (1,1,1,1)
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
		_RefractionIntensity("Refraction intensity", Range(-200,200)) = 50
		_FresnelPower("Fresnel power", Range(0.01, 50)) = 2
		_ZScale("Z scale", float) = 1.0
		_FoamLimit("Foam limit", Range(0, 1)) = 0.5
		_FoamTex ("Foam", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

		// Cette passe de rendu copie le frame buffer dans une texture appellée
		// _BackgroundTexture. L'opération sera faite la première fois que ce
		// shader sera utilisé pour rendre un objet. Tout rendu suivant réutilisera
		// cette même texture, il sera donc impossible de voir les objets transparents
		// à travers d'autres objets transparents
		// Pour plus d'info : https://docs.unity3d.com/Manual/SL-GrabPass.html
		GrabPass
		{
			"_BackgroundTexture"
		}

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
		#pragma target 3.0

		// Permet l'accès à la texture de copie d'arrière plan
		sampler2D _BackgroundTexture;
		float4 _BackgroundTexture_TexelSize;
		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D_float _CameraDepthTexture;
		sampler2D _FoamTex;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpTex;
			float2 uv_FoamTex;
			// Permet de récupérer la position écran du pixel que l'on rend
			float4 screenPos;
			// Permet de récupérer la direction vers la caméra
			float3 viewDir;
			// Sera utilisé pour stocker la distance entre la camera et les pixels rendus
			float eyeDepth;
		};

		fixed4 _Color1;
		fixed4 _Color2;
		fixed4 _Color3;
		float _HorizontalOffset;
		float _VerticalOffset;
		float _HorizontalOffset2;
		float _VerticalOffset2;
		float _AnimSpeed;
		float _AnimAmplitude;
		float _Glossiness;
		float _BumpIntensity;
		float _DistortionIntensity;
		float _RefractionIntensity;
		float _FresnelPower;
		float _ZScale;
		float _FoamLimit;

		// Calcul du displacement des vagues en fonction de la position dans
		// le monde
		void vert(inout appdata_full v, out Input o)
		{
			float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
			float offset = sin(_Time.y * _AnimSpeed + worldPosition.x) *
						sin(_Time.y * _AnimSpeed + worldPosition.z) *
										_AnimAmplitude;
			v.vertex.xyz += v.normal*offset;

			UNITY_INITIALIZE_OUTPUT(Input, o);
			COMPUTE_EYEDEPTH(o.eyeDepth);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Récupération de la profondeur du pixel en arrière plan (valeur brute)
			float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,
							UNITY_PROJ_COORD(IN.screenPos));
			// Valeur normalisée en mètres
			float sceneZ = LinearEyeDepth(rawZ);

			// Différence de distance entre la surface de l'eau et l'arrière plan
			float deltaZ = saturate((sceneZ - IN.eyeDepth) * _ZScale);
			float flatDeltaZ = deltaZ;

			// Récupération de la normale de base, qui sert à perturber la
			// normale secondaire
			float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex * 1.5
								+float2(_HorizontalOffset, _VerticalOffset)*_Time.y)
								, _BumpIntensity);
			// Récupération de la normale secondaire qui sera utilisée comme normale 
			// de surface
			float3 normal2 = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex
								+float2(_HorizontalOffset2, _VerticalOffset2)*_Time.y+
								normal.xy * _DistortionIntensity)
								, _BumpIntensity);

			// Couleur en surface
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex
								+float2(_HorizontalOffset, _VerticalOffset));

			// Calcul des coordonnées de mapping permettant l'accès
			// à la copie du frame buffer et du z buffer
			float2 UVOffset = normal2.xy * _BackgroundTexture_TexelSize.xy *
								IN.screenPos.z * _RefractionIntensity * deltaZ;
			float2 UVcoords = (IN.screenPos.xy + UVOffset) / IN.screenPos.w;
			// Couleur réfractée
			float3 refractedColor = tex2D(_BackgroundTexture, UVcoords);

			// Seconde récupération de l'information de profondeur en tenant compte
			// cette fois de la refraction
			rawZ = tex2D(_CameraDepthTexture, UVcoords).r;
			sceneZ = LinearEyeDepth(rawZ);
			deltaZ = saturate((sceneZ - IN.eyeDepth) * _ZScale);

			// Calcul de la rampe de couleur utilisée pour colorer l'eau
			float3 waterColor = lerp(lerp(_Color3, _Color2, saturate(deltaZ*2.0f)),
									_Color1, saturate(deltaZ*2.0f-1.0f)); 

			// Valeur de fresnel calculée à partir de l'angle qu'il y a entre 
			// la direction de la caméra et la normale
			float fresnel = saturate(1.0f - dot(normalize(IN.viewDir.xyz),normal2));	
			fresnel = pow(fresnel, _FresnelPower);

			// Texture d'écume
			float3 foamColor = tex2D(_FoamTex, IN.uv_FoamTex.xy 
					+float2(_HorizontalOffset, _VerticalOffset)*_Time.y);
			float foam = step( deltaZ, _FoamLimit*foamColor.g);

			o.Normal = normal2;
			// L'albedo varie entre la couleur de l'écume et la couleur de l'eau
			o.Albedo = lerp(c.rgb * _Color1*  fresnel, float3(1.0f, 1.0f, 1.0f), foam);
			o.Smoothness = lerp(_Glossiness, 0.0f, foam);
			// L'émissive est complémentaire à l'albedo et est noire aux endroits
			// couverts d'écume
			o.Emission = lerp(refractedColor * waterColor * (1.0f - fresnel), 
								float3(0.0f, 0.0f, 0.0f), foam);
			// Petite rampe de transition au bord du mesh
			o.Alpha = saturate(deltaZ*50.0f);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
