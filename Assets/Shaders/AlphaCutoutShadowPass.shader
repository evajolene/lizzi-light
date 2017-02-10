//This is a helper shader containing shader passes used by other shaders.
Shader "LizziLight/Helpers/AlphaCutoutShadowPass"
{
	Properties
	{
		DiffuseTexture("Diffuse Texture", 2D) = "white" {}
		DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
		AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.25
	}

	SubShader
	{
		//Shadow caster pass for alpha cutout objects.
		Pass
		{
			Name "ShadowCaster"
			
			Tags
			{
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment

			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

			uniform sampler2D DiffuseTexture;
			uniform float4 DiffuseColor;
			uniform float AlphaCutoff;

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput
			{
				V2F_SHADOW_CASTER;
				float2 uv : TEXCOORD1;
			};

			VertexOutput Vertex(VertexInput v)
			{
				VertexOutput output;
				TRANSFER_SHADOW_CASTER(output)
				output.uv = v.uv;
				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				float alpha = tex2D(DiffuseTexture, Input.uv).a;
				clip(alpha - AlphaCutoff);
				SHADOW_CASTER_FRAGMENT(Input)
			}

			ENDCG
		}
		
		//This pass might be needed later.
		Pass
		{
			Name "ShadowCollector"
			Tags
			{
				"LightMode" = "ShadowCollector"
			}

			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma multi_compile_shadowcollector
			#define SHADOW_COLLECTOR_PASS
			#include "UnityCG.cginc"

			uniform sampler2D DiffuseTexture;
			uniform float4 DiffuseColor;
			uniform float AlphaCutoff;

			struct VertexInput
			{
				float4 vertex : POSITION;
			};

			struct VertexOutput
			{
				V2F_SHADOW_COLLECTOR;
			};

			VertexOutput Vertex(VertexInput v)
			{
				VertexOutput output;
				TRANSFER_SHADOW_COLLECTOR(output)
				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				SHADOW_COLLECTOR_FRAGMENT(Input)
			}

			ENDCG
		}
	}
}