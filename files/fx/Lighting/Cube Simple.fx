//====================================================
// Point Light 
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix World:World;    
   matrix ViewInv:ViewInverse; 

//--------------
// tweaks
//--------------
   float SpecularPow=16;
   float SpecularIntencity=1.5f;
   float3 LightPosition;  
   float3 LightColor;      
   float LightRange; 
   float Attenuation;
   float3x3 LightAngle; 
   float ProjShift;

//--------------
// Textures
//--------------
   texture WorldPosTX <string Name = "";>; 
   sampler WorldPos=sampler_state 
      {
	Texture=<WorldPosTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture WorldNormalsTX <string Name = "";>; 
   sampler WorldNormals=sampler_state 
      {
	Texture=<WorldNormalsTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture DepthMapTX <string Name = "";>; 
   sampler DepthMap=sampler_state
      {
	Texture=<DepthMapTX>;
	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
      };
   texture JitterMapTX <string Name = "";>; 
   sampler JitterMap=sampler_state
      {
	Texture=<JitterMapTX >;
      };
   texture CubeLightTX <string Name = "";>; 
   sampler CubeLight=sampler_state
    {
	Texture=<CubeLightTX>;
    };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;  	
     };
   struct OutPut
     {
	float4 OPos:POSITION; 
 	float4 Proj:TEXCOORD0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.OPos=mul(IN.Pos,WorldVP); 	
	OUT.Proj=float4(OUT.OPos.x*0.5+0.5*OUT.OPos.w,0.5*OUT.OPos.w-OUT.OPos.y*0.5,OUT.OPos.w,OUT.OPos.w)+float4(ProjShift,ProjShift,0,0);
	return OUT;
    }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 Cubelight=texCUBE(CubeLight,mul(LightAngle,LightV));
	LightV=normalize(-LightV);
	float Normal=saturate(dot(WNormals,LightV));
	return float4(Normal*Cubelight*LightColor*(1-pow(Depth,Attenuation)),1);
     } 
   float4 PS_Specular(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 Cubelight=texCUBE(CubeLight,mul(LightAngle,LightV));
	LightV=normalize(-LightV);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,LightV);
	return float4(Normal*Cubelight*LightColor*(1-pow(Depth,Attenuation)),1);
     } 

//--------------
// techniques   
//--------------
    technique Light
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightSpecular
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_Specular(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }