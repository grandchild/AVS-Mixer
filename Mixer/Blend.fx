// September 2010
// blending two textures

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

float fader <string uiname="FaderPosition";>;
float param1 <string uiname="Parameter1";>;

//input textures
texture Tex1 <string uiname="Texture1";>;
texture Tex2 <string uiname="Texture2";>;

sampler Samp1 = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex1);          //apply a texture to the sampler
    MipFilter = Linear;         //sampler states (POINT, LINEAR, ANISOTROPIC, GAUSSIANQUAD)
    MinFilter = Linear;
    MagFilter = Linear;
};

sampler Samp2 = sampler_state
{
    Texture   = (Tex2);
    MipFilter = Linear;         //sampler states (POINT, LINEAR, ANISOTROPIC, GAUSSIANQUAD)
    MinFilter = Linear;
    MagFilter = Linear;
};

//texture transformation marked  with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture1 Transform";>;

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
// source for most of these formulas: http://www.nathanm.com/photoshop-blending-math/
// adaptation as crossfaders by me, jakob
// still wanted: reflect, glow, pin light, hard mix, vivid light, smooth threshold

float4 blend(vs2ps In): COLOR {
    float4 col1 = tex2D(Samp1, In.TexCd);
    float4 col2 = tex2D(Samp2, In.TexCd);
    return col1*(1-fader)+col2*fader;
}

float4 add(vs2ps In): COLOR {
    if(fader<0.5) return tex2D(Samp1, In.TexCd)+tex2D(Samp2, In.TexCd)*fader*2;
    else          return tex2D(Samp1, In.TexCd)*(2-fader*2)+tex2D(Samp2, In.TexCd);
}

float4 maximum(vs2ps In): COLOR {
    if(fader<0.5) return max(tex2D(Samp1, In.TexCd),tex2D(Samp2, In.TexCd)*fader*2);
    else          return max(tex2D(Samp1, In.TexCd)*(2-fader*2),tex2D(Samp2, In.TexCd));
}

float4 minimum(vs2ps In): COLOR {
    if(fader<0.5) return min(tex2D(Samp1, In.TexCd),(1-fader*2)+tex2D(Samp2, In.TexCd)*fader*2);
    else          return min(fader*2-1+tex2D(Samp1, In.TexCd)*(2-fader*2),tex2D(Samp2, In.TexCd));
}

float4 multiply(vs2ps In): COLOR {
    if(fader<0.5) return tex2D(Samp1, In.TexCd)*((1-fader*2)+tex2D(Samp2, In.TexCd)*fader*2);
    else          return (fader*2-1+tex2D(Samp1, In.TexCd)*(2-fader*2))*tex2D(Samp2, In.TexCd);
}

float4 screen(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2;
        return float4(1-(1-col1.rgb)*(1-col2.rgb),1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2-fader*2);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(1-(1-col1.rgb)*(1-col2.rgb),1);
    }
}

float4 difference(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2;
        return float4(abs(col1.rgb-col2.rgb),1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2-fader*2);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(abs(col1.rgb-col2.rgb),1);
    }
}

float4 subtract(vs2ps In): COLOR {
	if(param1<0.5){
		if(fader<0.5){
	        float4 col1 = tex2D(Samp1, In.TexCd);
	        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2;
	        return float4(col1.rgb-col2.rgb,1);
	    }else{
	        float4 col1 = saturate(tex2D(Samp1, In.TexCd)*(2-fader*2)+(fader*2-1));
	        float4 col2 = tex2D(Samp2, In.TexCd);
	        return float4(col1.rgb-col2.rgb,1);
	    }
	} else {
	    if(fader<0.5){
	        float4 col1 = tex2D(Samp1, In.TexCd);
	        float4 col2 = saturate(tex2D(Samp2, In.TexCd)*fader*2-fader*2+1);
	        return float4(col2.rgb-col1.rgb,1);
	    }else{
	        float4 col1 = tex2D(Samp1, In.TexCd)*(2-fader*2);
	        float4 col2 = tex2D(Samp2, In.TexCd);
	        return float4(col2.rgb-col1.rgb,1);
	    }
	}
}

