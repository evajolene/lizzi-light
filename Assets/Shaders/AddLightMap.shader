Shader "LizziLight/PostProcessing/AddLightMap"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		MultiplyLightColor("Multiply Light Color", Color) = (1, 1, 1, 1)
		AdditiveLightColor("Additive Light Color", Color) = (1, 1, 1, 0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Overlay"
		}

		Blend One One

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment Fragment

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 AdditiveLightColor;
			
			float4 Fragment(v2f_img Input) : COLOR
			{
				float4 color = tex2D(_MainTex, Input.uv);

				if (color.b == 1.0 || (color.r == 1.0 && color.g == 0.0))
				{
					color = AdditiveLightColor * AdditiveLightColor.a;
				}
				else
				{
					color = UNITY_LIGHTMODEL_AMBIENT * 0.5;
				}

				return color;
			}

			ENDCG
		}

		Blend DstColor Zero

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment Fragment

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 MultiplyLightColor;

			float4 Fragment(v2f_img Input) : COLOR
			{
				float4 color = tex2D(_MainTex, Input.uv);

				/*
					Red indicates light, green indicates shadow, and blue indicates a transparent object.
					This messy check is meant to test if the light/shadow was meant for either
					the transparent object, or the object behind it!
				*/
				if (color.r == 1.0 && ((color.g == 0.0 && color.b == 0.0) || color.b == 1.0))
				{
					color.rgb = MultiplyLightColor.rgb * MultiplyLightColor.a;
				}
				else
				{
					color = UNITY_LIGHTMODEL_AMBIENT;
				}

				return color;
			}

			ENDCG
		}
	}
}