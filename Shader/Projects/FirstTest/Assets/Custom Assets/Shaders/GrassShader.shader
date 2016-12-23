Shader "Custom/GrassShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_BumpTex("Normal", 2D) = "bump" {}
		_BumpScale("Normal intensity", Range(0, 2)) = 1
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_AlphaCutOff("Alpha cut off", Range(0, 1)) = 0.5
		[NoScaleOffset]_WindTex("Wind normal map", 2D) = "bump" {}
		_WindIntensity("Wind intensity", Range(-0.2, 0.2)) = 0.1
		_WindSpeed("Wind speed", Range(-1, 1)) = 0.3
		_WindScale("Wind scale", Range(0, 0.1)) = 0.7

		_RepulseMinDistance("Repulse min distance", float) = 0.5
		_RepulseMaxDistance("Repulse max distance", float) = 1.5
		_RepulseStrength("Repulse strength", Range (0, 2.0)) = 1.0

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		Cull off
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows addshadow vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D _WindTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_WindTex;
			float4 color : COLOR; //dans la variable color, tu mets la couleur
		};

		half _BumpScale;
		half _Glossiness;
		half _Metallic;
		half _AlphaCutOff;
		half _WindIntensity;
		half _WindSpeed;
		half _WindScale;
		fixed4 _Color;
		float _HeroSpeed;
		//On ne peut pas le mettre dans les properties parce que sinon ce n'est pas moi mais les properties qui vont écrire les valeurs de _HeroPosition
		float3 _HeroPosition;
		half _RepulseMinDistance;
		half _RepulseMaxDistance;
		half _RepulseStrength;

		void vert(inout appdata_full v) {
			float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			float3 repulseDirection = wPos - _HeroPosition;
			float distanceToHero = length(repulseDirection);
			repulseDirection = normalize(repulseDirection);
			repulseDirection.y = 0;
			
			float repulseIntensity = 1.0f - smoothstep(_RepulseMinDistance, _RepulseMaxDistance, distanceToHero);

			//accéder à la texture avec la normal map
			float3 offset = UnpackNormal(tex2Dlod(_WindTex, float4(wPos.xy * _WindScale + float2(0.5f, 0.5f) * _Time.y * _WindSpeed, 0.0f, 0.0f))) * _WindIntensity;
			offset = float3(offset.x, 0.0f, offset.y);
			offset += repulseDirection * repulseIntensity * _RepulseStrength * _HeroSpeed;
			v.vertex.xyz += offset * v.texcoord.y;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color * IN.color;
			float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_MainTex), _BumpScale);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			o.Normal = normal;
			//Clip : si le pixel > 0  alors il n'est pas affiché
			//décide à partir de quel niveau c'est transparent et de quel niveau c'est solide
			clip(c.a - _AlphaCutOff);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
