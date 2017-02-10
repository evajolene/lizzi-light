Shader "LizziLight/BaseColorAlphaCutout"
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
			"RenderType" = "AlphaCutout"
			"Queue" = "Transparent"
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
			};

			VertexOutput Vertex(VertexInput Input)
			{
				VertexOutput output;

				output.position = mul(UNITY_MATRIX_MVP, Input.position);
				output.uv = Input.uv;

				return output;
			}

			float4 Fragment(VertexOutput Input) : COLOR0
			{
				float4 color = tex2D(DiffuseTexture, Input.uv) * DiffuseColor;

				if (color.a < AlphaCutoff)
				{
					discard;
				}

				color.a = 1.0;

				return color;
			}

			ENDCG
		}

		UsePass "LizziLight/Helpers/AlphaCutoutShadowPass/SHADOWCASTER"
	}
}
