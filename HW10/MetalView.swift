//
//  MetalView.swift
//  HW10
//
//  Created by Wind on 3/31/16.
//  Copyright © 2016 Ryan Milvenan. All rights reserved.
//

import MetalKit
import simd

class MetalView: MTKView {
    
    let imageWidth: UInt
    let imageHeight: UInt
    
    private var imageWidthFloatBuffer: MTLBuffer!
    private var imageHeightFloatBuffer: MTLBuffer!
    
    let bytesPerRow: Int
    let region: MTLRegion
    let blankBitmapRawData : [UInt8]
    
    private var kernelFunction: MTLFunction!
    private var pipelineState: MTLComputePipelineState!
    private var defaultLibrary: MTLLibrary! = nil
    private var commandQueue: MTLCommandQueue! = nil
    
    private var threadsPerThreadgroup:MTLSize!
    private var threadgroupsPerGrid:MTLSize!
    
    let particleCount: Int
    let alignment:Int = 0x4000
    let particlesMemoryByteSize:Int
    
    private var particlesMemory:UnsafeMutablePointer<Void> = nil
    private var particlesVoidPtr: COpaquePointer!
    private var particlesParticlePtr: UnsafeMutablePointer<Vector4>!
    private var particlesParticleBufferPtr: UnsafeMutableBufferPointer<Vector4>!
    
    var particleColor = ParticleColor(R: 0.14, G: 0.62, B: 1, A: 1)
    
    var particlesBuffer: MTLBuffer!

    
    required init(coder: NSCoder) {
        particleCount = ParticleCount.QuarterMillion.rawValue
        imageWidth = 1024
        imageHeight = 768
        bytesPerRow = Int(4 * imageWidth)
        region = MTLRegionMake2D(0, 0, Int(imageWidth), Int(imageHeight))
        blankBitmapRawData = [UInt8](count: Int(imageWidth * imageHeight * 4), repeatedValue: 0)
        particlesMemoryByteSize = particleCount * sizeof(Vector4)
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()!
        
        framebufferOnly = false
        
        colorPixelFormat = MTLPixelFormat.BGRA8Unorm
        sampleCount = 1
        preferredFramesPerSecond = 60
        
        drawableSize = CGSize(width: CGFloat(imageWidth), height: CGFloat(imageHeight));
        
        setUpParticles()
        setUpMetal()
        
        particlesBuffer = device!.newBufferWithBytesNoCopy(particlesMemory, length: Int(particlesMemoryByteSize), options: MTLResourceOptions.StorageModeShared, deallocator: nil)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        step()
    }

    
    private func setUpMetal()
    {
        guard let device = MTLCreateSystemDefaultDevice() else
        {
            Swift.print("Could not create Metal System Device")
            
            return
        }
        
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
        
        kernelFunction = defaultLibrary.newFunctionWithName("particleShader")
        
        do {
            try pipelineState = device.newComputePipelineStateWithFunction(kernelFunction!)
        } catch let e {
            Swift.print("Could not create pipeline state: \(e)")
        }

        
        let threadExecutionWidth = pipelineState.threadExecutionWidth
        
        threadsPerThreadgroup = MTLSize(width:threadExecutionWidth,height:1,depth:1)
        threadgroupsPerGrid = MTLSize(width:particleCount / threadExecutionWidth, height:1, depth:1)
        
        var imageWidthFloat = Float(imageWidth)
        var imageHeightFloat = Float(imageHeight)
        
        imageWidthFloatBuffer =  device.newBufferWithBytes(&imageWidthFloat, length: sizeof(Float), options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
        imageHeightFloatBuffer = device.newBufferWithBytes(&imageHeightFloat, length: sizeof(Float), options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
    }
    
    private func setUpParticles()
    {
        posix_memalign(&particlesMemory, alignment, particlesMemoryByteSize)
        
        particlesVoidPtr = COpaquePointer(particlesMemory)
        particlesParticlePtr = UnsafeMutablePointer<Vector4>(particlesVoidPtr)
        particlesParticleBufferPtr = UnsafeMutableBufferPointer(start: particlesParticlePtr, count: particleCount)
        
        resetParticles()
    }
    
    func resetParticles()
    {
        func rand() -> Float32
        {
            return Float(drand48() - 0.5) * 0.005
        }
        
        let imageWidthDouble = Double(imageWidth)
        
        for index in particlesParticleBufferPtr.startIndex ..< particlesParticleBufferPtr.endIndex
        {
            let positionX = Float(drand48()*imageWidthDouble)
            let positionY = Float(arc4random() % UInt32(imageHeight))

            let particle = Vector4(x:positionX, y:positionY, z:rand(), w:rand())
            
            particlesParticleBufferPtr[index] = particle
        }
    }
    
    func step()
    {
        
        let commandBuffer = commandQueue.commandBuffer()
        let commandEncoder = commandBuffer.computeCommandEncoder()
        
        commandEncoder.setComputePipelineState(pipelineState)
        
        commandEncoder.setBuffer(particlesBuffer, offset: 0, atIndex: 0)
        commandEncoder.setBuffer(particlesBuffer, offset: 0, atIndex: 1)
        
        commandEncoder.setBytes(&particleColor, length: sizeof(ParticleColor), atIndex: 2)
        
        commandEncoder.setBuffer(imageWidthFloatBuffer, offset: 0, atIndex: 3)
        commandEncoder.setBuffer(imageHeightFloatBuffer, offset: 0, atIndex: 4)
                
        guard let drawable = currentDrawable else
        {
            Swift.print("currentDrawable returned nil")
            
            return
        }

        drawable.texture.replaceRegion(self.region, mipmapLevel: 0, withBytes: blankBitmapRawData, bytesPerRow: bytesPerRow)

        commandEncoder.setTexture(drawable.texture, atIndex: 0)
        
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        
        commandBuffer.commit()
        
    }

    
    enum ParticleCount: Int
    {
        case EighthMillion = 32768
        case QuarterMillion = 65536
        case HalfMillion = 131072
        case OneMillion =  262144
        case TwoMillion =  524288
        case FourMillion = 1048576
        case EightMillion = 2097152
        case SixteenMillion = 4194304
    }
    
    struct ParticleColor
    {
        var R: Float32 = 0
        var G: Float32 = 0
        var B: Float32 = 0
        var A: Float32 = 1
    }
    
    struct Vector4
    {
        var x: Float32 = 0
        var y: Float32 = 0
        var z: Float32 = 0
        var w: Float32 = 0
    }
    
}