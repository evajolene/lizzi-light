Shader "LizziLight/BaseColor"
{
	Properties
	{
		DiffuseTexture("Diffuse Texture", 2D) = "white" {}
		DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
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

			uniform sampler2D DiffuseTexture;
			uniform float4 DiffuseColor;

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
				return tex2D(DiffuseTexture, Input.uv) * DiffuseColor;
			}

			ENDCG
		}
	}
}