// wip
float4 phoenix(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0+1.0-fader*2.0;
        return float4(min(col1.rgb,col2.rgb)-max(col1.rgb,col2.rgb)+1.0,1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0)+fader*2.0-1.0;
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(min(col1.rgb,col2.rgb)-max(col1.rgb,col2.rgb)+1.0,1);
    }
}
// if improved here, also modify: dodgeright, burnleft/-right, vividlightleft/-right
float4 colordodgeleft(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2;
        return float4(col2.x==1?1:min(1,col1.x/(1-col2.x)),
                      col2.y==1?1:min(1,col1.y/(1-col2.y)),
                      col2.z==1?1:min(1,col1.z/(1-col2.z)),1);
    }else{ // note: 0.5-1 is a simple interpolated blend from dodge. looks odd, could be improved...
        float fader2 = (2.0*fader-1.0);
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4((col2.x==1?1:min(1,col1.x/(1-col2.x)))+col2.x*fader2,
                      (col2.y==1?1:min(1,col1.y/(1-col2.y)))+col2.y*fader2,
                      (col2.z==1?1:min(1,col1.z/(1-col2.z)))+col2.z*fader2,1);
    }
}

float4 colordodgeright(vs2ps In): COLOR {
    if(fader<0.5){ // note: 0-0.5 is a simple interpolated blend from dodge. looks odd, could be improved...
        float fader2 = (1.0-fader*2.0);
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0;
        return float4((col1.x==1?1:min(1,col2.x/(1-col1.x)))+col1.x*fader2,
                      (col1.y==1?1:min(1,col2.y/(1-col1.y)))+col1.y*fader2,
                      (col1.z==1?1:min(1,col2.z/(1-col1.z)))+col1.z*fader2,1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(col1.x==1?1:min(1,col2.x/(1-col1.x)),
                      col1.y==1?1:min(1,col2.y/(1-col1.y)),
                      col1.z==1?1:min(1,col2.z/(1-col1.z)),1);
    }
}

float4 burnleft(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0+1.0-fader*2.0;
        return float4(col2.x==0?0:max(0,1-(1-col1.x)/col2.x),
                      col2.y==0?0:max(0,1-(1-col1.y)/col2.y),
                      col2.z==0?0:max(0,1-(1-col1.z)/col2.z),1);
    }else{ // same here as in dodge - simple blend only
        float fader2 = (2.0*fader-1.0);
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4((col2.x==0?0:max(0,1-(1-col1.x)/col2.x))+col2.x*fader2,
                      (col2.y==0?0:max(0,1-(1-col1.y)/col2.y))+col2.y*fader2,
                      (col2.z==0?0:max(0,1-(1-col1.z)/col2.z))+col2.z*fader2,1);
    }
}

float4 burnright(vs2ps In): COLOR {
    if(fader<0.5){ // same here as in dodge - simple blend only
        float fader2 = 1.0-fader*2.0;
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0;
        return float4(col1.x==0?0:max(0,1-(1-col2.x)/col1.x)+col1.x*fader2,
                      col1.y==0?0:max(0,1-(1-col2.y)/col1.y)+col1.y*fader2,
                      col1.z==0?0:max(0,1-(1-col2.z)/col1.z)+col1.z*fader2,1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0)+fader*2.0-1.0;
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4((col1.x==0?0:max(0,1-(1-col2.x)/col1.x)),
                      (col1.y==0?0:max(0,1-(1-col2.y)/col1.y)),
                      (col1.z==0?0:max(0,1-(1-col2.z)/col1.z)),1);
    }
}

float4 overlayleft(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0+0.5-fader;
        return float4(col1.rgb<0.5?(2*col2.rgb*col1.rgb):1-2*(1-col2.rgb)*(1-col1.rgb),1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0)+fader-0.5;
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(col1.x<0.5?(2*col2.x*col1.x):1-2*(1-col2.x)*(1-col1.x),
                      col1.y<0.5?(2*col2.y*col1.y):1-2*(1-col2.y)*(1-col1.y),
                      col1.z<0.5?(2*col2.z*col1.z):1-2*(1-col2.z)*(1-col1.z),1);
    }
}

