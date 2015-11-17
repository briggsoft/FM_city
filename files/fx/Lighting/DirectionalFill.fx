//====================================================
// We Need To Fill Directional Light BackDrop
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// techniques   
//--------------
    float4 PS()  : COLOR {return float4(1,1,1,1);}
    technique DirRDepthMap
      {
 	pass p1
      {			
	ColorWriteEnable = red;	
 	pixelShader  = compile ps_1_0 PS();
	zwriteenable=false;
	zenable=false;	
      }
      }
    technique DirGDepthMap
      {
 	pass p1
      {		
	ColorWriteEnable = green;
 	pixelShader  = compile ps_1_0 PS();
	zwriteenable=false;
	zenable=false;		
      }
      }
    technique DirBDepthMap
      {
 	pass p1
      {		
	ColorWriteEnable = Blue;
 	pixelShader  = compile ps_1_0 PS();
	zwriteenable=false;
	zenable=false;		
      }
      }