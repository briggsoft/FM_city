//====================================================
//  
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection;
   matrix ViewInv:ViewInverse; 
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1};

//--------------
// tweaks
//--------------
   matrix FogProjMatrix;
   float3 FogPosition;
   float3 FogDir;  
   float FogZScale;  
   float FogZThickness;  
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
   	float viewFog=pow(saturate(length(WPos-ViewInv[3].xyz)/FogRange),FogPow);
	float4 Proj=mul(ProjMat,-mul(float4(WPos-FogPosition,1),FogProjMatrix));
	float FogFall=dot(WPos-FogPosition,FogDir);
	float4 ProjectFog=tex2Dproj(Project,Proj);
	ProjectFog.w=ProjectFog.w*saturate(FogFall/(FogZScale*FogZThickness))*(1-floor(saturate((FogFall+1)-FogZScale)));
	clip(ProjectFog.w-0.001f);
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