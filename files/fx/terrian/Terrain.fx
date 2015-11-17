//====================================================
// Terrain
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//Use Vertical Mapping ?
#define VerticalMap1 0
#define VerticalMap2 1
#define VerticalMap3 0
#define VerticalMap4 0

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix World:World;    
   matrix ViewInv:ViewInverse; 

//--------------
// tweaks
//--------------
   float4 TerrainVec={0,0,12800,12800};
   float2 Terrain1UV={16,16};
   float2 Terrain2UV={32,32};
   float2 Terrain3UV={16,16};
   float2 Terrain4UV={64,64};
   float3 LightColor={1.0f,0.75f,0.75f};
   float3 Lightdir={-0.5f,-0.5f,0.0f};
   float3 Ambient={0.15f,0.15f,0.15f};
   float4 FogColor={0.5f,0.5f,0.6f,1.0f};
   float FogRange=30000.0f;

//--------------
// Textures
//--------------
   texture NormalsTX <string Name = "";>;	
   sampler Normals=sampler_state 
      {
 	Texture=<NormalsTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
      };
   texture ShadowTX <string Name = "";>;	
   sampler Shadow=sampler_state 
      {
 	Texture=<ShadowTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
      };
   texture BlendMapTX <string Name = "";>;	
   sampler BlendMap=sampler_state 
      {
 	Texture=<BlendMapTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
      };
   texture ColorMapTX <string Name = "";>;	
   sampler ColorMap=sampler_state 
      {
 	Texture=<ColorMapTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
      };
   texture Base1TX <string Name = "";>;	
   sampler Base1=sampler_state 
      {
 	Texture=<Base1TX>;
      };
   texture Base2TX <string Name = "";>;	
   sampler Base2=sampler_state 
      {
 	Texture=<Base2TX>;
      };
   texture Base3TX <string Name = "";>;	
   sampler Base3=sampler_state 
      {
 	Texture=<Base3TX>;
      };
   texture Base4TX <string Name = "";>;	
   sampler Base4=sampler_state 
      {
 	Texture=<Base4TX>;
      };

//--------------
// structs 
//--------------
   struct In_Diffuse
     {
 	float4 Pos:POSITION; 
 	float2 UV:TEXCOORD0;  
     };
   struct Out_Diffuse
     {
	float4 OPos:POSITION; 
 	float2 Tex:TEXCOORD0;
	float2 Vertical:TEXCOORD1;
 	float4 Tex1:TEXCOORD2;
	float4 Tex2:TEXCOORD3;
	float4 Tex3:TEXCOORD4;
	float4 Tex4:TEXCOORD5;
	float Fog:FOG;
     };

//--------------
// vertex shader
//--------------
   Out_Diffuse VS(In_Diffuse IN) 
     {
 	Out_Diffuse OUT;
	OUT.OPos=mul(IN.Pos,WorldVP); 
 	float3 WPos=mul(IN.Pos,World);
 	float2 UV=(WPos.xz-TerrainVec.xy)/TerrainVec.zw; 
 	float2 UVx=-(WPos.xy)/TerrainVec.zw; 
	float2 UVz=-(WPos.zy)/TerrainVec.zw; 
	OUT.Tex=UV;
	OUT.Vertical=IN.UV;
	UV.y=-UV.y;
	#if VerticalMap1 == 1
	 OUT.Tex1=float4(UVx*Terrain1UV,UVz*Terrain1UV);
	#else	
 	 OUT.Tex1=float4(-UV*Terrain1UV,0,0);
	#endif
	#if VerticalMap2 == 1
	 OUT.Tex2=float4(UVx*Terrain2UV,UVz*Terrain2UV);
	#else	
 	 OUT.Tex2=float4(-UV*Terrain2UV,0,0);
	#endif
	#if VerticalMap3 == 1
	 OUT.Tex3=float4(UVx*Terrain3UV,UVz*Terrain3UV);
	#else	
 	 OUT.Tex3=float4(-UV*Terrain3UV,0,0);
	#endif
	#if VerticalMap4 == 1
	 OUT.Tex4=float4(UVx*Terrain4UV,UVz*Terrain4UV);
	#else	
 	 OUT.Tex4=float4(-UV*Terrain4UV,0,0);
	#endif
	float3 ViewPos=ViewInv[3].xyz-WPos;
	OUT.Fog=1-saturate(dot(ViewPos/FogRange,ViewPos/FogRange));
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS(Out_Diffuse IN) : COLOR
     { 
	float4 Blend=tex2D(BlendMap,IN.Tex);
	float3 ColMap=tex2D(ColorMap,IN.Tex);
	float3 Detailmap=0;
	#if VerticalMap1 == 1
	 Detailmap +=((tex2D(Base1,IN.Tex1.xy)*IN.Vertical.y)+(tex2D(Base1,IN.Tex1.zw)*IN.Vertical.x))*Blend.x;
	#else	
	 Detailmap +=tex2D(Base1,IN.Tex1.xy)*Blend.x;
	#endif
	#if VerticalMap2 == 1
	 Detailmap +=((tex2D(Base2,IN.Tex2.xy)*IN.Vertical.y)+(tex2D(Base2,IN.Tex2.zw)*IN.Vertical.x))*Blend.y;
	#else	
	 Detailmap +=tex2D(Base2,IN.Tex2.xy)*Blend.y;
	#endif
	#if VerticalMap3 == 1
	 Detailmap +=((tex2D(Base3,IN.Tex3.xy)*IN.Vertical.y)+(tex2D(Base3,IN.Tex3.zw)*IN.Vertical.x))*Blend.z;
	#else	
	 Detailmap +=tex2D(Base3,IN.Tex3.xy)*Blend.z;
	#endif
	#if VerticalMap4 == 1
	 Detailmap +=((tex2D(Base4,IN.Tex4.xy)*IN.Vertical.y)+(tex2D(Base4,IN.Tex4.zw)*IN.Vertical.x))*Blend.w;
	#else	
	 Detailmap +=tex2D(Base4,IN.Tex4.xy)*Blend.w;
	#endif
	float3 Normal=tex2D(Normals,IN.Tex)*2-1;
	return float4(((Detailmap+ColMap)-0.5f)*(saturate(dot(-Lightdir,Normal)*tex2D(Shadow,IN.Tex)*LightColor)+Ambient),1);
     }

//--------------
// techniques   
//--------------
   technique Diffuse
      {
 	pass p1
      {		
 	vertexShader = compile vs_2_0 VS(); 
 	pixelShader  = compile ps_2_0 PS();
	FOGCOLOR=(FogColor); 
	FOGENABLE=TRUE;	
      }
      }