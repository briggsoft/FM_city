//====================================================
// Ambient Filter
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// tweaks
//--------------
   float2 ViewVec;
   float3 Ambient;
   float2 SSAOOffsets[9]={{-1,-1},{-1,1},{1,-1},{1,1},{-0.5,0},{0,-0.5},{0,0.5},{0.5,0},{0,0}};
   float2 SSAOOffset=0.0075f;

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
   texture AmbientMapTX <string Name="";>;
   sampler AmbientMap=sampler_state 
      {
	Texture=<AmbientMapTX>;
      };
   texture SSAOsampleTX <string Name = " ";>;
   sampler SSAOsample=sampler_state 
      {
	Texture=<SSAOsampleTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
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
 	float2 Tex:TEXCOORD0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.OPos=IN.Pos; 
  	OUT.Tex=((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)+ViewVec;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	float3 WPos=tex2D(WorldPos,IN.Tex);
	float3 WNormals=tex2D(WorldNormals,IN.Tex)*2-1;
  	float3 Cube=texCUBE(AmbientMap,reflect(WPos,WNormals));
	float SSAO=1-(tex2D(SSAOsample,IN.Tex+(SSAOOffsets[0]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[1]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[2]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[3]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[4]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[5]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[6]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[7]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[8]*SSAOOffset)).x)/9;
	return float4((Cube*Ambient)*SSAO,1);				
     }  
  float4 PS_SH(OutPut IN) : COLOR
     {
	float3 WPos=tex2D(WorldPos,IN.Tex);
	float3 WNormals=tex2D(WorldNormals,IN.Tex)*2-1;
  	float3 Cube=texCUBE(AmbientMap,reflect(WPos,WNormals));
	return float4(Cube*Ambient,1);				
     }  
  float4 PS_SSAO(OutPut IN) : COLOR
     {
	float SSAO=1-(tex2D(SSAOsample,IN.Tex+(SSAOOffsets[0]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[1]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[2]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[3]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[4]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[5]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[6]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[7]*SSAOOffset)).x
	          +tex2D(SSAOsample,IN.Tex+(SSAOOffsets[8]*SSAOOffset)).x)/9;
	return float4(Ambient*SSAO,1);				
     }  

//--------------
// techniques   
//--------------
    technique SHSSAO
      {
 	pass p1
      {		
 	VertexShader = compile vs_2_0 VS(); 
 	PixelShader  = compile ps_2_0 PS();
	zwriteenable=false;
	zenable=false;	
      }
      }
    technique SH
      {
 	pass p1
      {		
 	VertexShader = compile vs_2_0 VS(); 
 	PixelShader  = compile ps_2_0 PS_SH();
	zwriteenable=false;
	zenable=false;	
      }
      }
    technique SSAO
      {
 	pass p1
      {		
 	VertexShader = compile vs_2_0 VS(); 
 	PixelShader  = compile ps_2_0 PS_SSAO();
	zwriteenable=false;
	zenable=false;	
      }
      }