//====================================================
// Directional Light
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
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1}; 

//--------------
// tweaks
//--------------  
   float SpecularPow=64;
   float SpecularIntencity=1.5f;
   float ProjShift;
   float3 LightPosition;  
   float3 LightDir;
   float3 LightColor;
   matrix ProjMatrix1;
   float3 ProjPosition1;
   float Split1;
   float Radius1;
   float3 CamPos1;
   matrix ProjMatrix2;
   float3 ProjPosition2;
   float Split2;
   float Radius2;
   float3 CamPos2;
   matrix ProjMatrix3;
   float3 ProjPosition3;
   float Split3;
   float Radius3;
   float3 CamPos3;
   float ShadowOffSet_1=5000.0f;
   float ShadowOffSet_2=10000.0f;
   float ShadowOffSet_3=15000.0f;
   float2 ShadowOffSet2x2_1[5];
   float2 ShadowOffSet2x2_2[5];
   float2 ShadowOffSet2x2_3[5];
   float2 ShadowOffSet3x3_1[9];
   float2 ShadowOffSet3x3_2[9];
   float2 ShadowOffSet3x3_3[9];
   float2 ShadowOffSet4x4_1[16];
   float2 ShadowOffSet4x4_2[16];
   float2 ShadowOffSet4x4_3[16];

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
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float Normal=saturate(dot(WNormals*2-1,-LightDir)); 
	return float4(Normal*LightColor,1);
     }
   float4 PS_ShadowMap_1_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1));
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
        float ShadowMap=(tex2D(DepthMap,ShadowVec).x > Depth ) ? 1.0 : 0.0;
	float Normal=dot(WNormals,-LightDir); 
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_2_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
        float ShadowMap=(tex2D(DepthMap,ShadowVec).y > Depth ) ? 1.0 : 0.0;
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_3_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
        float ShadowMap=(tex2D(DepthMap,ShadowVec).z > Depth ) ? 1.0 : 0.0;
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     }
   float4 PS_ShadowMap_1_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1));
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[0]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[1]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[2]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[3]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[4]).x > Depth ) ? 0.2 : 0.0);
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_2_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[0]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[1]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[2]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[3]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[4]).y > Depth ) ? 0.2 : 0.0);
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_3_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[0]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[1]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[2]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[3]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[4]).z > Depth ) ? 0.2 : 0.0);
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float Normal=dot(WNormals,-LightDir);  
	return float4(Normal*(ShadowMap*LightColor),1);
     }
   float4 PS_ShadowMap_1_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1));
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[0]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[1]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[2]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[3]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[4]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[5]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[6]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[7]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[8]).x > Depth ) ? 0.111111111 : 0.0);
	float Normal=dot(WNormals,-LightDir); 
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_2_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[0]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[1]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[2]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[3]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[4]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[5]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[6]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[7]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[8]).y > Depth ) ? 0.111111111 : 0.0);
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_3_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[0]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[1]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[2]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[3]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[4]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[5]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[6]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[7]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[8]).z > Depth ) ? 0.111111111 : 0.0);
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float Normal=dot(WNormals,-LightDir);  
	return float4(Normal*(ShadowMap*LightColor),1);
     }
   float4 PS_ShadowMap_1_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1)); 
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[0]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[1]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[2]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[3]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[4]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[5]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[6]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[7]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[8]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[9]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[10]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[11]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[12]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[13]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[14]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[15]).x > Depth ) ? 0.0625 : 0.0);
	float Normal=dot(WNormals,-LightDir); 
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_2_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[0]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[1]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[2]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[3]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[4]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[5]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[6]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[7]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[8]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[9]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[10]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[11]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[12]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[13]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[14]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[15]).y > Depth ) ? 0.0625 : 0.0);
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_ShadowMap_3_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[0]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[1]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[2]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[3]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[4]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[5]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[6]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[7]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[8]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[9]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[10]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[11]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[12]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[13]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[14]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[15]).z > Depth ) ? 0.0625 : 0.0);
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float Normal=dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     }
    float4 PS_Specular(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
	float3 LightV=normalize(LightPosition-WPos);
	float3 View=normalize(WPos-ViewInv[3].xyz);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*LightColor,1);
     }
   float4 PS_SpecularShadowMap_1_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1));
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
        float ShadowMap=(tex2D(DepthMap,ShadowVec).x > Depth ) ? 1.0 : 0.0;
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_2_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
        float ShadowMap=(tex2D(DepthMap,ShadowVec).y > Depth ) ? 1.0 : 0.0;
 	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_3_1(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
        float ShadowMap=(tex2D(DepthMap,ShadowVec).z > Depth ) ? 1.0 : 0.0;
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     }
   float4 PS_SpecularShadowMap_1_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1));
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[0]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[1]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[2]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[3]).x > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_1[4]).x > Depth ) ? 0.2 : 0.0);
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*LightColor*ShadowMap,1);
     } 
   float4 PS_SpecularShadowMap_2_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2)); 
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[0]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[1]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[2]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[3]).y > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_2[4]).y > Depth ) ? 0.2 : 0.0);
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_3_2(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[0]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[1]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[2]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[3]).z > Depth ) ? 0.2 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet2x2_3[4]).z > Depth ) ? 0.2 : 0.0);
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     }
   float4 PS_SpecularShadowMap_1_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1));
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[0]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[1]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[2]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[3]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[4]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[5]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[6]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[7]).x > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_1[8]).x > Depth ) ? 0.111111111 : 0.0);
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_2_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[0]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[1]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[2]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[3]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[4]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[5]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[6]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[7]).y > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_2[8]).y > Depth ) ? 0.111111111 : 0.0);
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_3_3(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[0]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[1]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[2]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[3]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[4]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[5]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[6]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[7]).z > Depth ) ? 0.111111111 : 0.0)
	               +((tex2D(DepthMap,ShadowVec+ShadowOffSet3x3_3[8]).z > Depth ) ? 0.111111111 : 0.0);
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     }
   float4 PS_SpecularShadowMap_1_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split1,View/Split1))+1);
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix1)); 
        float Depth=dot(WPos-CamPos1,LightDir)/(Radius1*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_1);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[0]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[1]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[2]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[3]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[4]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[5]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[6]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[7]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[8]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[9]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[10]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[11]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[12]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[13]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[14]).x > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_1[15]).x > Depth ) ? 0.0625 : 0.0);
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_2_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate((1-dot(View/Split2,View/Split2))+1)*(1-saturate((1-dot(View/Split1,View/Split1))));
	clip(Split-1);
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix2));
        float Depth=dot(WPos-CamPos2,LightDir)/(Radius2*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_2);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[0]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[1]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[2]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[3]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[4]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[5]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[6]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[7]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[8]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[9]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[10]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[11]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[12]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[13]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[14]).y > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_2[15]).y > Depth ) ? 0.0625 : 0.0);
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);
	return float4(Normal*(ShadowMap*LightColor),1);
     } 
   float4 PS_SpecularShadowMap_3_4(OutPut IN) : COLOR
     {
	float3 WPos=tex2Dproj(WorldPos,IN.Proj)+ViewInv[3].xyz;
	float3 View=WPos-ViewInv[3].xyz;
	float Split=saturate(dot(View/Split2,View/Split2));
	clip(Split-1);	
	float3 WNormals=tex2Dproj(WorldNormals,IN.Proj)*2-1;
        float4 ProjVec=mul(ProjMat,mul(float4(WPos,1),ProjMatrix3));
        float Depth=dot(WPos-CamPos3,LightDir)/(Radius3*2.5);
	float2 ShadowVec=ProjVec.xy+((dot(WNormals,1)+tex2D(JitterMap,IN.JitterUV))*ShadowOffSet_3);
	float ShadowMap=((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[0]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[1]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[2]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[3]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[4]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[5]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[6]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[7]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[8]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[9]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[10]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[11]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[12]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[13]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[14]).z > Depth ) ? 0.0625 : 0.0)
		       +((tex2D(DepthMap,ShadowVec+ShadowOffSet4x4_3[15]).z > Depth ) ? 0.0625 : 0.0);
	ShadowMap=saturate(ShadowMap+(1-saturate((1-dot(View/Radius3,View/Radius3))*4)));
	float3 LightV=normalize(LightPosition-WPos);
	View=normalize(View);
	WNormals=normalize(WNormals);
	float Normal=pow(saturate(dot(View,reflect(LightV,WNormals))),SpecularPow);
	Normal=((Normal*tex2Dproj(WorldNormals,IN.Proj).w)*SpecularIntencity)+dot(WNormals,-LightDir);  
	return float4(Normal*(ShadowMap*LightColor),1);
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
  	pixelShader  = compile ps_2_0 PS_ShadowMap_1_1(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p2
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_ShadowMap_2_1(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_ShadowMap_3_1(); 
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
  	pixelShader  = compile ps_2_a PS_ShadowMap_1_2(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
  	pass p2
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_ShadowMap_2_2(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_ShadowMap_3_1(); 
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
  	pixelShader  = compile ps_2_a PS_ShadowMap_1_3(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
  	pass p2
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_ShadowMap_2_3(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_ShadowMap_3_2(); 
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
  	pixelShader  = compile ps_3_0 PS_ShadowMap_1_4(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
  	pass p2
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_ShadowMap_2_4(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_ShadowMap_3_3(); 
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
  	pixelShader  = compile ps_2_0 PS_SpecularShadowMap_1_1(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p2
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_SpecularShadowMap_2_1(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_0 PS_SpecularShadowMap_3_1(); 
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
  	pixelShader  = compile ps_2_a PS_SpecularShadowMap_1_2(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
  	pass p2
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_SpecularShadowMap_2_2(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_2_0 VS(); 
  	pixelShader  = compile ps_2_a PS_SpecularShadowMap_3_1(); 
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
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_1_3(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
  	pass p2
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_2_2(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_3_2(); 
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
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_1_4(); 	
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }
  	pass p2
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_2_3(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;	
      }
  	pass p3
      {		
  	vertexShader = compile vs_3_0 VS(); 
  	pixelShader  = compile ps_3_0 PS_SpecularShadowMap_3_2(); 
	AlphaBlendEnable = True;
 	SrcBlend = One;
 	DestBlend = One;
	Zenable = false;
	zwriteenable = false;
      }  
      }