float4 overlayright(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0+0.5-fader;
        return float4(col2.x<0.5?(2*col1.x*col2.x):1-2*(1-col1.x)*(1-col2.x),
                      col2.y<0.5?(2*col1.y*col2.y):1-2*(1-col1.y)*(1-col2.y),
                      col2.z<0.5?(2*col1.z*col2.z):1-2*(1-col1.z)*(1-col2.z),1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0)+fader-0.5;
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(col2.x<0.5?(2*col1.x*col2.x):1-2*(1-col1.x)*(1-col2.x),
                      col2.y<0.5?(2*col1.y*col2.y):1-2*(1-col1.y)*(1-col2.y),
                      col2.z<0.5?(2*col1.z*col2.z):1-2*(1-col1.z)*(1-col2.z),1);
    }
}
/*
float4 vividlightleft(vs2ps In): COLOR {
    if(fader<0.5){
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0+2.0-fader*2.0;
        return float4(col2.x<0.5 ? (col2.x==0?0:max(0,1-(1-col1.x)/(col2.x*2))) : (col2.x==1?1:min(1,col1.x/(2-col2.x*2))),
                      col2.y<0.5 ? (col2.y==0?0:max(0,1-(1-col1.y)/(col2.y*2))) : (col2.y==1?1:min(1,col1.y/(2-col2.y*2))),
                      col2.z<0.5 ? (col2.z==0?0:max(0,1-(1-col1.z)/(col2.z*2))) : (col2.z==1?1:min(1,col1.z/(2-col2.z*2))),1);
    }else{
        float fader2 = 2.0-fader*2.0;
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4((col2.x<0.5 ? (col2.x==0?0:max(0,1-(1-col1.x)/(col2.x*2))) : (col2.x==1?1:min(1,col1.x/(2-col2.x*2))))*col2.x*fader2,
                      (col2.y<0.5 ? (col2.y==0?0:max(0,1-(1-col1.y)/(col2.y*2))) : (col2.y==1?1:min(1,col1.y/(2-col2.y*2))))*col2.y*fader2,
                      (col2.z<0.5 ? (col2.z==0?0:max(0,1-(1-col1.z)/(col2.z*2))) : (col2.z==1?1:min(1,col1.z/(2-col2.z*2))))*col2.z*fader2,1);
    }
}
// VividLight(B,L) ((L < 128)?ChannelBlend_ColorBurn(B,(2 * L)):ChannelBlend_ColorDodge(B,(2 * (L - 128))))

float4 vividlightright(vs2ps In): COLOR {
    if(fader<0.5){
        float fader2 = 1.0-fader*2.0;
        float4 col1 = tex2D(Samp1, In.TexCd);
        float4 col2 = tex2D(Samp2, In.TexCd)*fader*2.0+2.0-fader*2.0;
        return float4((col1.x<0.5 ? (col1.x==0?0:max(0,1-(1-col2.x)/(col1.x*2))) : (col1.x==1?1:min(1,col2.x/(2-col1.x*2))))+col1.x*fader2,
                      (col1.y<0.5 ? (col1.y==0?0:max(0,1-(1-col2.y)/(col1.y*2))) : (col1.y==1?1:min(1,col2.y/(2-col1.y*2))))+col1.x*fader2,
                      (col1.z<0.5 ? (col1.z==0?0:max(0,1-(1-col2.z)/(col1.z*2))) : (col1.z==1?1:min(1,col2.z/(2-col1.z*2))))+col1.x*fader2,1);
    }else{
        float4 col1 = tex2D(Samp1, In.TexCd)*(2.0-fader*2.0)+(2.0-fader*2.0);
        float4 col2 = tex2D(Samp2, In.TexCd);
        return float4(col1.x<0.5 ? (col1.x==0?0:max(0,1-(1-col2.x)/(col1.x*2))) : (col1.x==1?1:min(1,col2.x/(2-col1.x*2))),
                      col1.y<0.5 ? (col1.y==0?0:max(0,1-(1-col2.y)/(col1.y*2))) : (col1.y==1?1:min(1,col2.y/(2-col1.y*2))),
                      col1.z<0.5 ? (col1.z==0?0:max(0,1-(1-col2.z)/(col1.z*2))) : (col1.z==1?1:min(1,col2.z/(2-col1.z*2))),1);
    }
}
*/

// PinLight(B,L)   ((L < 128)?ChannelBlend_Min(B,(2 * L)):ChannelBlend_Max(B,(2 * (L - 128))))
// HardMix(B,L)    (((ChannelBlend_VividLight(B,L) < 128) ? 0:255))
// Reflect(B,L)    (((L == 255) ? L:min(255, (B * B / (255 - L)))))
// Glow(B,L)       (ChannelBlend_Reflect(L,B))

