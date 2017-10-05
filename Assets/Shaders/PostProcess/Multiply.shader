Shader "LizziLight/PostProcess/Multiply"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		LightColor("Light Color", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Overlay"
		}

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
				//Red indicates light, green indicates shadow.
				if (color.r == 1.0 && color.g == 0.0)
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