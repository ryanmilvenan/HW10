//
//  Shaders.metal
//  HW10
//
//  Created by Wind on 3/31/16.
//  Copyright © 2016 Ryan Milvenan. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void particleShader(texture2d<float, access::write> outTexture [[texture(0)]],
                           const device float4 *inParticles [[ buffer(0) ]],
                           device float4 *outParticles [[ buffer(1) ]],
                           
                           constant float3 &particleColor [[ buffer(2) ]],
                           
                           constant float &imageWidth [[ buffer(3) ]],
                           constant float &imageHeight [[ buffer(4) ]],
                                                      
                           uint id [[thread_position_in_grid]])
{
    const float4 inParticle = inParticles[id];
    
    const float4 outColor = float4(particleColor, 1.0);
    
    
    const uint2 particlePosition(inParticle.x, inParticle.y);
    
    if (particlePosition.x > 0 && particlePosition.y > 0 && particlePosition.x < imageWidth && particlePosition.y < imageHeight)
    {
        outTexture.write(outColor, particlePosition);
    }
    else
    {
        inParticle.z = 0;
        inParticle.w = 0;
        inParticle.y = inParticle.y - imageHeight;
    }

    
    float4 outParticle;
    
    outParticle = {
        inParticle.x + inParticle.z,
        inParticle.y + 1.5,
        inParticle.z,
        inParticle.w,
    };

    outParticles[id] = outParticle;

}