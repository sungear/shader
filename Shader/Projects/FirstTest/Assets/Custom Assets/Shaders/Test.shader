Shader "Custom/Test" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_BumpTex("Normal", 2D) = "bump" {}
	_TestTex("Test", 2D) = "white" {}
	_BumpIntensity("Normal intensity", Range(0.0, 2.0)) = 1.0
		_HorizontalOffset("Horizontal offset", float) = 0.0
		_VerticalOffset("Vertical offset", float) = 0.0
		_HorizontalOffset2("Horizontal offset 2", float) = 0.0
		_VerticalOffset2("Vertical offset 2", float) = 0.0
		_AnimSpeed("Animation speed", float) = 0.0
		_AnimAmplitude("Animation amplitude", float) = 0.0
		_Smoothness("Smoothness", Range(0.0, 1.0)) = 0.8
		_DistortionIntensity("Distortion intensity", Range(-2.0, 2.0)) = 0.1
		_RefractionIntensity("Refraction intensity", Range(-200, 200)) = 50
		_FresnelPower("Fresnel power", Range(0.01, 50)) = 2
		_ZScale("Z scale", Range(0.0, 1.0)) = 0.1
		_GhostPower("Ghost power", float) = 1.0
		/*_MinDistance("Tessellation min distance", Range(0, 20)) = 5
		_MaxDistance("Tessellation max distance", Range(20, 200)) = 50
		_Tessellation("Tessellation intensity", Range(1, 32)) = 5 */ // aumoins 1 sinon il supprime tout les triangle
		//3 triangles en plus par 1 niveau de tesselation en plus
		_BumpColor("Bump Color", Color) = (1,1,1,1)
		_TestColor("Test color", Color) = (1, 1, 1, 1)
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Transparent" } // de type transparent //queue = donne l'ordre de rendu → ici on dit que c'est après les objets opaques, et donc dans l'ordre par défaut dans unity
		LOD 200 //level of details → permet de changer de shader selon la distance de la caméra

		GrabPass{
		"_BackgroundTexture" //lui donner veut dire que le premier objet va faire le grappass et les autres vont le copier
							 // par contre, il y a des problème : si l'objet avec le grappass est sous un autre objet, on ne le voit pas
	}

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows vertex:vert /*tessellate:tessDistance*/

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0 //passer à 5.0 pour avoir le tessallate
		//#include "Tessellation.cginc"

		sampler2D _BackgroundTexture;
	float4 _BackgroundTexture_TexelSize;
	sampler2D _MainTex;
	sampler2D _BumpTex;
	sampler2D _TestTex;
	sampler2D_float _CameraDepthTexture;

	struct Input {
		float2 uv_MainTex;
		float2 uv_BumpTex;
		float2 uv_TestTex;
		float4 screenPos; // position où on est à l'écran - calculer automatiquement par le shader
		float3 viewDir;
		float eyeDepth;
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
	float _RefractionIntensity;
	float _FresnelPower;
	float _ZScale;
	float _GhostPower;
	/*float _MinDistance;
	float _MaxDistance;
	float _Tessellation;*/
	fixed4 _BumpColor;
	fixed4 _TestColor;

	/*float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2) {
	return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _MinDistance, _MaxDistance, _Tessellation);
	}*/

	void vert(inout appdata_full v, out Input o) {
		float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
		float offset = sin(_Time.y * _AnimSpeed + worldPosition.x)
			* sin(_Time.y * _AnimSpeed + worldPosition.z) * _AnimAmplitude;
		v.vertex.xyz += v.normal*offset;

		UNITY_INITIALIZE_OUTPUT(Input, o);
		COMPUTE_EYEDEPTH(o.eyeDepth);
	}

	void surf(Input IN, inout SurfaceOutputStandard o) {

		float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
		float sceneZ = LinearEyeDepth(rawZ);
		float deltaZ = saturate((sceneZ - IN.eyeDepth) * _ZScale);

		float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex + float2(_HorizontalOffset, _VerticalOffset) * _Time.y), _BumpIntensity);
		float3 normal1 = UnpackScaleNormal(tex2D(_BumpTex, (1 - IN.uv_BumpTex) + float2(_HorizontalOffset, _VerticalOffset) * _Time.y), _BumpIntensity);
		float3 normal2 = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex - float2(_HorizontalOffset2, _VerticalOffset2) * _Time.y + (normal.xy * normal1.xy) * _DistortionIntensity)
			, _BumpIntensity);

		fixed4 bumpColor = tex2D(_BumpTex, IN.uv_BumpTex) * _BumpColor;

		//normal = normalize(normal + normal2);
		// Albedo comes from a texture tinted by color
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex + float2(_HorizontalOffset, _VerticalOffset)) * _Color;

		fixed4 testColor = tex2D(_TestTex, IN.uv_TestTex) * _TestColor;

		c.rgb = lerp(c.rgb, bumpColor*_Color, deltaZ);

		/*seulement le x et y parce que c'est les valeurs qui vacillent entre 0 et 1*/
		/* * _Background_TexelSize pour que ce soit indépendant de la taille de l'écran*/
		// le z permet de gérer la distorsion selon la distance de l'objet de la caméra
		float2 UVoffset = normal2.xy  * _BackgroundTexture_TexelSize.xy * IN.screenPos.z * _RefractionIntensity * deltaZ;
		//Calculer la coordonnée réelle du pixel pour accéder à ce qui est derrière
		float2 UVcoords = (IN.screenPos.xy + UVoffset) / IN.screenPos.w; //la diviosion par le w permet d'avoir une valoir plus exacte
		float3 refractedColor = tex2D(_BackgroundTexture, UVcoords); //couleur du background en tenant compte de la réfraction

		rawZ = tex2D(_CameraDepthTexture, UVcoords).r;
		sceneZ = LinearEyeDepth(rawZ);
		deltaZ = saturate((sceneZ - IN.eyeDepth) * _ZScale);

		float fresnel = saturate(1.0f - dot(normalize(IN.viewDir.xyz), normal2));
		fresnel = pow(fresnel, _FresnelPower * _GhostPower);

		o.Normal = normal2;
		o.Albedo = c.rgb * fresnel;
		o.Smoothness = _Smoothness;
		//couleur réfractée va être colorée en fonction de la couleur Albedo
		o.Emission = refractedColor * lerp(lerp(_Color, _TestColor, saturate(deltaZ*2)), _BumpColor, saturate(deltaZ*2-1))  * (1 - fresnel);
		o.Alpha = c.a;
	}
	ENDCG
	}
		FallBack "Diffuse"
}
