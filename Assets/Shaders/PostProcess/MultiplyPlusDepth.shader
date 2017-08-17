Shader "LizziLight/PostProcess/MultiplyPlusDepth"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		LightColor("Light Color", Color) = (1, 1, 1, 1)
		AdditiveDepthColor("Additive Depth Color", Color) = (1, 1, 1, 0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Overlay"
		}

		//Additive pass. Adds (depth color * depth) where there is light.
		Blend One One

		Pass
		{
			CGPROGRAM
			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "UnityCG.cginc"

			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex;
			uniform float4 AdditiveDepthColor;
			
			struct VertexInput
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPosition : TEXCOORD1;
			};

			VertexOutput Vertex(VertexInput Input)
			{
				VertexOutput output;

				output.position = UnityObjectToClipPos(Input.position);
				output.uv = Input.uv;
				output.screenPosition = ComputeScreenPos(output.position);

				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR
			{
				float4 outColor = float4(0, 0, 0, 1);

				float4 color = tex2D(_MainTex, Input.uv);
				//Red indicates light, green indicates shadow, and blue indicates a transparent object.
				if (color.b == 1.0 || (color.r == 1.0 && color.g == 0.0))
				{
					float depth = Linear01Depth(tex2D(_CameraDepthTexture, UNITY_PROJ_COORD(Input.screenPosition)).r) * 32.0;
					outColor = AdditiveDepthColor * AdditiveDepthColor.a * depth;
				}

				return outColor;
			}

			ENDCG
		}

		//Multiply pass. Simple texture * light.
		Blend DstColor Zero

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment Fragment

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 LightColor;

			float4 Fragment(v2f_img Input) : COLOR
			{
				float4 color = tex2D(_MainTex, Input.uv);
				float4 outColor = float4(0, 0, 0, 1);
				//Red indicates light, green indicates shadow, and blue indicates a transparent object.
				if (color.b == 1.0 || (color.r == 1.0 && color.g == 0.0))
				{
					outColor.rgb = max(LightColor.rgb * LightColor.a, UNITY_LIGHTMODEL_AMBIENT);
				}
				else
				{
					outColor = UNITY_LIGHTMODEL_AMBIENT;
				}

				return outColor;
			}

			ENDCG
		}
	}
}