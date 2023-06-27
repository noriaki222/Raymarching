Shader "Custom/Ray"
{
	Properties
	{
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
			"IgnoreProjector" = "True"
			"ShaderModel" = "4.5"
		}
		LOD 200

		// Buffer Pass
		Pass
		{
			Name "ForwardOnly"
			Tags { "LightMode" = "UniversalForwardOnly" }
			ZWrite On
			Cull Back
			ZTest LEqual

			HLSLPROGRAM

			// �v���b�g�t�H�[��
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			// ���_�A�t���O�����g
			#pragma vertex vert
			#pragma fragment frag

			// GPU�C���X�^���V���O
			#pragma multi_compile_instancing

			// URP core
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			// �v���p�e�B�[
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			CBUFFER_END

			#include "hlsl/Distance.hlsl"


			float3 lightDir = float3(1.0, 1.0, 1.0);

			struct Ray
			{
				float3 origin;
				float3 direction;
			};

			// ���̋����֐�
			float sphereDist(float3 position, float radius)
			{
				return length(position) - radius;
			}

			// �V�[���̋����֐�
			float sceneDist(float3 position)
			{
				return sphereDist(position, 3.5);
			}

			// ���C���Ԃ������ʒu�ɂ�����@�����擾
			float3 getNormal(float3 position)
			{
				float delta = 0.0001;
				float fx = sceneDist(position) - sceneDist(float3(position.x - delta, position.y, position.z));
				float fy = sceneDist(position) - sceneDist(float3(position.x, position.y - delta, position.z));
				float fz = sceneDist(position) - sceneDist(float3(position.x, position.y, position.z - delta));
				return normalize(float3(fx, fy, fz));
			}

			void vert(float4 vertex : POSITION, out float4 position : SV_POSITION)
			{
				VertexPositionInputs vertexInput = GetVertexPositionInputs(vertex);
				position = vertexInput.positionCS;
			}

			float4 frag(float4 vpos : SV_POSITION) : SV_Target
			{
				float3 lightDir = normalize(float3(1.0, -1.0, 1.0) * -1);
				// �c���̂����Z���ق���-1�`1�ɂȂ�悤�Ȓl���v�Z����
				float2 pos = (vpos.xy * 2.0 - _ScreenParams.xy) / min(_ScreenParams.x, _ScreenParams.y);
				// �v���b�g�t�H�[���̈Ⴂ���z��
				#if UNITY_UV_STARTS_AT_TOP
					pos.y *= -1;
				#endif

				// ���C���`
				Ray ray;
				ray.origin = float3(0.0, 0.0, -50.0);
				ray.direction = normalize(float3(pos.x, pos.y, 6.0));

				float3 color = 0;
				for (int i = 0; i < 16; i++)
				{
					float dist = sceneDist(ray.origin);
					if (dist < 0.0001)
					{
						// �������\���ɒZ��������Փ˂����Ɣ��肵�ĐF���v�Z����
						float3 normal = getNormal(ray.origin);
						float diff = dot(normal, lightDir);
						color = diff;
						break;
					}
					// ���C��i�߂�
					ray.origin += ray.direction * dist;
				}

				return float4(color, 1.0);
			}
			ENDHLSL
		}
    }
}
