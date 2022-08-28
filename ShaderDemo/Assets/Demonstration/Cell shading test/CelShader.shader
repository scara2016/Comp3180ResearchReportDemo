Shader "Custom/CelShader"
{
     Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _LightingRamp ("Lighting Ramp", 2D) = "white" {}
        _Color ("TInt Color", Color) = (1, 1, 1, 1)
        _Antialiasing("Band Smoothing", Float) = 5.0
        _Glossiness("Shinyness", Float) = 400
        _BumpMap("Normal/BumpMap", 2D) = "bump" {}
        _Fresnel("Fesnel Amount", Range(0,1)) = 0.5
        _OutlineSize("Outline Size", Float) = 0.01
        _OutlineColor("Outline Color", Color) = (0,0,0,1)
        _ID("Stencil ID", Int) = 1
    }

    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque" 
            "LightMode" ="ForwardBase" 
        }
        
        pass 
        {
            Stencil
        {
            Ref [_ID]
            Comp Always
            Pass replace
            Fail Keep
            ZFail Keep
        }
        CGPROGRAM
        #pragma vertex vertex
        #pragma fragment fragment

        #include "unityCG.cginc"
        #include "Lighting.cginc"

        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _BumpMap;
        sampler2D _LightingRamp;
        float4 _Color;
        float _Glossiness;
        float _Antialiasing;
        float _Fresnel;

       

        struct VertexData
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
        };
        struct Interpolators
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 worldNormal: NORMAL;
            float3 viewDir : TEXCOORD1;
        };

        Interpolators vertex(VertexData v)
        {
            Interpolators i;
            i.vertex = UnityObjectToClipPos(v.vertex);
            i.uv = TRANSFORM_TEX(v.uv, _MainTex);
            i.worldNormal = UnityObjectToWorldNormal(v.normal);
            i.viewDir = WorldSpaceViewDir(v.vertex);
            return i;
        }

        float4 fragment(Interpolators i) : SV_TARGET
        {
 //           i.worldNormal = tex2D(_BumpMap,i.uv).rgb;
            i.worldNormal = normalize(i.worldNormal);

   /*         i.worldNormal.xy = float2(tex2D(_BumpMap, i.uv).w,tex2D(_BumpMap, i.uv).y);
            i.worldNormal.z = sqrt(1-saturate(dot(i.worldNormal.xy,i.worldNormal.xy)));
            i.worldNormal = i.worldNormal.xzy; */

            float4 diffuse = dot(_WorldSpaceLightPos0, i.worldNormal);
            //float delta = fwidth(diffuse)*_Antialiasing;
            //float diffuseSmooth= smoothstep(0, delta, diffuse);
            
            float4 diffuseSmooth = tex2D(_LightingRamp, float2(diffuse.r*0.3 +0.69, 0.5));
            float3 halfVec =normalize(_WorldSpaceLightPos0 + i.viewDir);
            float specular = dot(i.worldNormal, halfVec);
            specular = pow(specular * diffuseSmooth, _Glossiness);
            float specularSmooth = smoothstep(0, 0.01*_Antialiasing, specular);
            float rim = 1- dot(i.worldNormal, i.viewDir);
            rim = rim * diffuseSmooth;
            float fresnelSize = 1- _Fresnel;
            float fresnelSmooth = smoothstep(fresnelSize, fresnelSize*1.1, rim);
            float4 albedo = tex2D(_MainTex, i.uv) * _Color;
            float4 color = (albedo*(((diffuseSmooth+specularSmooth +fresnelSmooth)/3)*_LightColor0+unity_AmbientSky));
            return color;
        }
        ENDCG
        }

        pass
        {
            Stencil
            {
                Ref [_ID]
                Comp NotEqual
            }
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment

            #include "unityCG.cginc"
            
            float _OutlineSize;
            float4 _OutlineColor;
            
            struct VertexData
            {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            };
            
            struct Interpolators
            {
            float4 vertex : SV_POSITION;
            };

            Interpolators vertex(VertexData v)
            {
                Interpolators i;
                float3 normal = normalize(v.normal) * _OutlineSize;
                float3 pos = v.vertex + normal;
                i.vertex = UnityObjectToClipPos(pos);
                return i;
            }
            float4 fragment(Interpolators i) : SV_Target
            {
                return _OutlineColor;
            }


            ENDCG
        } 

    }
    FallBack "Diffuse"
}
