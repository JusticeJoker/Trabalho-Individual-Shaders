Shader "Custom/Planet"
{
    Properties {
      _DayTex ("dayTexture", 2D) = "white" {}
      _NightTex ("nightTexture", 2D) = "white" {}
      _Pickle ("pickleRickTexture", 2D) = "white" {}
      _emission("Display Name", Range(0, 0.5)) = 0
      _YellowColor ("Color", Color) = (1, 1, 0, 1)
      _WaterTex ("waterTexture", 2D) = "white" {}

      [Toggle(USE_TEXTURE)] _UseTextureWater("Water", Float) = 0
      [Toggle(USE_TEXTURE)] _UseTextureEmpty("Empty", Float) = 0

    }
    SubShader{

        Tags { "RenderType" = "Opaque"}

        Cull Front

        CGPROGRAM

        #pragma surface surf Lambert alpha

        sampler2D _Pickle;

        struct Input {
            float2 uv_Pickle;
        };

        void surf(Input IN, inout SurfaceOutput o){
            fixed4 c = tex2D(_Pickle, IN.uv_Pickle); 
            o.Albedo = c.rgb;
            o.Normal = -UnpackNormal(tex2D(_Pickle, IN.uv_Pickle));
            o.Alpha = c.a;
        }

        
        ENDCG   

        Cull Back

        CGPROGRAM

        #pragma surface surf Lambert 
        #pragma shader_feature USE_TEXTURE

        struct Input {

            float2 uv_DayTex;
            float2 uv_NightTex;
            float2 uv_WaterTex;
            float3 viewDir;
        };

        float3 lightDir;
        sampler2D _DayTex;
        sampler2D _NightTex;
        sampler2D _WaterTex;
        fixed4 _YellowColor;
        float _emission;


        float _UseTextureWater;
        float _UseTextureEmpty;

        void surf(Input IN, inout SurfaceOutput o) {

            //gives us the normalized world space light
            lightDir = normalize(_WorldSpaceLightPos0.xyz);

            //and the dot product from the light and the normal gives us the part that is beeing lighten if we check > or < then 0
            float dotp = dot(lightDir, o.Normal);

            //check iluminated area so its the day
            //if the dot product is biggger than 0, then we are taking light and we apply the day texture
            if (dotp > 0)
            {
                o.Albedo = tex2D(_DayTex, IN.uv_DayTex);
                o.Alpha = 1;

                if (_UseTextureEmpty == 1)
                {
                    if (o.Albedo.b > o.Albedo.g && o.Albedo.b > o.Albedo.r)
                    {
                        discard;
                    }
                    else{
                        o.Albedo = tex2D(_DayTex, IN.uv_DayTex);
                    }
                }
                
                if (_UseTextureWater == 1)
                {
                    if (o.Albedo.b > o.Albedo.g && o.Albedo.b > o.Albedo.r)
                    {
                        float2 rotation = float2(sin(_Time.y + IN.uv_WaterTex.y )* 0.1, cos(_Time.y + IN.uv_WaterTex.y) * 0.1);
                        o.Albedo = tex2D(_WaterTex, IN.uv_WaterTex + rotation);
                    }

                }
            }
            else //else we apply the night texture
            {
                o.Albedo = tex2D(_NightTex, IN.uv_NightTex);
                o.Emission = (o.Albedo * _YellowColor) * tex2D(_NightTex, IN.uv_NightTex).a * _emission;
                o.Alpha = 1;
            }

        }
        ENDCG
    }
    Fallback "Diffuse"
}
