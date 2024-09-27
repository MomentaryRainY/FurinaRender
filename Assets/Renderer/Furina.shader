Shader "Furina"
{
    Properties {
        //面板参数
        [Space(20.0)]
        [Toggle]_genshinShader( "是否是脸部" , float) = 0.0

        [Space(15.0)]
        [NoScaleOffset]_diffuse( "Diffuse" , 2d) = "white"{}
        _fresnel( "边缘光范围" , Range(0.0, 10.0)) = 1.7
        _edgeLight( "边缘光强度" , Range(0.0, 1.0)) = 0.02
        [Space(8.0)]
        _diffuseA( "Alpha(1透明, 2自发光)" , Range(0.0, 2.0)) = 0
        _Cutoff( "透明阈值" , Range(0.0, 1.0)) = 1.0
        [HDR]_glow( "自发光强度" , color) = (1.0, 1.0, 1.0, 1.0)
        _flicker( "发光闪烁速度" , float) = 0.8
        [Space(30.0)]

        [NoScaleOffset]_lightmap( "Lightmap/FaceLightmap" , 2d) = "white"{}
        _bright( "亮面范围" , float) = 0.99
        _grey( "灰面范围" , float) = 1.14
        _dark( "暗面范围" , float) = 0.5
        [Space(30.0)]

        [NoScaleOffset]_bumpMap( "Normalmap" , 2d) = "bump"{}
        _bumpScale( "法线强度" , float) = 1.0
        [Space(30.0)]

        [NoScaleOffset]_ramp( "Shadow_Ramp" , 2d) = "white"{}
        [Toggle]_dayAndNight("是否是白天" , float) = 0.0
        [Space(8.0)]
        _lightmapA0("1.0_Ramp条数" , Range(1, 5)) = 1
        _lightmapA1("0.7_Ramp条数" , Range(1, 5)) = 4
        _lightmapA2("0.5_Ramp条数" , Range(1, 5)) = 3
        _lightmapA3("0.3_Ramp条数" , Range(1, 5)) = 5
        _lightmapA4("0.0_Ramp条数" , Range(1, 5)) = 2
        [Space(30.0)]

        [NoScaleOffset]_metalMap( "MetalMap" , 2d) = "white"{}
        _gloss( "高光范围" , Range(1, 256.0)) = 1
        _glossStrength( "高光强度" , Range(0.0, 1.0)) = 1
        _metalMapColor( "金属反射颜色" , color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30.0)]
    
        _outline( "描边粗细" , Range(0.0, 1.0)) = 0.4
        _outlineColor0( "描边颜色1" , color) = (1.0, 0.0, 0.0, 0.0)
        _outlineColor1( "描边颜色2" , color) = (0.0, 1.0, 0.0, 0.0)
        _outlineColor2( "描边颜色3" , color) = (0.0, 0.0, 1.0, 0.0)
        _outlineColor3( "描边颜色4" , color) = (1.0, 1.0, 0.0, 0.0)
        _outlineColor4( "描边颜色5" , color) = (0.5, 0.0, 1.0, 0.0)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
            }

        HLSLINCLUDE
        //导入库
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  //默认库
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"  //光照库
        CBUFFER_START(UnityPerMaterial)  //常量缓冲区开头
            //声明面板参数
            float _genshinShader;  //是否是脸部
            //diffuse
            float _fresnel;  //边缘光范围
            float _edgeLight;  //边缘光强度
            float _diffuseA;  //diffuseA
            float _Cutoff;  //透明阈值
            float4 _glow;  //自发光强度
            float _flicker;  //发光闪烁速度
            //lightmap/FaceLightmap
            float _bright;  //亮面范围
            float _grey;  //灰面范围
            float _dark;  //暗面范围
            //normal
            float _bumpScale;  //法线强度
            //ramp
            float _dayAndNight;  //是否是白天
            float _lightmapA0;  //1.0_Ramp条数
            float _lightmapA1;  //0.7_Ramp条数
            float _lightmapA2;  //0.5_Ramp条数
            float _lightmapA3;  //0.3_Ramp条数
            float _lightmapA4;  //0.0_Ramp条数
            //高光
            float _gloss;  //高光范围
            float _glossStrength;  //高光强度
            float3 _metalMapColor;  //金属折射颜色
            //描边
            float _outline;  //描边粗细
            float3 _outlineColor0;  //描边颜色1
            float3 _outlineColor1;  //描边颜色2
            float3 _outlineColor2;  //描边颜色3
            float3 _outlineColor3;  //描边颜色4
            float3 _outlineColor4;  //描边颜色5
        CBUFFER_END  //常量缓冲区结尾
            //声明贴图
            TEXTURE2D(_diffuse);  //Diffuse
            SAMPLER(sampler_diffuse);
            TEXTURE2D(_lightmap);  //Lightmap/FaceLightmap
            SAMPLER(sampler_lightmap);
            TEXTURE2D(_bumpMap);  //Normal
            SAMPLER(sampler_bumpMap);
            TEXTURE2D(_ramp);  //Shadow_Ramp
            SAMPLER(sampler_ramp);
            TEXTURE2D(_metalMap);  //MetalMap
            SAMPLER(sampler_metalMap);
        ENDHLSL

        //渲染正面
        Pass {  //pass语义段
            Tags { "LightMode" = "head" }  //渲染标签

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            //输入结构
            struct a2v {
                float4 vertex : POSITION;  //获取顶点数据
                float2 texcoord0 : TEXCOORD0;  //获取uv0
                float3 normal : NORMAL;  //获取顶点法线
                float4 tangent : TANGENT;  //获取顶点切线
            };

            //输出结构
            struct v2f {
                float4 pos : SV_POSITION;  //顶点数据
                float2 uv0 : TEXCOORD0;  //uv0
                //矩阵
                float4 TtoW0 : TEXCOORD1;  //x切线,y副切线,z法线,w顶点
                float4 TtoW1 : TEXCOORD2;  //x切线,y副切线,z法线,w顶点
                float4 TtoW2 : TEXCOORD3;  //x切线,y副切线,z法线,w顶点
            };

            //高光
            float3 Spec(float NdotL, float NdotH, float3 nDirVS, float4 lightmap, float3 baseColor){
                float blinnPhong = pow(max(0.0, NdotH), _gloss);  //Blinn-Phong
                float3 specular = blinnPhong * lightmap.r * _glossStrength;  //高光强度
                specular = specular * lightmap.b;  //混合高光细节
                specular = baseColor * specular;  //叠加固有色
                lightmap.g = smoothstep(0.2, 0.3, lightmap.g);  //lightmap.g
                float halfLambert = smoothstep(0.0, _grey, NdotL + _dark) * lightmap.g;  //半Lambert
                float brightMask = step(_bright, halfLambert);  //亮面
                specular = specular * brightMask;  //遮罩暗面
                return specular;  //输出结果
            }

            float3 shadow_ramp(float4 lightmap, float NdotL){
                lightmap.g = smoothstep(0.2, 0.3, lightmap.g);  //lightmap.g
                float halfLambert = smoothstep(0.0, _grey, NdotL + _dark) * lightmap.g;  //半Lambert
                float brightMask = step(_bright, halfLambert);  //亮面
                //判断白天与夜晚
                float rampSampling = 0.0;
                if(_dayAndNight == 0){rampSampling = 0.5;}
                //计算ramp采样条数
                float ramp0 = _lightmapA0 * -0.1 + 1.05 - rampSampling;  //0.95
                float ramp1 = _lightmapA1 * -0.1 + 1.05 - rampSampling;  //0.65
                float ramp2 = _lightmapA2 * -0.1 + 1.05 - rampSampling;  //0.75
                float ramp3 = _lightmapA3 * -0.1 + 1.05 - rampSampling;  //0.55
                float ramp4 = _lightmapA4 * -0.1 + 1.05 - rampSampling;  //0.45
                //分离lightmap.a各材质
                float lightmapA2 = step(0.25, lightmap.a);  //0.3
                float lightmapA3 = step(0.45, lightmap.a);  //0.5
                float lightmapA4 = step(0.65, lightmap.a);  //0.7
                float lightmapA5 = step(0.95, lightmap.a);  //1.0
                //重组lightmap.a
                float rampV = ramp0;  //0.0
                rampV = lerp(rampV, ramp1, lightmapA2);  //0.3
                rampV = lerp(rampV, ramp2, lightmapA3);  //0.5
                rampV = lerp(rampV, ramp3, lightmapA4);  //0.7
                rampV = lerp(rampV, ramp4, lightmapA5);  //1.0
                //采样ramp
                float3 ramp = SAMPLE_TEXTURE2D(_ramp, sampler_ramp, float2(halfLambert, rampV)); //横向采样，右u下v
                float3 shadowRamp = lerp(ramp, halfLambert, brightMask);  //遮罩亮面
                return shadowRamp;  //输出结果
            }

            //边缘
            float3 edgeLight(float NdotV, float3 baseColor, float4 lightmap){
                float3 fresnel = pow(1 - NdotV, _fresnel);  //菲涅尔范围
                fresnel = step(0.95, fresnel) * _edgeLight;//;  //边缘光强度
                float edgeColor = lightmap.a;
                float3 color = float3(0.6, 0.2, 0.2);
                color = lerp(color, float3(0, 0, 0), step(0.2, edgeColor)); 
                color = lerp(color, float3(0, 0, 0), step(0.4, edgeColor)); 
                color = lerp(color, float3(0, 0, 0), step(0.6, edgeColor)); 
                color = lerp(color, float3(0.6, 0.2, 0.2), step(0.8, edgeColor)); //皮肤
                return color * fresnel;  //输出结果
            }

            //金属
            float3 Metal(float3 nDirVS, float4 lightmap, float3 baseColor){
                float metalMask = 1 - step(lightmap.r, 0.9);  //金属遮罩
                //采样metalMap
                float3 metalMap = SAMPLE_TEXTURE2D(_metalMap, sampler_metalMap, nDirVS.rg * 0.5 + 0.5).r;
                metalMap = lerp(_metalMapColor, baseColor, metalMap);  //金属反射颜色
                metalMap = lerp(0.0, metalMap, metalMask);  //遮罩非金属区域
                return metalMap;  //输出结果
            }

            //身体
            float3 Body(float NdotL, float NdotH, float NdotV, float4 lightmap, float3 baseColor, float3 nDirVS){
                float3 ramp = shadow_ramp(lightmap, NdotL);  //ramp
                float3 specular = Spec(NdotL, NdotH, nDirVS, lightmap, baseColor);  //高光
                float3 metal = Metal(nDirVS, lightmap, baseColor);  //金属
                float3 diffsue = baseColor * ramp;  //漫反射
                diffsue = diffsue * step(lightmap.r, 0.9);  //遮罩金属区域
                float3 fresnel = edgeLight(NdotV, baseColor, lightmap);  //边缘光
                //混合最终结果
                float3 body = (diffsue + metal + specular) * step(0.01, pow(max(NdotV, 0.01), _fresnel)) + fresnel;
                return body;  //输出结果
            }

            //脸部
            float3 Face(float2 uv, float3 lDirWS, float3 baseColor){
                float SDF = SAMPLE_TEXTURE2D(_lightmap, sampler_lightmap, uv);
                float SDF2 = SAMPLE_TEXTURE2D(_lightmap, sampler_lightmap, float2(1 - uv.x, uv.y));
                 float3 up = float3(0,1,0);  //上方向
                float3 front = unity_ObjectToWorld._13_23_33;  //角色前朝向
                float3 left = cross(front, up);  //左侧朝向
                float3 right = -cross(front, up);  //右侧朝向
                //点乘向量
                float frontL = dot(normalize(front.xz), normalize(lDirWS.xz));  //前点乘光
                float leftL = dot(normalize(left.xz), normalize(lDirWS.xz));  //左点乘光
                float rightL = dot(normalize(right.xz), normalize(lDirWS.xz));  //右点乘光
                //计算阴影
                float lightAttenuation = (frontL > 0) * min((SDF > leftL), 1 - (SDF2 < rightL));
                float rampSampling = 0.0;
                if(_dayAndNight == 0){rampSampling = 0.5;}
                //计算V轴
                float rampV = _lightmapA4 * -0.1 + 1.05 - rampSampling;  //0.85
                //采样ramp
                float3 rampColor = SAMPLE_TEXTURE2D(_ramp, sampler_ramp, float2(lightAttenuation, rampV));
                //混合baseColor
                float3 face = baseColor + lightAttenuation * rampColor * 0.1;
                //lerp(baseColor * rampColor, baseColor, lightAttenuation);
                return face;  //输出结果
            }

            //顶点Shader
            v2f vert (a2v v) {
                v2f o;  //定义返回值
                o.pos = TransformObjectToHClip(v.vertex.xyz);  //MVP变换(模型空间>>世界空间>>视觉空间>>裁剪空间)
                o.uv0 = v.texcoord0;  //传递uv0(无变换)
                float3 nDirWS = TransformObjectToWorldNormal(v.normal);  //世界空间法线
                float3 tDirWS = TransformObjectToWorld(v.tangent.xyz);  //世界空间切线
                float3 bDirWS = cross(nDirWS, tDirWS) * v.tangent.w;  //世界空间副切线
                float3 posWS = TransformObjectToWorld(v.vertex.xyz);  //世界顶点位置
                //构建矩阵
                o.TtoW0 = float4(tDirWS.x, bDirWS.x, nDirWS.x, posWS.x);  //x切线,y副切线,z法线,w顶点
                o.TtoW1 = float4(tDirWS.y, bDirWS.y, nDirWS.y, posWS.y);  //x切线,y副切线,z法线,w顶点
                o.TtoW2 = float4(tDirWS.z, bDirWS.z, nDirWS.z, posWS.z);  //x切线,y副切线,z法线,w顶点
                return o;  //返回顶点Shader
            }

            //片元Shader
            half4 frag (v2f i) : SV_TARGET {
                //采样贴图
                float3 baseColor = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, i.uv0).rgb;  //diffuseRGB通道
                float diffuseA = SAMPLE_TEXTURE2D(_diffuse,sampler_diffuse, i.uv0).a;  //diffuseA通道
                float4 lightmap = SAMPLE_TEXTURE2D(_lightmap, sampler_lightmap, i.uv0).rgba;  //lightmap
                //法线贴图
                float3 nDirTS = UnpackNormal(SAMPLE_TEXTURE2D(_bumpMap, sampler_bumpMap, i.uv0)).rgb;  //切线空间法线(采样法线贴图并解码)
                nDirTS.xy *= _bumpScale;  //法线强度
                nDirTS.z = sqrt(1.0 - saturate(dot(nDirTS.xy, nDirTS.xy)));  //计算法线z分量
                //准备向量
                float3 posWS = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);  //世界空间顶点
                //切线空间法线转世界空间法线
                float3 nDirWS = normalize(half3(dot(i.TtoW0.xyz, nDirTS), dot(i.TtoW1.xyz, nDirTS), dot(i.TtoW2.xyz, nDirTS)));
                Light mlight = GetMainLight();  //光源
                float3 lDirWS= normalize(mlight.direction);  //世界光源方向(平行光)
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - posWS.xyz);  //世界观察方向
                float3 nDirVS = normalize(mul((float3x3)UNITY_MATRIX_V, nDirWS));  //世界空间法线转观察空间法线
                float3 hDirWS = normalize(vDirWS + lDirWS) ;  //半角方向
                //向量点乘
                float NdotL = dot(nDirWS, lDirWS);  //兰伯特
                float NdotH = dot(nDirWS, hDirWS);  //Blinn-Phong
                float NdotV = dot(nDirWS, vDirWS);  //菲涅尔

                if (!_genshinShader) 
                //return lightmap.a;
                return half4(Body(NdotL, NdotH, NdotV, lightmap, baseColor, nDirVS), 1);
                else return half4(Face(i.uv0, lDirWS, baseColor),1);
            }
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
