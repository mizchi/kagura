// WebGPU C API スタブ
// wgpu-native が完全な C API を提供しているため、このファイルは最小限

#include <moonbit.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// WebGPU と GLFW の macOS 固有ヘッダー
#if __has_include("../../deps/wgpu-macos/include/webgpu/webgpu.h")
#include "../../deps/wgpu-macos/include/webgpu/webgpu.h"
#elif __has_include(<webgpu/webgpu.h>)
#include <webgpu/webgpu.h>
#else
#error "webgpu/webgpu.h not found. run: bash scripts/setup-wgpu-native.sh"
#endif

#define GLFW_EXPOSE_NATIVE_COCOA
#if __has_include("/opt/homebrew/include/GLFW/glfw3.h")
#include "/opt/homebrew/include/GLFW/glfw3.h"
#include "/opt/homebrew/include/GLFW/glfw3native.h"
#elif __has_include("/usr/local/include/GLFW/glfw3.h")
#include "/usr/local/include/GLFW/glfw3.h"
#include "/usr/local/include/GLFW/glfw3native.h"
#elif __has_include("/Users/mz/brew/include/GLFW/glfw3.h")
#include "/Users/mz/brew/include/GLFW/glfw3.h"
#include "/Users/mz/brew/include/GLFW/glfw3native.h"
#elif __has_include(<GLFW/glfw3.h>)
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>
#else
#error "GLFW headers not found. install glfw (brew install glfw)."
#endif

// macOS Cocoa フレームワーク
#import <QuartzCore/CAMetalLayer.h>
#import <Cocoa/Cocoa.h>

// GLFW のヘルパー関数
// glfwGetWindowSize は out パラメータを使うため、MoonBit から直接呼べない
// タプルを返すヘルパー関数を提供する

// NOTE: glfw3.h をインクルードしているため、前方宣言は不要

// MoonBit の WindowSize 構造体（生成されたコードに合わせる）
struct $WindowSize {
  int32_t $0;  // width
  int32_t $1;  // height
};

// ウィンドウサイズを取得して構造体で返す（クラッシュするため未使用）
struct $WindowSize moonbit_glfw_get_window_size_struct(GLFWwindow* window) {
  printf("[C] moonbit_glfw_get_window_size_struct() called, window=%p\n", (void*)window);
  fflush(stdout);

  int width, height;
  glfwGetWindowSize(window, &width, &height);
  printf("[C] Got size: %dx%d\n", width, height);
  fflush(stdout);

  struct $WindowSize result;
  result.$0 = width;
  result.$1 = height;

  printf("[C] Returning WindowSize struct\n");
  fflush(stdout);

  return result;
}

// ウィンドウサイズを個別に取得（分割版）
int32_t moonbit_glfw_get_window_width(GLFWwindow* window) {
  int width, height;
  glfwGetWindowSize(window, &width, &height);
  return width;
}

int32_t moonbit_glfw_get_window_height(GLFWwindow* window) {
  int width, height;
  glfwGetWindowSize(window, &width, &height);
  return height;
}

// MoonBit String から安全にウィンドウを作成
// MoonBit の String は UTF-16 エンコード (uint16_t*)
GLFWwindow* moonbit_glfw_create_window_safe(int32_t width, int32_t height, uint16_t* title_utf16) {
  // UTF-16 から UTF-8 に変換（簡易版：ASCII範囲のみ対応）
  char title_utf8[256] = {0};
  if (title_utf16) {
    int i = 0;
    while (i < 255 && title_utf16[i] != 0) {
      // ASCII範囲のみ変換（0x00-0x7F）
      if (title_utf16[i] < 0x80) {
        title_utf8[i] = (char)title_utf16[i];
      } else {
        title_utf8[i] = '?';  // 非ASCII文字は'?'に
      }
      i++;
    }
    title_utf8[i] = '\0';
  } else {
    strcpy(title_utf8, "Window");
  }

  // ウィンドウヒント設定（WebGPU 用）
  glfwWindowHint(0x00022001, 0);  // GLFW_CLIENT_API = GLFW_NO_API
  glfwWindowHint(0x00020003, 1);  // GLFW_RESIZABLE = GLFW_TRUE

  // ウィンドウ作成
  GLFWwindow* window = glfwCreateWindow(width, height, title_utf8, NULL, NULL);

  return window;
}

// ===============================
// WebGPU Surface 作成
// ===============================

