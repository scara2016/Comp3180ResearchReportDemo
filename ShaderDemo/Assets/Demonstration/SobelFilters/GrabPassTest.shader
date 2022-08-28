Shader "Unlit/GrabPassTest"
{
	SubShader{

	Tags{"Queue" = "Transparent"}

	GrabPass
	{
	  "_GrabTexture"
	}

	pass {
	CGPROGRAM
	#pragma vertex vertex
	#pragma fragment fragment

	#include "UnityCG.cginc"

		sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;

	struct VertexData {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	};
	struct Interpolaters {
	float4 uv : TEXCOORD0;
	float4 vertex: SV_POSITION;
	};

	Interpolaters vertex(VertexData v)
	{
		 Interpolaters i;
		 i.vertex = UnityObjectToClipPos(v.vertex);
		 i.uv = ComputeGrabScreenPos(i.vertex);
		 return i;
	}

	 float sobel(sampler2D tex, float2 uv) {
		float2 delta = float2(0.01, 0.01);

				float4 hr = float4(0, 0, 0, 0);
				float4 vt = float4(0, 0, 0, 0);

				hr += tex2D(tex, (uv + float2(-1.0, -1.0) * delta)) * 1.0;
				hr += tex2D(tex, (uv + float2(0.0, -1.0) * delta)) * 0.0;
				hr += tex2D(tex, (uv + float2(1.0, -1.0) * delta)) * -1.0;
				hr += tex2D(tex, (uv + float2(-1.0,  0.0) * delta)) * 2.0;
				hr += tex2D(tex, (uv + float2(0.0,  0.0) * delta)) * 0.0;
				hr += tex2D(tex, (uv + float2(1.0,  0.0) * delta)) * -2.0;
				hr += tex2D(tex, (uv + float2(-1.0,  1.0) * delta)) * 1.0;
				hr += tex2D(tex, (uv + float2(0.0,  1.0) * delta)) * 0.0;
				hr += tex2D(tex, (uv + float2(1.0,  1.0) * delta)) * -1.0;

				vt += tex2D(tex, (uv + float2(-1.0, -1.0) * delta)) * 1.0;
				vt += tex2D(tex, (uv + float2(0.0, -1.0) * delta)) * 2.0;
				vt += tex2D(tex, (uv + float2(1.0, -1.0) * delta)) * 1.0;
				vt += tex2D(tex, (uv + float2(-1.0,  0.0) * delta)) * 0.0;
				vt += tex2D(tex, (uv + float2(0.0,  0.0) * delta)) * 0.0;
				vt += tex2D(tex, (uv + float2(1.0,  0.0) * delta)) * 0.0;
				vt += tex2D(tex, (uv + float2(-1.0,  1.0) * delta)) * -1.0;
				vt += tex2D(tex, (uv + float2(0.0,  1.0) * delta)) * -2.0;
				vt += tex2D(tex, (uv + float2(1.0,  1.0) * delta)) * -1.0;

				return sqrt(hr * hr + vt * vt);		
	}



	float4 fragment(Interpolaters i) : SV_Target
	{
	 float2 convertedUV = float2(i.uv.x/i.uv.w, i.uv.y/i.uv.w);
	 float s = sobel(_GrabTexture, convertedUV);
	 float4 color = tex2Dproj(_GrabTexture, i.uv);
	color = saturate((1 - color) - 0.5);
	//return color;
	return float4(s,s,s,1);

	}
	ENDCG
		}
	}
}
