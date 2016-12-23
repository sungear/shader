Shader "Custom/Surface01" 
{
	// Cette section permet d'exposer les paramètres du shader dans l'inspecteur Unity
	// Le paramètres peuvent être de type Color/2D-3D-Cube (texture)/Range(valeur flottante délimitée par un min/max)/Float
	// Pour plus de détails : http://docs.unity3d.com/Manual/SL-Properties.html
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
		// Le tag rendertype permet de définir le type de shader défini 
		// (utilisé dans le cadre des shaders de remplacement) : http://docs.unity3d.com/Manual/SL-ShaderReplacement.html)
		Tags { "RenderType"="Opaque" }

		// Le LOD (level of detail) permet de préciser l'importance du shader dans le cas 
		// ou vous voudriez en supprimez certains afin de rendre le jeu
		// plus fluide sur certaines plateformes plus limitées.
		// Pour plus de détails : http://docs.unity3d.com/Manual/SL-ShaderLOD.html
		LOD 200
		
		CGPROGRAM

		// Ce pragma permet de définir la fonction qui est utilisée pour le surface shader (ici 'surf')
		// de même que le type de lighting utilisé pour faire le rendu (ici 'Standard' - PBR shader)
		// D'autres types de lighting sont disponibles (Lambert, BlinnPhong ... ) permettant d'avoir des 
		// shaders plus légers mais non PBR
		// fullforwardshadows permet de supporter l'ensemble des sources lumineuses.
		// Pour plus de détails : http://docs.unity3d.com/Manual/SL-SurfaceShaders.html
		#pragma surface surf Standard fullforwardshadows

		// Permet de s'assurer que la cible minimale pour ce shader est une plateforme de type directX 9
		// ou supérieur.
		// 3.0 = DX9, 4.0 = DX10, 5.0 = DX11
		#pragma target 5.0

		// Déclaration des variables exposées du shader. On retrouve les mêmes noms que dans la
		// section 'Properties' ci dessus
		sampler2D _MainTex;
		sampler2D _LogoTex;

		// Structure des données d'entrée du surface shader.
		// Les coordonnées de mapping portent le nom 'uv' suivi du nom de la texture (ici '_MaintTex' & '_LogoTex')
		// Il est possible de récupérer d'autres infos comme la couleur par vertex
		// Pour plus de détails : http://docs.unity3d.com/Manual/SL-SurfaceShaders.html (section Surfae shader input structure)
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


		// Fonction surf utilisée comme surface shader
		// Nous retrouvons en input ce qui a été défini dans la structure ci dessus
		// et en sortie, une structure standard (SurfaceOutputStandard) utilisée dans les surface shaders
		// Cette structure reprend les éléments suivants :
		//
		// fixed3 Albedo;      base (diffuse or specular) color
		// fixed3 Normal;      tangent space normal, if written
		// half3 Emission;
		// half Metallic;      0=non-metal, 1=metal
		// half Smoothness;    0=rough, 1=smooth
		// half Occlusion;     occlusion (default 1)
		// fixed Alpha;        alpha for transparencies
		//
		// Il n'est pas nécessaire d'écrire dans toutes ces variables, des valeurs par défaut sont 
		// déjà définies de base.
		// Pour plus de détails : http://docs.unity3d.com/Manual/SL-SurfaceShaders.html

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// La fonction tex2D permet d'aller lire la couleur d'un texel de la texture _LogoTex
			// aux coordonnées IN.uv_LogoTex
			fixed4 logoColor = tex2D(_LogoTex, IN.uv_LogoTex);

			// Même principe ici, mais on décalle les UV en fonction de la vitesse de scrolling et
			// du temps
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex + _Time.y * 
							float2(_ScrollSpeedHorizontal, _ScrollSpeedVertical));

			// Les deux couleurs de textures sont mélangées grâce à un LERP (linear interpolater)
			// Le premier paramètre du lerp = la valeur de retour quand le poids est à 0
			// Le second paramètre du lerp = la valaur de retour quand le poids est à 1
			// Le troisième paramètre est le poids
			c.rgb = lerp(c.rgb, c.rgb* _Color, logoColor.a);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			// La glossiness est déterminée comme étant un mélange de la glossiness de base
			// et de la glossiness du logo
			o.Smoothness = lerp(_Glossiness, _GlossinessLogo, logoColor.a);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