// GLFWwindow から CAMetalLayer を取得/作成
CAMetalLayer* get_metal_layer_from_glfw(GLFWwindow* window) {
  NSWindow* nswindow = glfwGetCocoaWindow(window);
  if (!nswindow) {
    printf("[ERROR] Failed to get NSWindow from GLFW\n");
    return NULL;
  }

  NSView* contentView = [nswindow contentView];
  if (!contentView) {
    printf("[ERROR] Failed to get content view\n");
    return NULL;
  }

  // CAMetalLayer が既にある場合はそれを返す
  if ([[contentView layer] isKindOfClass:[CAMetalLayer class]]) {
    return (CAMetalLayer*)[contentView layer];
  }

  // CAMetalLayer を新規作成
  [contentView setWantsLayer:YES];
  CAMetalLayer* metalLayer = [CAMetalLayer layer];
  [contentView setLayer:metalLayer];

  printf("[INFO] Created CAMetalLayer for GLFW window\n");
  return metalLayer;
}

// GLFW window から wgpu Surface を作成
void* moonbit_create_surface_from_glfw(void* instance, GLFWwindow* window) {
  printf("[C] moonbit_create_surface_from_glfw() called\n");
  printf("[C]   instance=%p, window=%p\n", instance, (void*)window);

  // Metal layer を取得
  CAMetalLayer* metalLayer = get_metal_layer_from_glfw(window);
  if (!metalLayer) {
    printf("[ERROR] Failed to get Metal layer\n");
    return NULL;
  }

  printf("[C]   metalLayer=%p\n", (void*)metalLayer);

  // WGPUSurfaceSourceMetalLayer 構造体を作成
  WGPUSurfaceSourceMetalLayer metalSurfaceSource = {
    .chain = {
      .next = NULL,
      .sType = WGPUSType_SurfaceSourceMetalLayer
    },
    .layer = metalLayer
  };

  // WGPUSurfaceDescriptor を作成
  WGPUSurfaceDescriptor surfaceDescriptor = {
    .nextInChain = (WGPUChainedStruct*)&metalSurfaceSource,
    .label = "GLFW Surface"
  };

  // Surface を作成
  WGPUSurface surface = wgpuInstanceCreateSurface((WGPUInstance)instance, &surfaceDescriptor);
  printf("[C] wgpuInstanceCreateSurface() returned: %p\n", (void*)surface);

  return surface;
}

// ===============================
// Adapter 取得（非同期コールバック対応）
// ===============================

// グローバル変数でコールバック結果を保存
static WGPUAdapter g_adapter = NULL;
static WGPURequestAdapterStatus g_adapter_status;
static int g_adapter_received = 0;

// Adapter 取得のコールバック
void adapter_request_callback(
    WGPURequestAdapterStatus status,
    WGPUAdapter adapter,
    WGPUStringView message,
    void* userdata1,
    void* userdata2
) {
  printf("[C] Adapter callback: status=%d, adapter=%p\n", status, (void*)adapter);
  if (message.data && message.length > 0) {
    printf("[C] Message: %.*s\n", (int)message.length, message.data);
  }

  g_adapter_status = status;
  g_adapter = adapter;
  g_adapter_received = 1;
}

// Adapter をリクエストして同期的に待機（MoonBit から呼び出し）
WGPUAdapter moonbit_request_adapter_sync(WGPUInstance instance, WGPUSurface surface) {
  printf("[C] moonbit_request_adapter_sync() called\n");
  printf("[C]   instance=%p, surface=%p\n", (void*)instance, (void*)surface);

  // グローバル変数をリセット
  g_adapter = NULL;
  g_adapter_status = 0;
  g_adapter_received = 0;

  // RequestAdapterOptions を設定
  WGPURequestAdapterOptions options = {
    .nextInChain = NULL,
    .compatibleSurface = surface,
    .powerPreference = WGPUPowerPreference_HighPerformance,
    .backendType = WGPUBackendType_Undefined,  // Metal を自動選択
    .forceFallbackAdapter = 0
  };

  // コールバック情報を設定
  // AllowSpontaneous: コールバックが即座に呼ばれる（wgpuInstanceWaitAny 不要）
  WGPURequestAdapterCallbackInfo callbackInfo = {
    .nextInChain = NULL,
    .mode = WGPUCallbackMode_AllowSpontaneous,
    .callback = adapter_request_callback,
    .userdata1 = NULL,
    .userdata2 = NULL
  };

  // Adapter をリクエスト（非同期）
  printf("[C] Calling wgpuInstanceRequestAdapter...\n");
  WGPUFuture future = wgpuInstanceRequestAdapter(instance, &options, callbackInfo);
  printf("[C] Got future: id=%llu\n", future.id);

  // AllowSpontaneous モードではコールバックが即座に呼ばれる
  // 念のため少し待機
  for (int i = 0; i < 100 && !g_adapter_received; i++) {
    // スピンウェイト
  }

  if (!g_adapter_received) {
    printf("[ERROR] Callback not called: received=%d\n", g_adapter_received);
    return NULL;
  }

  if (g_adapter_status != WGPURequestAdapterStatus_Success) {
    printf("[ERROR] Adapter request failed: status=%d\n", g_adapter_status);
    return NULL;
  }

  printf("[C] ✓ Adapter acquired successfully: %p\n", (void*)g_adapter);
  return g_adapter;
}

