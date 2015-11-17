//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix World:World;  
   matrix ViewInv:ViewInverse; 

//--------------
// tweaks
//--------------
   float4 FogColor={0.8f,0.8f,0.8f,1.0f};
   float FogRange=2500.0f;

//--------------
// Textures
//--------------
   texture BaseTX <string Name="";>;	
   sampler2D Base = sampler_state {texture = <BaseTX>;};
   texture BlendTX <string Name="";>;	
   sampler2D Blend = sampler_state {texture = <BlendTX>;};

//--------------
// structs 
//--------------
   struct input
     {
 	float4 Pos:POSITION; 
 	float2 UVA:TEXCOORD0; 
 	float2 UVB:TEXCOORD1; 
     };
   struct output
     {
	float4 OPos:POSITION; 
 	float2 TexA:TEXCOORD0;
   	float2 TexB:TEXCOORD1;
	float Fog:FOG;
     };

//--------------
// vertex shader
//--------------
   output VS(input IN) 
     {
 	output OUT;
	OUT.OPos=mul(IN.Pos,WorldVP); 
 	OUT.TexA=IN.UVA;
	OUT.TexB=IN.UVB;
	OUT.Fog=1-length((ViewInv[3].xyz-mul(IN.Pos,World).xyz)/FogRange);
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS(output IN)  : COLOR
     {
	float4 Texture1=tex2D(Base,IN.TexA);
 	float3 Texture2=tex2D(Blend,IN.TexB);	
	return float4(Texture1.xyz*(Texture2+Texture2),Texture1.w);
     }

//--------------
// techniques   
//--------------
   technique Blend
      {
 	pass p0
      {		
	vertexShader = compile vs_1_0 VS(); 
 	pixelShader  = compile ps_1_0 PS(); 	
 	FOGCOLOR=(FogColor); 
	FOGENABLE=TRUE;	
      }
      }