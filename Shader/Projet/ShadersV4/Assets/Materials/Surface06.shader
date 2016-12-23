Shader "Custom/Surface06" 
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
		_MinDistance("Tessellation min distance", Range(0, 20)) = 5
		_MaxDistance("Tessellation max distance", Range(20, 200)) = 50
		_Tessellation("Tessellation intensity", Range(0, 32)) = 5
		_FoamTex ("Foam", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass
		{
			"_BackgroundTexture"
		}

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade tessellate:tessDistance
		#pragma target 5.0
		#include "Tessellation.cginc"

		sampler2D _BackgroundTexture;
		float4 _BackgroundTexture_TexelSize;
		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D_float _CameraDepthTexture;
		sampler2D _FoamTex;

		struct appdata 
		{
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

		struct Input 
		{
			float2 uv_MainTex;
			//float2 uv_BumpTex;
			//float2 uv_FoamTex;
			//float4 screenPos;
			//float3 viewDir;
			//float eyeDepth;
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
		float _MinDistance;
		float _MaxDistance;
		float _Tesselation;
		float _FoamLimit;

		float4 tessDistance(appdata v0, appdata v1, appdata v2)
		{
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex,
				_MinDistance, _MaxDistance, _Tesselation); 
		} 


		void vert(inout appdata v) //, out Input o)
		{
			//float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
			//float offset = sin(_Time.y * _AnimSpeed + worldPosition.x) *
			//			sin(_Time.y * _AnimSpeed + worldPosition.z) *
			//							_AnimAmplitude;
			//v.vertex.xyz += v.normal*offset;

			//UNITY_INITIALIZE_OUTPUT(Input, o);
			//COMPUTE_EYEDEPTH(o.eyeDepth);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			//float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,
			//				UNITY_PROJ_COORD(IN.screenPos));
			//float sceneZ = LinearEyeDepth(rawZ);

			//float deltaZ = saturate((sceneZ - IN.eyeDepth) * _ZScale);
			//float flatDeltaZ = deltaZ;

			//float3 normal = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex * 1.5
			//					+float2(_HorizontalOffset, _VerticalOffset)*_Time.y)
			//					, _BumpIntensity);
			//float3 normal2 = UnpackScaleNormal(tex2D(_BumpTex, IN.uv_BumpTex
			//					+float2(_HorizontalOffset2, _VerticalOffset2)*_Time.y+
			//					normal.xy * _DistortionIntensity)
			//					, _BumpIntensity);

			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex
			//					+float2(_HorizontalOffset, _VerticalOffset));

			//float2 UVOffset = normal2.xy * _BackgroundTexture_TexelSize.xy *
			//					IN.screenPos.z * _RefractionIntensity * deltaZ;
			//float2 UVcoords = (IN.screenPos.xy + UVOffset) / IN.screenPos.w;
			//float3 refractedColor = tex2D(_BackgroundTexture, UVcoords);

			//rawZ = tex2D(_CameraDepthTexture, UVcoords).r;
			//sceneZ = LinearEyeDepth(rawZ);
			//deltaZ = saturate((sceneZ - IN.eyeDepth) * _ZScale);

			//float3 waterColor = lerp(lerp(_Color3, _Color2, saturate(deltaZ*2.0f)),
			//						_Color1, saturate(deltaZ*2.0f-1.0f)); 

			//float fresnel = saturate(1.0f - dot(normalize(IN.viewDir.xyz),normal2));	
			//fresnel = pow(fresnel, _FresnelPower);

			//float3 foamColor = tex2D(_FoamTex, IN.uv_FoamTex.xy 
			//		+float2(_HorizontalOffset, _VerticalOffset)*_Time.y);
			//float foam = step( deltaZ, _FoamLimit*foamColor.g);

			//o.Normal = normal2;
			//o.Albedo = lerp(c.rgb * _Color1*  fresnel, float3(1.0f, 1.0f, 1.0f), foam);
			//o.Smoothness = lerp(_Glossiness, 0.0f, foam);
			//o.Emission = lerp(refractedColor * waterColor * (1.0f - fresnel), float3(0.0f, 0.0f, 0.0f), foam);
			//o.Alpha = saturate(deltaZ*50.0f);

			o.Emission = float4(1.0f, 0.0f, 0.0f, 1.0f);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
