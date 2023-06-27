// ‹——£ŠÖ”
#ifndef DISTANCE_INCLUDE
#define DISTANCE_INCLUDE

// https://iquilezles.org/articles/distfunctions/

float sdSphere(float3 p, float s)
{
	return length(p) - s;
}

float sdBox(float3 p, float3 b)
{
	float3 q = abs(p) - b;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdRoundBox(float3 p, float3 b, float r)
{
	float3 q = abs(p) - b;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdBoxFrame(float3 p, float3 b, float e)
{
	p = abs(p) - b;
	float3 q = abs(p + e) - e;
	return min(min(
		length(max(float3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0),
		length(max(float3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)),
		length(max(float3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}

float sdTorus(float3 p, float2 t)
{
	float2 q = float2(length(p.xz) - t.x, p.y);
	return length(q) - t.y;
}

float sdCappedTorus(float3 p, float2 sc, float ra, float rb)
{
	p.x = abs(p.x);
	float k = (sc.y*p.x > sc.x*p.y) ? dot(p.xy, sc) : length(p.xy);
	return sqrt(dot(p, p) + ra * ra - 2.0*ra*k) - rb;
}

float sdLink(float3 p, float le, float r1, float r2)
{
	float3 q = float3(p.x, max(abs(p.y) - le, 0.0), p.z);
	return length(float2(length(q.xy) - r1, q.z)) - r2;
}

float sdCylinder(float3 p, float3 c)
{
	return length(p.xz - c.xy) - c.z;
}

#endif
