//====================================================
// Screen Space Ambient Occlusion
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewInv:ViewInverse; 
   matrix ViewProj:ViewProjection; 

//--------------
// tweaks
//--------------
   float Radius=10.0f;
   float Intencity=1.5f;
   float3 samplesoffset[16]=
    {
     float3(0.355512,-0.709318,-0.102371),
     float3(0.534186,0.71511,-0.115167),
     float3(-0.87866,0.157139,-0.115167),
     float3(0.140679,-0.475516,-0.0639818 ),
     float3(-0.0796121,0.158842,-0.677075 ),
     float3(-0.0759516,-0.101676,-0.483625 ),
     float3(0.12493,-0.0223423,-0.483625 ),
     float3(-0.0720074,0.243395,-0.967251),
     float3(-0.207641,0.414286,0.187755),
     float3(-0.277332,-0.371262,0.187755),
     float3(0.63864,-0.114214,0.262857 ),
     float3(-0.184051,0.622119,0.262857 ),
     float3(0.110007,-0.219486,0.435574 ),
     float3(0.235085,0.314707,0.696918 ),
     float3(-0.290012,0.0518654,0.522688 ),
     float3(0.0975089,-0.329594,0.609803 )
    };

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
 	OUT.Tex=(float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5;
	return OUT;
    }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	float3 WPos=tex2D(WorldPos,IN.Tex)+ViewInv[3].xyz;
	float3 WNormals=tex2D(WorldNormals,IN.Tex)*2-1;
	float radius=Radius+(mul(float4(WPos,1),ViewProj).z/100);
        float occ=0;
        float zd,sd;
	float2 sp;
        float3 cs,ns; 
	float4 np;
	for (int i=0; i < 16; i++)
	 {	
	  cs=reflect(samplesoffset[i],WNormals)*radius; 
	  if (dot(cs,WNormals)<0.0f) cs +=WNormals*radius; 
	  np=mul(float4(WPos+cs,1),ViewProj);
	  sp=((np.xy/np.w)*float2(0.5f,-0.5f))+float2(0.5f,0.5f);
	  sd=mul(float4(tex2D(WorldPos,sp)+ViewInv[3].xyz,1.0f),ViewProj).w;
	  zd=max(np.w-sd,0.0f);	
	  if (sd<np.w) occ +=1/(1+(zd*zd*0.01f));
	 }
	return float4(((occ/16)*Intencity).xxx,1);
     }

//--------------
// techniques   
//--------------
    technique SSAO
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS(); 
 	PixelShader  = compile ps_3_0 PS();
	Zenable = false;
	zwriteenable = false; 	
      }
      }
 