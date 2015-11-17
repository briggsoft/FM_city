//====================================================
// Fog Back Plain
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
   float3 FogColor;
   float FogRange;
   float FogPow;
   float FogIntencity;
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
   texture ProjectTX <string Name = "";>;	
   sampler Project=sampler_state 
      {
 	texture=<ProjectTX>;
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION; 
 	float2 UV:TEXCOORD;		
     };
   struct OutPut
     {
	float4 OPos:POSITION; 
 	float2 Tex:TEXCOORD0;
  	float3 WPos:TEXCOORD1;
  	float4 Proj:TEXCOORD2;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.OPos=mul(IN.Pos,WorldVP); 	
 	OUT.Tex=IN.UV;
	OUT.WPos=mul(IN.Pos,World)-ViewInv[3].xyz;
	OUT.Proj=float4(OUT.OPos.x*0.5+0.5*OUT.OPos.w,0.5*OUT.OPos.w-OUT.OPos.y*0.5,OUT.OPos.w,OUT.OPos.w)+float4(ProjShift,ProjShift,0,0);
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	clip((length(tex2Dproj(WorldPos,IN.Proj))-length(IN.WPos)));
    	float viewFog=pow(saturate(length(IN.WPos)/FogRange),FogPow);
	float4 ProjectFog=tex2D(Project,IN.Tex);
	return float4(ProjectFog.xyz*FogColor,ProjectFog.w*viewFog*FogIntencity);
     }

//--------------
// techniques   
//--------------
    technique fog
      {
 	pass p1
      {		
 	vertexShader = compile vs_2_0 VS(); 
 	pixelShader  = compile ps_2_0 PS();
	Zenable = false;
	zwriteenable = false;
	AlphaBlendEnable=TRUE;	
	SrcBlend=SRCALPHA;
	DestBlend=INVSRCALPHA;
      }
      }