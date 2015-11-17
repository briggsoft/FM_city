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
   float ShadowOffSet=3.0f;
   float4 ShadowOffSet2x2[5];
   float4 ShadowOffSet3x3[9];
   float4 ShadowOffSet4x4[16];
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
	MagFilter=Linear;
	MinFilter=Point;
	MipFilter=None;
      };
   texture JitterMapTX <string Name = "";>; 
   sampler JitterMap=sampler_state
      {
	Texture=<JitterMapTX >;
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
	float2 JitterUV:TEXCOORD1;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.OPos=mul(IN.Pos,WorldVP); 	
	OUT.Proj=float4(OUT.OPos.x*0.5+0.5*OUT.OPos.w,0.5*OUT.OPos.w-OUT.OPos.y*0.5,OUT.OPos.w,OUT.OPos.w)+float4(ProjShift,ProjShift,0,0);
   	OUT.JitterUV=IN.Pos.xz+IN.Pos.y;
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
	LightV=normalize(-LightV);
	float Normal=saturate(dot(WNormals,LightV));
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation)),1);
     } 
   float4 PS_ShadowMap_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=(texCUBE(DepthMap,ShadowVec) > Depth) ? 1.0 : 0.0;
	LightV=normalize(-LightV);
	float Normal=saturate(dot(WNormals,LightV));     
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_ShadowMap_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[0]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[1]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[2]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[3]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[4]) > Depth) ? 0.2 : 0.0);
	LightV=normalize(-LightV);
	float Normal=saturate(dot(WNormals,LightV));     
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_ShadowMap_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,0.333f).xxx+(tex2D(JitterMap,IN.JitterUV).xyz*0.333f))*ShadowOffSet);
	float ShadowMap=((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[0]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[1]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[2]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[3]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[4]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[5]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[6]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[7]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[8]) > Depth) ? 0.111111111 : 0.0);
	LightV=normalize(-LightV);
	float Normal=saturate(dot(WNormals,LightV));     
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_ShadowMap_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[0]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[1]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[2]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[3]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[4]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[5]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[6]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[7]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[8]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[9]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[10]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[11]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[12]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[13]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[14]) > Depth) ? 0.0625 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[15]) > Depth) ? 0.0625 : 0.0);
	LightV=normalize(-LightV);
	float Normal=saturate(dot(WNormals,LightV));     
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_Specular(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	LightV=normalize(-LightV);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,LightV);
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation)),1);
     } 
   float4 PS_SpecularShadowMap_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=(texCUBE(DepthMap,ShadowVec) > Depth) ? 1.0 : 0.0;
	LightV=normalize(-LightV);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,LightV);
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_SpecularShadowMap_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[0]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[1]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[2]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[3]) > Depth) ? 0.2 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet2x2[4]) > Depth) ? 0.2 : 0.0);
	LightV=normalize(-LightV);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,LightV);
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_SpecularShadowMap_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[0]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[1]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[2]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[3]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[4]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[5]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[6]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[7]) > Depth) ? 0.111111111 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet3x3[8]) > Depth) ? 0.111111111 : 0.0);
	LightV=normalize(-LightV);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,LightV);
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
     }
   float4 PS_SpecularShadowMap_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 LightV=WPos-LightPosition;
	float Depth=length(LightV/LightRange);
	clip(1-Depth);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 ShadowVec=LightV+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet);
	float ShadowMap=((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[0]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[1]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[2]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[3]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[4]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[5]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[6]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[7]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[8]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[9]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[10]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[11]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[12]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[13]) > Depth) ? 0.0625 : 0.0)
	               +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[14]) > Depth) ? 0.0625 : 0.0)
		       +((texCUBE(DepthMap,ShadowVec+ShadowOffSet4x4[15]) > Depth) ? 0.0625 : 0.0);
	LightV=normalize(-LightV);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,LightV);
	return float4(Normal*LightColor*(1-pow(Depth,Attenuation))*ShadowMap,1);
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
    technique LightShadowMap_1
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_ShadowMap_1(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightShadowMap_2
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_ShadowMap_2(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightShadowMap_3
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_ShadowMap_3(); 		
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightShadowMap_4
      {
  	pass p1
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_ShadowMap_4(); 		
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
    technique LightSpecularShadowMap_1
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_SpecularShadowMap_1(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightSpecularShadowMap_2
      {
  	pass p1
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_SpecularShadowMap_2(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightSpecularShadowMap_3
      {
  	pass p1
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_3(); 		
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }
    technique LightSpecularShadowMap_4
      {
  	pass p1
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_4(); 		
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
      }