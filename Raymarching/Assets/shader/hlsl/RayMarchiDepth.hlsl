#ifndef RAYMARCHIDEPTH_INCLUDE
#define RAYMARCHIDEPTH_INCLUDE

struct Attributes
{
	float4 positionOS : POSITION;
	float2 uv : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
	float4 positionHCS : SV_POSITION;
	float2 uv : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};

struct FragOutput
{
	float4 normal : SV_Target;
	float depth : SV_Depth;
};

Varyings DepthNormalsVertex(Attributes IN)
{
	Varyings OUT;
	// GPU instancing
	UNITY_SETUP_INSTANCE_ID(IN);
	UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
	// Stereo
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
	OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
	OUT.uv = IN.uv;
	return OUT;
}

FragOutput DepthNormalsFragment(Varyings IN) : SV_Target
{
	// Instancing
	UNITY_SETUP_INSTANCE_ID(IN);
	// Stereo
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
	FragOutput o;
	o.normal = float4(0.0, 0.0, 0.0, 0.0);
	o.depth = 0.0;
	return o;
}

#endif
