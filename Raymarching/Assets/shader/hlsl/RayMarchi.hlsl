#ifndef RAYMARCHI_INCLUDE
#define RAYMARCHI_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "hlsl/Distance.hlsl"

struct Attributes
{
	float4 positionOS        : POSITION;
	float2 uv : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
	float4 positionCS			: SV_POSITION;
	float2 uv					: TEXCOORD0;
	float3 positionWS           : TEXCOORD1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};

struct Ray
{
	float3 origin;
	float3 direction;
};

Varyings vert(Attributes input)
{
	Varyings output = (Varyings)0;

	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
	
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
	
	output.positionWS = vertexInput.positionWS;
	output.positionCS = vertexInput.positionCS;
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
	return output;
}

FragmentOutput GBuffer(InputData inputData, SurfaceData surfaceData)
{
	FragmentOutput output;

	// Material flags
	uint materialFlags = 0;
#if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
	materialFlags |= kMaterialFlagSubtractiveMixedLighting;  // For subtractive mixed lighting
#endif
// We do not set kMaterialFlagReceiveShadowsOff, kMaterialFlagSpecularHighlightsOff
// as this sample always has shadows and specular highlights enabled
	float materialFlagsPacked = PackMaterialFlags(materialFlags);

	// Normals
	float3 normalWS = PackNormal(inputData.normalWS);

	// GI + Emission
	Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
	MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
	half3 giEmission = (inputData.bakedGI * surfaceData.albedo) + surfaceData.emission;

	// GBuffer0
	output.GBuffer0.rgb = surfaceData.albedo;  // Albedo
	output.GBuffer0.a = materialFlagsPacked;   // Material flags

	// GBuffer1
	output.GBuffer1.rgb = surfaceData.specular;  // Specular color
	output.GBuffer1.a = 0;                       // Occlusion (occlusion not included in this sample)

	// GBuffer2
	output.GBuffer2.rgb = normalWS;              // World space normals
	output.GBuffer2.a = surfaceData.smoothness;  // Smoothness

	// GBuffer3
	output.GBuffer3.rgb = giEmission;  // GI + Emission
	output.GBuffer3.a = 1;

	// GBUFFER_SHADOWMASK (shadow mask)
#if OUTPUT_SHADOWMASK
	output.GBUFFER_SHADOWMASK = inputData.shadowMask;
#endif

	// GBUFFER_LIGHT_LAYERS (light layer)
#ifdef _LIGHT_LAYERS
	uint lightLayer = GetMeshRenderingLightLayer();
	output.GBUFFER_LIGHT_LAYERS = float4((lightLayer & 0x000000FF) / 255.0, 0.0, 0.0, 0.0);
#endif

	// GBUFFER_OPTIONAL_SLOT_1 (depth as color if Native Render Pass is enabled)
#if _RENDER_PASS_ENABLED
	output.GBUFFER_OPTIONAL_SLOT_1 = inputData.positionCS.z;
#endif

	return output;
}

// シーン内の距離関数
float sceneDist(float3 position)
{
	return sdSphere(position, 3.5);
}

// シーン内の法線取得
float3 getNormal(float3 position)
{
	float delta = 0.0001;
	float fx = sceneDist(position) - sceneDist(float3(position.x - delta, position.y, position.z));
	float fy = sceneDist(position) - sceneDist(float3(position.x, position.y - delta, position.z));
	float fz = sceneDist(position) - sceneDist(float3(position.x, position.y, position.z - delta));
	return normalize(float3(fx, fy, fz));
}


FragmentOutput frag(Varyings input)
{
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

	half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

	float3 lightDir = normalize(float3(1.0, -1.0, 1.0) * -1);
	float2 pos = (input.positionWS.xy * 2.0 - _ScreenParams.xy) / min(_ScreenParams.x, _ScreenParams.y);

	// レイの定義
	Ray ray;
	ray.origin = float3(0.0, 0.0, -50.0);
	ray.direction = normalize(float3(pos.x, pos.y, 6.0));
	float3 normal = 0;

	for (int i = 0; i < 16; i++)
	{
		float dist = sceneDist(ray.origin);
		if (dist < 0.0001)
		{
			// 距離が十分に短かったら衝突したと判定して色を計算する
			normal = getNormal(ray.origin);
			color.rgb = 1.0;
			color.a = 1.0;
			break;
		}
		// レイを進める
		ray.origin += ray.direction * dist;
	}


	// outputdata
	InputData inputData = (InputData)0;
	inputData.positionWS = input.positionWS;
	inputData.normalWS = normal;
	inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

	SurfaceData surfaceData = (SurfaceData)0;
	surfaceData.albedo = color.rgb;
	surfaceData.alpha = color.a;
	surfaceData.occlusion = 1;

	FragmentOutput output = GBuffer(inputData, surfaceData);

	return output;
}

#endif