// ===============================
// Device 取得（非同期コールバック対応）
// ===============================

// グローバル変数でコールバック結果を保存
static WGPUDevice g_device = NULL;
static WGPURequestDeviceStatus g_device_status;
static int g_device_received = 0;

// Device 取得のコールバック
void device_request_callback(
    WGPURequestDeviceStatus status,
    WGPUDevice device,
    WGPUStringView message,
    void* userdata1,
    void* userdata2
) {
  printf("[C] Device callback: status=%d, device=%p\n", status, (void*)device);
  if (message.data && message.length > 0) {
    printf("[C] Message: %.*s\n", (int)message.length, message.data);
  }

  g_device_status = status;
  g_device = device;
  g_device_received = 1;
}

// Device をリクエストして同期的に待機（MoonBit から呼び出し）
WGPUDevice moonbit_request_device_sync(WGPUAdapter adapter) {
  printf("[C] moonbit_request_device_sync() called\n");
  printf("[C]   adapter=%p\n", (void*)adapter);

  // グローバル変数をリセット
  g_device = NULL;
  g_device_status = 0;
  g_device_received = 0;

  // DeviceDescriptor を設定（最小限）
  WGPUDeviceDescriptor descriptor = {
    .nextInChain = NULL,
    .label = "Main Device",
    .requiredFeatureCount = 0,
    .requiredFeatures = NULL,
    .requiredLimits = NULL,
    .defaultQueue = {
      .nextInChain = NULL,
      .label = "Main Queue"
    },
    .deviceLostCallbackInfo = {
      .nextInChain = NULL,
      .mode = WGPUCallbackMode_AllowSpontaneous,
      .callback = NULL
    },
    .uncapturedErrorCallbackInfo = {
      .nextInChain = NULL,
      .callback = NULL
    }
  };

  // コールバック情報を設定
  WGPURequestDeviceCallbackInfo callbackInfo = {
    .nextInChain = NULL,
    .mode = WGPUCallbackMode_AllowSpontaneous,
    .callback = device_request_callback,
    .userdata1 = NULL,
    .userdata2 = NULL
  };

  // Device をリクエスト（非同期）
  printf("[C] Calling wgpuAdapterRequestDevice...\n");
  WGPUFuture future = wgpuAdapterRequestDevice(adapter, &descriptor, callbackInfo);
  printf("[C] Got future: id=%llu\n", future.id);

  // AllowSpontaneous モードではコールバックが即座に呼ばれる
  for (int i = 0; i < 100 && !g_device_received; i++) {
    // スピンウェイト
  }

  if (!g_device_received) {
    printf("[ERROR] Device callback not called: received=%d\n", g_device_received);
    return NULL;
  }

  if (g_device_status != WGPURequestDeviceStatus_Success) {
    printf("[ERROR] Device request failed: status=%d\n", g_device_status);
    return NULL;
  }

  printf("[C] ✓ Device acquired successfully: %p\n", (void*)g_device);
  return g_device;
}

// Queue を取得（Device から）
WGPUQueue moonbit_device_get_queue(WGPUDevice device) {
  printf("[C] moonbit_device_get_queue() called\n");
  printf("[C]   device=%p\n", (void*)device);

  WGPUQueue queue = wgpuDeviceGetQueue(device);
  printf("[C] ✓ Queue acquired: %p\n", (void*)queue);

  return queue;
}

// ===============================
// Surface Configuration
// ===============================

