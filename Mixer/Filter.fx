//@author: jakob aka grandchild
//@help: fadable basic image processing: brightness, contrast, invert, saturation, channel switch
//@tags: image processing, image, processing, brightness, contrast, invert, saturation, channel switch, grandchild, gc, AVS
//@credits: http://vvvv.org/documentation/shadersnippets

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//input parameters
float bright <float uimin=0.0; float uimax=2.0; string uiname="Brightness";>;
float contrast <float uimin=0.0; float uimax=5.0; string uiname="Contrast";>;
int cswitch <int uimin=0; int uimax=5; string uiname="Color Switch";>;
float sat <float uimin=0.0; float uimax=4.0; string uiname="Saturation";>;
int inv <int uimin=0; int uimax=1; string uiname="Invert";>;

//texture
texture Tex <string uiname="Texture";>;

sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = Linear;         //sampler states (POINT, LINEAR, ANISOTROPIC, GAUSSIANQUAD)
    MinFilter = Linear;
    MagFilter = Linear;
};

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};


// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
	float3 lumcoeff={0.299,0.587,0.114};
	float4 col4 = tex2D(Samp, In.TexCd);
	float alpha = col4.w;
	float3 col = (((col4.rgb-0.5)*contrast)+0.5)+bright;
    if(cswitch==1){ //brg
		float temp = col.r;
		col.r = col.b;
		col.b = col.g;
		col.g = temp;
	}else if(cswitch==2){ //gbr
		float temp = col.r;
		col.r = col.g;
		col.g = col.b;
		col.b = temp;
	}else if(cswitch==3){ //rbg
		float temp = col.b;
		col.b = col.g;
		col.g = temp;
	}else if(cswitch==4){ //bgr
		float temp = col.r;
		col.r = col.b;
		col.b = temp;
	}else if(cswitch==5){ //grb
		float temp = col.r;
		col.r = col.g;
		col.g = temp;
	}
	col = dot(col,lumcoeff)*(1-sat)+sat*col;
	return inv ? float4(1-col,alpha) : float4(col,alpha);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUE:
// --------------------------------------------------------------------------------------------------

technique UnaryShader { pass P0 { PixelShader  = compile ps_2_0 PS(); } }
