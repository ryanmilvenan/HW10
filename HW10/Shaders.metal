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
                           const device float4x4 *inParticles [[ buffer(0) ]],
                           device float4x4 *outParticles [[ buffer(1) ]],
                           
                           constant float3 &particleColor [[ buffer(2) ]],
                           
                           constant float &imageWidth [[ buffer(3) ]],
                           constant float &imageHeight [[ buffer(4) ]],
                           
                           constant float &dragFactor [[ buffer(5) ]],
                           
                           uint id [[thread_position_in_grid]])
{
    const float4x4 inParticle = inParticles[id];

    const uint type = id % 3;
    
    const float4 colors[] = {
        float4(particleColor.r, particleColor.g , particleColor.b , 1.0),
        float4(particleColor.b, particleColor.r, particleColor.g, 1.0),
        float4(particleColor.g, particleColor.b, particleColor.r, 1.0)};
    
    const float4 outColor = colors[1];
    
    const float spawnSpeedMultipler = 20.0;

    
    const uint2 particlePositionA(inParticle[0].x, inParticle[0].y);
    
    if (particlePositionA.x > 0 && particlePositionA.y > 0 && particlePositionA.x < imageWidth && particlePositionA.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionA);
    }
    else
    {
        inParticle[0].z = spawnSpeedMultipler * fast::sin(inParticle[0].x + inParticle[0].y);
        inParticle[0].w = spawnSpeedMultipler * fast::cos(inParticle[0].x + inParticle[0].y);
        
        inParticle[0].x = imageWidth/2;
        inParticle[0].y = imageHeight/2;
    }
    
    const uint2 particlePositionB(inParticle[1].x, inParticle[1].y);
    
    if (particlePositionB.x > 0 && particlePositionB.y > 0 && particlePositionB.x < imageWidth && particlePositionB.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionB);
    }
    else
    {
        inParticle[1].z = spawnSpeedMultipler;
        inParticle[1].w = spawnSpeedMultipler;
        
        inParticle[1].x = imageWidth / 2;
        inParticle[1].y = imageHeight/2;
    }
    
    const uint2 particlePositionC(inParticle[2].x, inParticle[2].y);
    
    if (particlePositionC.x > 0 && particlePositionC.y > 0 && particlePositionC.x < imageWidth && particlePositionC.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionC);
    }
    else
    {
        inParticle[2].z = spawnSpeedMultipler;
        inParticle[2].w = spawnSpeedMultipler;
        
        inParticle[2].x = imageWidth / 2;
        inParticle[2].y = imageHeight/2;
    }
    
    const uint2 particlePositionD(inParticle[3].x, inParticle[3].y);
    
    if (particlePositionD.x > 0 && particlePositionD.y > 0 && particlePositionD.x < imageWidth && particlePositionD.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionD);
    }
    else
    {
        inParticle[3].z = 0;
        inParticle[3].w = -9.8;
        
        inParticle[3].x = imageWidth / 2;
        inParticle[3].y = imageHeight/2;
    }
    
    float4x4 outParticle;
    
    outParticle[0] = {
        inParticle[0].x + inParticle[0].z,
        inParticle[0].y + inParticle[0].w,
        (inParticle[0].z * dragFactor),
        (inParticle[0].w * dragFactor),
    };
    
    
    outParticle[1] = {
        inParticle[1].x + inParticle[1].z,
        inParticle[1].y + inParticle[1].w,
        (inParticle[1].z * dragFactor),
        (inParticle[1].w * dragFactor),
    };
    
    
    outParticle[2] = {
        inParticle[2].x + inParticle[2].z,
        inParticle[2].y + inParticle[2].w,
        (inParticle[2].z * dragFactor),
        (inParticle[2].w * dragFactor),
    };
    
    
    outParticle[3] = {
        inParticle[3].x + inParticle[3].z,
        inParticle[3].y + inParticle[3].w,
        (inParticle[3].z * dragFactor),
        (inParticle[3].w * dragFactor),
    };
    
    outParticles[id] = outParticle;

}