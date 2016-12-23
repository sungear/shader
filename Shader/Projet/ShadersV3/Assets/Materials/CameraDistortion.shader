Shader "Custom/CameraDistortion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DistortionPower("Distortion power", Range(0.0, 2.0)) = 1.5
		_Zoom("Zoom", Range(0.5, 1.5)) = 1.0
		_Aberration("Aberration", Range(-0.1, 0.1)) = 0.001
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float _DistortionPower;
			float _Zoom;
			float _Aberration;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uvCoordsUnit = (i.uv * 2.0f - 1.0f);
				float originalDist = length(uvCoordsUnit);

				float dist = lerp(sin(originalDist), originalDist, _DistortionPower);
				dist *= _Zoom;
				float2 distortedUV = normalize(uvCoordsUnit) * dist;
				float4 color = tex2D(_MainTex, (distortedUV + 1.0f)/2.0f);

				dist = lerp(sin(originalDist), originalDist, _DistortionPower - _Aberration);
				dist *= _Zoom;
				distortedUV = normalize(uvCoordsUnit) * dist;
				color.r = tex2D(_MainTex, (distortedUV + 1.0f)/2.0f).r;

				dist = lerp(sin(originalDist), originalDist, _DistortionPower + _Aberration);
				dist *= _Zoom;
				distortedUV = normalize(uvCoordsUnit) * dist;
				color.b = tex2D(_MainTex, (distortedUV + 1.0f)/2.0f).b;

				return color;
			}
			ENDCG
		}
	}
}