// Surface を設定（MoonBit から呼び出し）
void moonbit_configure_surface(
    WGPUSurface surface,
    WGPUDevice device,
    WGPUAdapter adapter,
    uint32_t width,
    uint32_t height
) {
  printf("[C] moonbit_configure_surface() called\n");
  printf("[C]   surface=%p, device=%p, adapter=%p, size=%dx%d\n",
         (void*)surface, (void*)device, (void*)adapter, width, height);

  // Surface の capabilities を取得
  WGPUSurfaceCapabilities capabilities = {0};
  WGPUStatus status = wgpuSurfaceGetCapabilities(surface, adapter, &capabilities);

  if (status != WGPUStatus_Success) {
    printf("[ERROR] Failed to get surface capabilities: status=%d\n", status);
    return;
  }

  printf("[C] Surface capabilities:\n");
  printf("[C]   formatCount=%zu\n", capabilities.formatCount);
  if (capabilities.formatCount > 0) {
    printf("[C]   format[0]=%d\n", capabilities.formats[0]);
  }

  // 最初のフォーマットを使用（通常は BGRA8Unorm）
  WGPUTextureFormat format = capabilities.formatCount > 0
    ? capabilities.formats[0]
    : WGPUTextureFormat_BGRA8Unorm;

  printf("[C] Using format: %d\n", format);

  // Surface を設定
  WGPUSurfaceConfiguration config = {
    .nextInChain = NULL,
    .device = device,
    .format = format,
    .usage = WGPUTextureUsage_RenderAttachment,
    .width = width,
    .height = height,
    .viewFormatCount = 0,
    .viewFormats = NULL,
    .alphaMode = WGPUCompositeAlphaMode_Auto,
    .presentMode = WGPUPresentMode_Fifo
  };

  wgpuSurfaceConfigure(surface, &config);
  printf("[C] ✓ Surface configured successfully\n");

  // capabilities のメモリを解放
  wgpuSurfaceCapabilitiesFreeMembers(capabilities);
}

// ===============================
// Shader Module
// ===============================

// UTF-16 文字列を UTF-8 に変換（ASCII範囲のみ）
char* utf16_to_utf8(uint16_t* utf16_str) {
  if (!utf16_str) return NULL;

  // 文字列長を計算
  size_t len = 0;
  while (utf16_str[len] != 0) {
    len++;
  }

  // UTF-8 バッファを確保（ASCII範囲なので長さは同じ）
  char* utf8_str = (char*)malloc(len + 1);
  if (!utf8_str) return NULL;

  // 変換（ASCII範囲のみ）
  for (size_t i = 0; i < len; i++) {
    utf8_str[i] = (utf16_str[i] < 0x80) ? utf16_str[i] : '?';
  }
  utf8_str[len] = '\0';

  return utf8_str;
}

// ShaderModule を作成（WGSL シェーダーコードから）
void* moonbit_create_shader_module(WGPUDevice device, uint16_t* wgsl_code_utf16) {
  printf("[C] moonbit_create_shader_module() called\n");
  printf("[C]   device=%p\n", (void*)device);

  // UTF-16 → UTF-8 変換
  char* wgsl_code = utf16_to_utf8(wgsl_code_utf16);
  if (!wgsl_code) {
    printf("[ERROR] Failed to convert WGSL code\n");
    return NULL;
  }

  printf("[C] WGSL code (first 100 chars):\n%.*s\n", 100, wgsl_code);

  // ShaderSourceWGSL を作成
  WGPUShaderSourceWGSL wgslDesc = {
    .chain = {
      .next = NULL,
      .sType = WGPUSType_ShaderSourceWGSL
    },
    .code = {
      .data = wgsl_code,
      .length = strlen(wgsl_code)
    }
  };

  // ShaderModuleDescriptor を作成
  WGPUShaderModuleDescriptor descriptor = {
    .nextInChain = (WGPUChainedStruct*)&wgslDesc,
    .label = "Triangle Shader"
  };

  // ShaderModule を作成
  WGPUShaderModule shaderModule = wgpuDeviceCreateShaderModule(device, &descriptor);
  printf("[C] ✓ ShaderModule created: %p\n", (void*)shaderModule);

  free(wgsl_code);
  return shaderModule;
}

// ===============================
// Render Pipeline
// ===============================

// シンプルな RenderPipeline を作成（三角形描画用）
void* moonbit_create_render_pipeline(
    WGPUDevice device,
    WGPUShaderModule shaderModule,
    uint32_t format
) {
  printf("[C] moonbit_create_render_pipeline() called\n");
  printf("[C]   device=%p, shader=%p, format=%d\n",
         (void*)device, (void*)shaderModule, format);

  // Vertex state（頂点なし、シェーダーで生成）
  WGPUVertexState vertexState = {
    .module = shaderModule,
    .entryPoint = {.data = "vs_main", .length = 7},
    .constantCount = 0,
    .constants = NULL,
    .bufferCount = 0,
    .buffers = NULL
  };

  // Fragment state
  WGPUColorTargetState colorTarget = {
    .format = format,
    .blend = NULL,
    .writeMask = WGPUColorWriteMask_All
  };

  WGPUFragmentState fragmentState = {
    .module = shaderModule,
    .entryPoint = {.data = "fs_main", .length = 7},
    .constantCount = 0,
    .constants = NULL,
    .targetCount = 1,
    .targets = &colorTarget
  };

  // RenderPipelineDescriptor
  WGPURenderPipelineDescriptor descriptor = {
    .nextInChain = NULL,
    .label = "Triangle Pipeline",
    .layout = NULL,  // Auto layout
    .vertex = vertexState,
    .primitive = {
      .topology = WGPUPrimitiveTopology_TriangleList,
      .stripIndexFormat = WGPUIndexFormat_Undefined,
      .frontFace = WGPUFrontFace_CCW,
      .cullMode = WGPUCullMode_None
    },
    .depthStencil = NULL,
    .multisample = {
      .count = 1,
      .mask = 0xFFFFFFFF,
      .alphaToCoverageEnabled = 0
    },
    .fragment = &fragmentState
  };

  WGPURenderPipeline pipeline = wgpuDeviceCreateRenderPipeline(device, &descriptor);
  printf("[C] ✓ RenderPipeline created: %p\n", (void*)pipeline);

  return pipeline;
}

