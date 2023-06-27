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

			// プラットフォーム
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			// 頂点、フラグメント
			#pragma vertex vert
			#pragma fragment frag

			// GPUインスタンシング
			#pragma multi_compile_instancing

			// URP core
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			// プロパティー
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

			// プラットフォーム
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			// Vertex/fragment functions used in URP's DepthNormalsPass
			#pragma vertex DepthNormalsVertex
			#pragma fragment DepthNormalsFragment

			// GPUインスタンシング
			#pragma multi_compile_instancing

			// URP core
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			// プロパティー

			#include "hlsl/RayMarchiDepth.hlsl"

			ENDHLSL
		}
    }
}
