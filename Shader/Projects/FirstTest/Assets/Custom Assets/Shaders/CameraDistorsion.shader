Shader "Custom/CameraDistorsion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DistortionPower("Distortion power", Range(0, 2)) = 1.5
		_Zoom("Zoom", Range(0.5, 1.5)) = 1
		_Aberration("Aberration", Range(-0.1, 0)) = 0.01
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass // on sait qu'on a un hlsl quand on a Pass - on ne l'a pas avec le surface shader
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members _Zoom,_Aberration)
#pragma exclude_renderers d3d11 xbox360
			#pragma vertex vert
			#pragma fragment frag
			//On retire le fog parce qu'il est inutile dans un post effect
			//// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			//infos de position, de texture
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			// vertex to fragment
			struct v2f
			{
				float2 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float _Zoom;
				float _Aberration;
			};

			sampler2D _MainTex;
			float _DistortionPower;
			//Permet de récupérer le tilling et l'effet d'une texture - pas besoin dans notre cas
			//float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				o.uv = v.uv;
				return o;
			}
			
			//calcule la couleur finale du shader
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uvCoordUnit = (i.uv * 2.0f - 1.0f);
				float  originalDist = length(uvCoordUnit);

				float dist = lerp(sin(originalDist), originalDist, _DistortionPower);
				dist *= _Zoom;
				float2 distortedUV = normalize(uvCoordUnit) * dist;
				float4 color = tex2D(_MainTex, (distortedUV + 1.0f) / 2.0f);

				dist = lerp(sin(originalDist), originalDist, _DistortionPower - _Aberration);
				dist *= _Zoom;
				distortedUV = normalize(uvCoordUnit) * dist;
				corlo.r = tex2D(_MainTex, (distortedUV + 1.0f) / 2.0f).r;

				dist = lerp(sin(originalDist), originalDist, _DistortionPower + _Aberration);
				dist *= _Zoom;
				distortedUV = normalize(uvCoordUnit) * dist;
				corlo.b = tex2D(_MainTex, (distortedUV + 1.0f) / 2.0f).b;

				//// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return color;
			}
			ENDCG
		}
	}
}
