Shader "LizziLight/Replacers/OnlyLightAndShadow"
{
	Properties
	{
		DiffuseTexture("Diffuse Texture", 2D) = "white" {}
		DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
		AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.25
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			
			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			
			//Gets Unity's shadow functions.
			#include "AutoLight.cginc"
			
			struct VertexInput
			{
				//This is Unity required, by name, for our shadows.
				float4 vertex : POSITION;
			};

			struct VertexOutput
			{
				//This is Unity required, by name, for our shadows.
				float4 pos : SV_POSITION;

				//This adds a shadow coordinate variable using TEXCOORD0.
				SHADOW_COORDS(0)
			};

			//TRANSFER_SHADOW requires VertexInput parameter to be called v and include vertex.
			VertexOutput Vertex(VertexInput v)
			{
				VertexOutput output;

				output.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_SHADOW(output);

				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				float shadowAttenuation = SHADOW_ATTENUATION(Input);
				
				if (shadowAttenuation < 0.175)
				{
					shadowAttenuation = 1.0;
				}
				else
				{
					shadowAttenuation = 0.0;
				}

				return float4(0.0, shadowAttenuation, 0.0, 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			Blend One One

			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "UnityCG.cginc" 

			//These are Unity required, by name, to get light and attenuation.
			uniform float4 _LightColor0;
			uniform sampler2D _LightTexture0;
			uniform sampler2D _LightTextureB0;
			uniform float4x4 unity_WorldToLight;

			struct VertexInput
			{
				float4 position : POSITION;
			};

			struct VertexOutput
			{
				float4 position : SV_POSITION;
				float4 lightPosition : TEXCOORD0;
			};

			VertexOutput Vertex(VertexInput Input)
			{
				VertexOutput output;

				output.position = UnityObjectToClipPos(Input.position);
				output.lightPosition = mul(unity_WorldToLight, mul(unity_ObjectToWorld, Input.position));

				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				float4 color = float4(0.0, 0.0, 0.0, 1.0);

				float attenuation = 0.0;
				float cookieAttenuation = 1.0;

				//Check if this light is a spotlight...
				if (unity_WorldToLight[3][3] != 1.0)
				{
					cookieAttenuation = tex2D
					(
						_LightTexture0,
						Input.lightPosition.xy / Input.lightPosition.w + float2(0.5, 0.5)
					).a;

					//Get from _LightTextureB0 for spotlight calculation.
					attenuation = tex2D
					(
						_LightTextureB0,
						dot(Input.lightPosition.xyz, Input.lightPosition.xyz).rr
					).UNITY_ATTEN_CHANNEL;
				}
				else
				{
					//Point light calculation.
					attenuation = tex2D
					(
						_LightTexture0,
						dot(Input.lightPosition.xyz, Input.lightPosition.xyz).rr
					).UNITY_ATTEN_CHANNEL;
				}

				if (attenuation > 0.1 && cookieAttenuation > 0.1)
				{
					color.r = 1.0;
				}

				return color;
			}
			
			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "AlphaCutout"
			"IgnoreProjector" = "True"
			"Queue" = "AlphaTest"
		}

		Cull Off

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			
			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			
			//Gets Unity's shadow functions.
			#include "AutoLight.cginc"
			
			uniform sampler2D DiffuseTexture;
			uniform float4 DiffuseColor;
			uniform float AlphaCutoff;
			
			struct VertexInput
			{
				//This is Unity required, by name, for our shadows.
				float4 vertex : POSITION;

				float2 uv : TEXCOORD0;
			};

			struct VertexOutput
			{
				//This is Unity required, by name, for our shadows.
				float4 pos : SV_POSITION;

				float2 uv : TEXCOORD0;

				//This adds a shadow coordinate variable using TEXCOORD1.
				SHADOW_COORDS(1)
			};

			//TRANSFER_SHADOW requires VertexInput parameter to be called v and include vertex.
			VertexOutput Vertex(VertexInput v)
			{
				VertexOutput output;

				output.pos = UnityObjectToClipPos(v.vertex);
				output.uv = v.uv;
				TRANSFER_SHADOW(output);

				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				float shadowAttenuation = SHADOW_ATTENUATION(Input);

				float alpha = (tex2D(DiffuseTexture, Input.uv) * DiffuseColor).a;

				if (alpha >= AlphaCutoff)
				{
					if (shadowAttenuation < 1.0)
					{
						shadowAttenuation = 1.0;
					}
					else
					{
						shadowAttenuation = 0.0;
					}
				}
				else
				{
					discard;
				}

				return float4(0.0, shadowAttenuation, 0.0, 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			Blend One One

			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "UnityCG.cginc" 

			//These are Unity required, by name, to get light and attenuation.
			uniform float4 _LightColor0;
			uniform sampler2D _LightTexture0;
			uniform sampler2D _LightTextureB0;
			uniform float4x4 unity_WorldToLight;

			uniform sampler2D DiffuseTexture;
			uniform float4 DiffuseColor;
			uniform float AlphaCutoff;

			struct VertexInput
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 lightPosition : TEXCOORD1;
			};

			VertexOutput Vertex(VertexInput Input)
			{
				VertexOutput output;

				output.position = UnityObjectToClipPos(Input.position);
				output.uv = Input.uv;
				output.lightPosition = mul(unity_WorldToLight, mul(unity_ObjectToWorld, Input.position));

				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				float4 color = float4(0.0, 0.0, 0.0, 1.0);

				float attenuation = 0.0;
				float cookieAttenuation = 1.0;

				//Check if this light is a spotlight...
				if (unity_WorldToLight[3][3] != 1.0)
				{
					cookieAttenuation = tex2D
					(
						_LightTexture0,
						Input.lightPosition.xy / Input.lightPosition.w + float2(0.5, 0.5)
					).a;

					//Get from _LightTextureB0 for spotlight calculation.
					attenuation = tex2D
					(
						_LightTextureB0,
						dot(Input.lightPosition.xyz, Input.lightPosition.xyz).rr
					).UNITY_ATTEN_CHANNEL;
				}
				else
				{
					//Point light calculation.
					attenuation = tex2D
					(
						_LightTexture0,
						dot(Input.lightPosition.xyz, Input.lightPosition.xyz).rr
					).UNITY_ATTEN_CHANNEL;
				}

				float alpha = (tex2D(DiffuseTexture, Input.uv) * DiffuseColor).a;

				if (attenuation > 0.1 && cookieAttenuation > 0.1 && alpha >= AlphaCutoff)
				{
					color.r = 1.0;
				}
				else
				{
					discard;
				}

				return color;
			}
			
			ENDCG
		}

		UsePass "LizziLight/Helpers/AlphaCutoutShadowPass/SHADOWCASTER"
	}
}
