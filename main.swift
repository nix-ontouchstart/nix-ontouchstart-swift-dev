import SwiftUI
import AppKit
import Metal
import MetalKit

// --- Metal Shader Source ---
let shaderSource = """
#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float time;
    float resolution[2];
};

struct VertexOut {
    float4 position [[position]];
};

// The Vertex Shader: Defines the 4 corners of a quad covering the screen
vertex VertexOut vertex_main(uint vid [[vertex_id]]) {
    float4 positions[4] = {
        float4(-1.0, -1.0, 0.0, 1.0), // Bottom Left
        float4( 1.0, -1.0, 0.0, 1.0), // Bottom Right
        float4(-1.0,  1.0, 0.0, 1.0), // Top Left
        float4( 1.0,  1.0, 0.0, 1.0)  // Top Right
    };
    
    VertexOut out;
    out.position = positions[vid];
    return out;
}

// The Fragment Shader: Calculates the "Aurora" colors
fragment float4 aurora_fragment(VertexOut in [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(0)]]) {
    float2 uv = in.position.xy / float2(uniforms.resolution[0], uniforms.resolution[1]);
    float2 p = uv * 3.0;
    
    float t = uniforms.time * 0.5;
    
    // Complex math to create the "Liquid/Aurora" look
    float val = sin(p.x + t) + sin(p.y + t) + sin((p.x + p.y) * 0.5 + t);
    val += sin(p.x * 1.5 + t * 1.2) * 0.5;
    val += sin(p.y * 2.0 - t * 0.8) * 0.5;
    
    float r = 0.5 + 0.5 * sin(val + t);
    float g = 0.5 + 0.5 * sin(val + t + 2.0);
    float b = 0.5 + 0.5 * sin(val + t + 4.0);
    
    return float4(r * 0.4, g * 0.7, b * 0.9, 1.0);
}
"""

// --- Metal Renderer ---
class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime = Date()
    
    struct Uniforms {
        var time: Float
        var resolution: SIMD2<Float>
    }
    
    init(metalView: MTKView) {
        super.init()
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device.makeCommandQueue()
        
        // Compile the shader source
        let library = try! device.makeLibrary(source: shaderSource, options: nil)
        let vertexFunction = library.makeFunction(name: "vertex_main")!
        let fragmentFunction = library.makeFunction(name: "aurora_fragment")!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        // Create the pipeline state
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        metalView.delegate = self
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let pipeline = pipelineState else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        var uniforms = Uniforms(
            time: Float(Date().timeIntervalSince(startTime)),
            resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
        )
        
        encoder?.setRenderPipelineState(pipeline)
        encoder?.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        
        // Draw 4 vertices in a triangle strip to form a full-screen quad
        encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

// --- UI Wrapper ---
struct MetalViewWrapper: NSViewRepresentable {
    static var sharedRenderer: Renderer?

    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.preferredFramesPerSecond = 60
        
        if MetalViewWrapper.sharedRenderer == nil {
            MetalViewWrapper.sharedRenderer = Renderer(metalView: mtkView)
        }
        
        mtkView.device = MetalViewWrapper.sharedRenderer?.device
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        ZStack {
            MetalViewWrapper()
            
            VStack {
                Text("M5 GPU Power")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("Real-time Metal Shader")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Running at 60 FPS")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(width: 600, height: 600)
    }
}

// --- App Entry Point ---
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "M5 GPU Demo"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()