float4 threshold(vs2ps In): COLOR {
    float4 col1 = tex2D(Samp1, In.TexCd);
    float4 col2 = tex2D(Samp2, In.TexCd);
    if((col2.x+col2.y+col2.z)*.25+fader<1)
        return col1;
    else
        return col2;
}

//wip
float4 horwipe(vs2ps In): COLOR {
    float wipe = saturate(In.TexCd.x*(param1*2-1)-param1+fader*2);
    return tex2D(Samp1, In.TexCd)*wipe+tex2D(Samp2, In.TexCd)*(1-wipe);
}

//wip
float4 verwipe(vs2ps In): COLOR {
    float wipe = saturate(In.TexCd.y*(param1*2-1)-param1+fader*2);
    return tex2D(Samp1, In.TexCd)*(1-wipe)+tex2D(Samp2, In.TexCd)*wipe;
}

//wip
float4 symwipe(vs2ps In): COLOR {
    float wipe = saturate(abs(In.TexCd.x*2-1)*(param1*2-1)+1-fader*2+1-param1);
    return tex2D(Samp1, In.TexCd)*wipe+tex2D(Samp2, In.TexCd)*(1-wipe);
}

float4 hardwipe(vs2ps In): COLOR {
    float wipe = (In.TexCd.x-fader)>0 ? (param1<0.5?1:0) : (param1<0.5?0:1);
    return tex2D(Samp1, In.TexCd)*wipe+tex2D(Samp2, In.TexCd)*(1-wipe);
}

float4 fadeovergray(vs2ps In): COLOR {
	if(fader<0.5){
        return tex2D(Samp1, In.TexCd)*(1.0-fader*2.0)+float4(param1,param1,param1,1)*(fader*2.0);
    }else{
		return tex2D(Samp2, In.TexCd)*(fader*2.0-1.0)+float4(param1,param1,param1,1)*(2.0-fader*2.0);
	}
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------


technique Blend{ pass P0{ PixelShader = compile ps_2_0 blend(); }}
technique Add{ pass P0{ PixelShader = compile ps_2_0 add(); }}
technique Max{ pass P0{ PixelShader = compile ps_2_0 maximum(); }}
technique Min{ pass P0{ PixelShader = compile ps_2_0 minimum(); }}
technique Mul{ pass P0{ PixelShader = compile ps_2_0 multiply(); }}
technique Screen{ pass P0{ PixelShader = compile ps_2_0 screen(); }}
technique Dif{ pass P0{ PixelShader = compile ps_2_0 difference(); }}
technique Sub{ pass P0{ PixelShader = compile ps_2_0 subtract(); }}
//technique Sub_R{ pass P0{ PixelShader = compile ps_2_0 subtractright(); }}
technique Phoenix{ pass P0{ PixelShader = compile ps_2_0 phoenix(); }}
technique Dodge_L{ pass P0{ PixelShader = compile ps_2_0 colordodgeleft(); }}
technique Dodge_R{ pass P0{ PixelShader = compile ps_2_0 colordodgeright(); }}
technique Burn_L{ pass P0{ PixelShader = compile ps_2_0 burnleft(); }}
technique Burn_R{ pass P0{ PixelShader = compile ps_2_0 burnright(); }}
technique Overlay_L{ pass P0{ PixelShader = compile ps_2_0 overlayleft(); }}
technique Overlay_R{ pass P0{ PixelShader = compile ps_2_0 overlayright(); }}
//technique Vivid_L{ pass P0{ PixelShader = compile ps_3_0 vividlightleft(); }}
//technique Vivid_R{ pass P0{ PixelShader = compile ps_3_0 vividlightright(); }}
technique Threshold{ pass P0{ PixelShader = compile ps_2_0 threshold(); }}
technique HWipe{ pass P0{ PixelShader = compile ps_2_0 horwipe(); }}
technique VWipe{ pass P0{ PixelShader = compile ps_2_0 verwipe(); }}
technique SymWipe{ pass P0{ PixelShader = compile ps_2_0 symwipe(); }}
technique HardWipe{ pass P0{ PixelShader = compile ps_2_0 hardwipe(); }}
technique FadeOverBlack{ pass P0{ PixelShader = compile ps_2_0 fadeovergray(); }}