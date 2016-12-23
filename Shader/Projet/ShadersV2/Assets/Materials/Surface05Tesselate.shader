Shader "Tessellation Sample" 
{
        Properties 
		{
			_Color1 ("Water color", Color) = (0,0,0.5,1)
			_MainTex ("Albedo (RGB)", 2D) = "white" {}
			_BumpTex("Normal", 2D) = "bump" {}
			_BumpIntensity("Normal intensity", Range(0.0, 2.0)) = 1.0
			_HorizontalOffset("Horizontal offset", float) = 0.0
			_VerticalOffset("Vertical offset", float) = 0.0
			_HorizontalOffset2("Horizontal offset 2", float) = 0.0
			_VerticalOffset2("Vertical offset 2", float) = 0.0
			_AnimSpeed("Anim speed", float) = 0.0
			_AnimAmplitude1("Anim amplitude 1", float) = 0.0
			_AnimAmplitude2("Anim amplitude 2", float) = 0.0
			_Waves1Scale("Waves 1 scale", Range(0.01,3)) = 1
			_Waves2Scale("Waves 2 scale", Range(0.01,3)) = 0.45
			_Glossiness("Glossiness", Range(0.0, 1.0)) = 0.8
			_MinDistance("Tessellation min distance", Range(0, 20)) = 5
			_MaxDistance("Tessellation max distance", Range(20, 200)) = 50
			_Tessellation ("Tessellation", Range(1,32)) = 4
			_DistortionIntensity("Distortion", Range(-0.1, 0.1)) = 0.01

        }
        SubShader 
		{
			Tags { "RenderType"="Transparent" "Queue"="Transparent" }
			LOD 200
			//Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows vertex:vert tessellate:tessDistance
            #pragma target 5
            #include "Tessellation.cginc"

            struct appdata 
			{
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

			sampler2D _MainTex;
			sampler2D _BumpTex;

			struct Input 
			{
				float2 uv_MainTex;
				float2 uv_BumpTex;
			};

			fixed4 _Color1;
			float _HorizontalOffset;
			float _VerticalOffset;
			float _HorizontalOffset2;
			float _VerticalOffset2;
			float _AnimSpeed;
			float _AnimAmplitude1;
			float _AnimAmplitude2;
			float _Glossiness;
			float _BumpIntensity;
			float _MinDistance;
			float _MaxDistance;
			float _Tessellation;
			float _Waves1Scale;
			float _Waves2Scale;
			float _DistortionIntensity;


			float4 tessDistance (appdata v0, appdata v1, appdata v2) 
			{
				return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex,
					_MinDistance, _MaxDistance, _Tessellation); 
            }

            void vert (inout appdata v)
            {
				float3 worldPosition = mul(unity_ObjectToWorld, v.vertex);
				float offset = sin(_Time.y * _AnimSpeed + worldPosition.x*_Waves1Scale) *
							sin(_Time.y * _AnimSpeed + worldPosition.z*_Waves1Scale) *
											_AnimAmplitude1;
				offset += sin(_Time.y * _AnimSpeed + worldPosition.x*_Waves2Scale) *
							sin(_Time.y * _AnimSpeed + worldPosition.z*_Waves2Scale) *
											_AnimAmplitude2;
				v.vertex.xyz += v.normal*offset;
            }

            void surf (Input IN, inout SurfaceOutputStandard o) 
			{
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

                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color1;
                o.Albedo = c;
                o.Smoothness = _Glossiness;
				o.Normal = normal2;
                //o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }