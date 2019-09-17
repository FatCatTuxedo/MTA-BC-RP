 float2 gDistFade = float2(250, 150);
 float gBrightness = 1;
 float gDayTime = 1;
 float gTextureSize = 512.0;
 float3 gNormalStrength = float3(1,1,1);
 
 float gLight0Enable = 0;
 int gLight0Type = 1;
 float3 gLight0Position = float3(0,0,0);
 float4 gLight0Diffuse = float4(0,0,0,1);
 float gLight0Attenuation = 0; 
 bool gLight0NormalShadow = true;
 float3 gLight0Direction = float3(0.0, 0.0, -1.0);
 float gLight0Falloff  = 1.0;
 float gLight0Theta = 0;
 float gLight0Phi = 0; 
 float gLight1Enable = 0;
 int gLight1Type = 1;
 float3 gLight1Position = float3(0,0,0);
 float4 gLight1Diffuse = float4(0,0,0,1);
 float gLight1Attenuation = 0; 
 bool gLight1NormalShadow = true;
 float3 gLight1Direction = float3(0.0, 0.0, -1.0);
 float gLight1Falloff  = 1.0;
 float gLight1Theta = 0;
 float gLight1Phi = 0; 
 float gLight2Enable = 0;
 int gLight2Type = 1;
 float3 gLight2Position = float3(0,0,0);
 float4 gLight2Diffuse = float4(0,0,0,1);
 float gLight2Attenuation = 0; 
 bool gLight2NormalShadow = true;
 float3 gLight2Direction = float3(0.0, 0.0, -1.0);
 float gLight2Falloff  = 1.0;
 float gLight2Theta = 0;
 float gLight2Phi = 0; 
 float gLight3Enable = 0;
 int gLight3Type = 1;
 float3 gLight3Position = float3(0,0,0);
 float4 gLight3Diffuse = float4(0,0,0,1);
 float gLight3Attenuation = 0; 
 bool gLight3NormalShadow = true;
 float3 gLight3Direction = float3(0.0, 0.0, -1.0);
 float gLight3Falloff  = 1.0;
 float gLight3Theta = 0;
 float gLight3Phi = 0; 
 float gLight4Enable = 0;
 int gLight4Type = 1;
 float3 gLight4Position = float3(0,0,0);
 float4 gLight4Diffuse = float4(0,0,0,1);
 float gLight4Attenuation = 0; 
 bool gLight4NormalShadow = true;
 float3 gLight4Direction = float3(0.0, 0.0, -1.0);
 float gLight4Falloff  = 1.0;
 float gLight4Theta = 0;
 float gLight4Phi = 0; 
 float gLight5Enable = 0;
 int gLight5Type = 1;
 float3 gLight5Position = float3(0,0,0);
 float4 gLight5Diffuse = float4(0,0,0,1);
 float gLight5Attenuation = 0; 
 bool gLight5NormalShadow = true;
 float3 gLight5Direction = float3(0.0, 0.0, -1.0);
 float gLight5Falloff  = 1.0;
 float gLight5Theta = 0;
 float gLight5Phi = 0; 
 float gLight6Enable = 0;
 int gLight6Type = 1;
 float3 gLight6Position = float3(0,0,0);
 float4 gLight6Diffuse = float4(0,0,0,1);
 float gLight6Attenuation = 0; 
 bool gLight6NormalShadow = true;
 float3 gLight6Direction = float3(0.0, 0.0, -1.0);
 float gLight6Falloff  = 1.0;
 float gLight6Theta = 0;
 float gLight6Phi = 0; 
 float gLight7Enable = 0;
 int gLight7Type = 1;
 float3 gLight7Position = float3(0,0,0);
 float4 gLight7Diffuse = float4(0,0,0,1);
 float gLight7Attenuation = 0; 
 bool gLight7NormalShadow = true;
 float3 gLight7Direction = float3(0.0, 0.0, -1.0);
 float gLight7Falloff  = 1.0;
 float gLight7Theta = 0;
 float gLight7Phi = 0; 
 float4x4 gWorld : WORLD;
 float4x4 gView : VIEW;
 float4x4 gProjection : PROJECTION;
 float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
 float4x4 gWorldInverseTranspose : WORLDINVERSETRANSPOSE;
 float3 gCameraPosition : CAMERAPOSITION; 
 #include "common.txt" 
 #include "light1.txt" 
 texture gTexture0 < string textureState="0,Texture"; >;
 sampler Sampler0 = sampler_state
 {
 Texture = (gTexture0);
 };
  texture gTexture1 < string textureState="1,Texture"; >;
 sampler Sampler1 = sampler_state
 {
 Texture = (gTexture1);
 }; 
 struct VSInput{
 float4 Position : POSITION0;
 float3 TexCoord : TEXCOORD0;
 float2 TexCoord1 : TEXCOORD1;
 float4 Normal : NORMAL0;
 float4 Diffuse : COLOR0;
 }; 
 struct PSInput{
 float4 Position : POSITION;
 float2 TexCoord : TEXCOORD0;
 float DistFade : TEXCOORD1;
 float3 WorldPos : TEXCOORD2;
 float4 Diffuse : COLOR0;
 float4 ViewPos : TEXCOORD4; 
 float3 Normal : TEXCOORD3; 
 }; 
 PSInput VertexShaderSB(VSInput VS)
 {
 PSInput PS = (PSInput)0;
 PS.Position = mul(VS.Position, gWorldViewProjection);
 PS.ViewPos = PS.Position;
 PS.WorldPos = mul(float4(VS.Position.xyz,1), gWorld).xyz;
 PS.TexCoord = VS.TexCoord; 
 float DistanceFromCamera = distance( gCameraPosition, PS.WorldPos ); 
 PS.Normal = mul(VS.Normal, gWorldInverseTranspose); 
 PS.DistFade = MTAUnlerp ( gDistFade[0], gDistFade[1], DistanceFromCamera ); 
 float4 Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse ); 
 float brightness = gBrightness; 
 Diffuse.rgb *= brightness; 
 PS.Diffuse = saturate(Diffuse);
 return PS;
 } 
 struct PSOutput 
 {
 float4 color : COLOR0; 
 float depth : DEPTH; 
 }; 
 PSOutput PixelShaderSB(PSInput PS)
 {
 PSOutput output = (PSOutput)0;
 float4 texel = tex2D(Sampler0, PS.TexCoord);
 float4 texLight = 0;
 float3 Normal = 0; 
 Normal = normalize( PS.Normal ); 
 if (gLight0Enable) texLight += createLight(Normal, PS.WorldPos, gLight0Type, gLight0Position, gLight0Direction, gLight0Diffuse, gLight0Attenuation, gLight0Phi, gLight0Theta, gLight0Falloff, gLight0NormalShadow ); 
 if (gLight1Enable) texLight += createLight(Normal, PS.WorldPos, gLight1Type, gLight1Position, gLight1Direction, gLight1Diffuse, gLight1Attenuation, gLight1Phi, gLight1Theta, gLight1Falloff, gLight1NormalShadow ); 
 if (gLight2Enable) texLight += createLight(Normal, PS.WorldPos, gLight2Type, gLight2Position, gLight2Direction, gLight2Diffuse, gLight2Attenuation, gLight2Phi, gLight2Theta, gLight2Falloff, gLight2NormalShadow ); 
 if (gLight3Enable) texLight += createLight(Normal, PS.WorldPos, gLight3Type, gLight3Position, gLight3Direction, gLight3Diffuse, gLight3Attenuation, gLight3Phi, gLight3Theta, gLight3Falloff, gLight3NormalShadow ); 
 if (gLight4Enable) texLight += createLight(Normal, PS.WorldPos, gLight4Type, gLight4Position, gLight4Direction, gLight4Diffuse, gLight4Attenuation, gLight4Phi, gLight4Theta, gLight4Falloff, gLight4NormalShadow ); 
 if (gLight5Enable) texLight += createLight(Normal, PS.WorldPos, gLight5Type, gLight5Position, gLight5Direction, gLight5Diffuse, gLight5Attenuation, gLight5Phi, gLight5Theta, gLight5Falloff, gLight5NormalShadow ); 
 if (gLight6Enable) texLight += createLight(Normal, PS.WorldPos, gLight6Type, gLight6Position, gLight6Direction, gLight6Diffuse, gLight6Attenuation, gLight6Phi, gLight6Theta, gLight6Falloff, gLight6NormalShadow ); 
 if (gLight7Enable) texLight += createLight(Normal, PS.WorldPos, gLight7Type, gLight7Position, gLight7Direction, gLight7Diffuse, gLight7Attenuation, gLight7Phi, gLight7Theta, gLight7Falloff, gLight7NormalShadow ); 
 float4 light = texel * texLight * saturate( PS.DistFade ); 
 texel = 0; 
 texel.rgb += saturate( light.rgb ); 
 texel.a = light.a;
 output.color = saturate( texel );
 output.depth = calculateLayeredDepth( PS.ViewPos ); 
 output.color.a *= PS.Diffuse.a; 
 return output;
 } 
 technique dynamic_lighting 
 {
 pass P0 
 { 
 AlphaRef = 1;
 SrcBlend = SRCALPHA;
 DestBlend = ONE; 
 AlphaBlendEnable = TRUE;
 VertexShader = compile vs_3_0 VertexShaderSB();
 PixelShader = compile ps_3_0 PixelShaderSB();
 }
 }
 technique fallback 
 {
 pass P0 
 { }
 } 
