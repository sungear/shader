Shader "Tessellation Sample" 
{
        Properties 
		{
            _DispTex ("Disp Texture", 2D) = "gray" {}
            _NormalMap ("Normalmap", 2D) = "bump" {}
            _Displacement ("Displacement", Range(0, 1.0)) = 0.3
            _Color ("Color", color) = (1,1,1,0)
            _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)


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
//		_Tessellation("Tessellation intensity", Range(0, 32)) = 5
        _Tessellation ("Tessellation", Range(1,32)) = 4
		_FoamTex ("Foam", 2D) = "white" {}

        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:vert tessellate:tessDistance nolightmap
            #pragma target 5
            #include "Tessellation.cginc"

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
				float2 uv_BumpTex;
				float2 uv_FoamTex;
				float4 screenPos;
				float3 viewDir;
				float eyeDepth;
			};

            float _Tess;

            sampler2D _DispTex;
            float _Displacement;

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
			float _Tessellation;
			float _FoamLimit;

			float4 tessDistance (appdata v0, appdata v1, appdata v2) 
			{
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex,
				_MinDistance, _MaxDistance, _Tessellation); 
            }

            void vert (inout appdata v)
            {
				float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
				float offset = sin(_Time.y * _AnimSpeed + worldPosition.x) *
							sin(_Time.y * _AnimSpeed + worldPosition.z) *
											_AnimAmplitude;
				v.vertex.xyz += v.normal*offset;

			//UNITY_INITIALIZE_OUTPUT(Input, o);
			//COMPUTE_EYEDEPTH(o.eyeDepth);

            }

   //         struct Input 
			//{
   //             float2 uv_MainTex;
   //         };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) 
			{
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }