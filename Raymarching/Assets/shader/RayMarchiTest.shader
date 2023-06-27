Shader "Custom/RayMarchiTest"
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
			Name "GBuffer"
			Tags { "LightMode" = "UniversalGBuffer" }
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

			#include "hlsl/RayMarchi.hlsl"

			ENDHLSL
		}

		Pass
		{
			Name "DepthNormals"
			Tags{"LightMode" = "DepthNormals"}
			ZWrite On
			Cull Back

			HLSLPROGRAM

			// �v���b�g�t�H�[��
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			// Vertex/fragment functions used in URP's DepthNormalsPass
			#pragma vertex DepthNormalsVertex
			#pragma fragment DepthNormalsFragment

			// GPU�C���X�^���V���O
			#pragma multi_compile_instancing

			// URP core
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			// �v���p�e�B�[

			#include "hlsl/RayMarchiDepth.hlsl"

			ENDHLSL
		}
    }
}
