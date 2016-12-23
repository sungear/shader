Shader "Custom/Plane" {
	Properties {
		_Color ("Color" /*nom apparaissant dans l'inspecteur*/, Color /*color pickeur*/) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D /*texture 25*/) = "white" /*white, black ou bump*/{}
		_Glossiness ("Smoothness", Range(0,1)/*slider 0 à 1*/) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ScrollSpeedV("Scroll Speed Vertical", Range(-1,1)) = 0.1
		_ScrollSpeedH("Scroll Speed Horizontal", Range(-1,1)) = 0.1
		_LogoTex ("Logo (RGB)", 2D) = "white"
	}
	SubShader {
		Tags { "RenderType"="Opaque" } /*signal le type de shader*/
		LOD 200
		
		CGPROGRAM // commence le code shader
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard /*type d'éclairage*/ fullforwardshadows /*shader fait pour quoi?*/ // commande qu'on peut envoyer au compilateur

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0 //définir le type de matérial sur lequel on fait notre shader - 5.0 est le plus neuf - 3.0 sur Androird, 5.0 sur PC

		sampler2D _MainTex; //faire bien attention ! ne met pas erreur si on écrit _Maintex par exemple...
		sampler2D _LogoTex;

		struct Input /*définit les choses particulière dont on va avoir besoin*/{
			float2 uv_MainTex; /*coordonnées du mapping*/
			float2 uv_LogoTex;
		};

		//half _Glossiness; // half = moitié de précision d'un float → 16 au lieu de 32
		//half _Metallic;
		//fixed4 _Color; // fixed = valeur flottante allant de 0 à 1
		float _Glossiness;
		float _Metallic;
		float4 _Color;
		float _ScrollSpeedV;
		float _ScrollSpeedH;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 logoColor = tex2D(_LogoTex, IN.uv_LogoTex);
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex + _Time.x*float2(_ScrollSpeedV, _ScrollSpeedH));
			c.rgb = lerp(c.rgb, c.rgb * _Color, logoColor.a);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness*logoColor.a;
			o.Alpha = c.a;
		}
		ENDCG // fin du code shader
	}
	FallBack "Diffuse"
}