// ===============================
// Rendering
// ===============================

// 1フレーム描画（MoonBit から呼び出し）
void moonbit_render_frame(
    WGPUSurface surface,
    WGPUDevice device,
    WGPUQueue queue,
    WGPURenderPipeline pipeline
) {
  // Surface から現在のテクスチャを取得
  WGPUSurfaceTexture surfaceTexture;
  wgpuSurfaceGetCurrentTexture(surface, &surfaceTexture);

  if (surfaceTexture.status != WGPUSurfaceGetCurrentTextureStatus_SuccessOptimal &&
      surfaceTexture.status != WGPUSurfaceGetCurrentTextureStatus_SuccessSuboptimal) {
    printf("[ERROR] Failed to get surface texture: status=%d\n", surfaceTexture.status);
    return;
  }

  // TextureView を作成
  WGPUTextureViewDescriptor viewDesc = {
    .nextInChain = NULL,
    .label = "Surface Texture View",
    .format = WGPUTextureFormat_Undefined,  // Use texture's format
    .dimension = WGPUTextureViewDimension_2D,
    .baseMipLevel = 0,
    .mipLevelCount = 1,
    .baseArrayLayer = 0,
    .arrayLayerCount = 1,
    .aspect = WGPUTextureAspect_All
  };

  WGPUTextureView view = wgpuTextureCreateView(surfaceTexture.texture, &viewDesc);

  // CommandEncoder を作成
  WGPUCommandEncoderDescriptor encoderDesc = {
    .nextInChain = NULL,
    .label = "Command Encoder"
  };
  WGPUCommandEncoder encoder = wgpuDeviceCreateCommandEncoder(device, &encoderDesc);

  // RenderPass を開始
  WGPURenderPassColorAttachment colorAttachment = {
    .view = view,
    .depthSlice = WGPU_DEPTH_SLICE_UNDEFINED,
    .resolveTarget = NULL,
    .loadOp = WGPULoadOp_Clear,
    .storeOp = WGPUStoreOp_Store,
    .clearValue = {0.1, 0.2, 0.3, 1.0}  // Dark blue background
  };

  WGPURenderPassDescriptor renderPassDesc = {
    .nextInChain = NULL,
    .label = "Render Pass",
    .colorAttachmentCount = 1,
    .colorAttachments = &colorAttachment,
    .depthStencilAttachment = NULL,
    .occlusionQuerySet = NULL,
    .timestampWrites = NULL
  };

  WGPURenderPassEncoder pass = wgpuCommandEncoderBeginRenderPass(encoder, &renderPassDesc);

  // Pipeline を設定して三角形を描画
  wgpuRenderPassEncoderSetPipeline(pass, pipeline);
  wgpuRenderPassEncoderDraw(pass, 3, 1, 0, 0);  // 3 vertices

  // RenderPass を終了
  wgpuRenderPassEncoderEnd(pass);
  wgpuRenderPassEncoderRelease(pass);

  // CommandBuffer を作成して Queue に送信
  WGPUCommandBufferDescriptor cmdBufferDesc = {
    .nextInChain = NULL,
    .label = "Command Buffer"
  };
  WGPUCommandBuffer cmdBuffer = wgpuCommandEncoderFinish(encoder, &cmdBufferDesc);
  wgpuQueueSubmit(queue, 1, &cmdBuffer);

  // リソースをクリーンアップ
  wgpuCommandBufferRelease(cmdBuffer);
  wgpuCommandEncoderRelease(encoder);
  wgpuTextureViewRelease(view);

  // Present
  wgpuSurfacePresent(surface);

  // Texture を解放
  wgpuTextureRelease(surfaceTexture.texture);
}
