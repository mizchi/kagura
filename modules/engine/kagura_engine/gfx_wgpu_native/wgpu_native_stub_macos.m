// macOS-specific Surface creation (Cocoa/Metal)
// This file is compiled only on macOS; on other platforms it is empty.

#ifdef __APPLE__

#import <QuartzCore/CAMetalLayer.h>
#import <Cocoa/Cocoa.h>

// WebGPU header
#if __has_include("../../../../deps/wgpu-native/include/webgpu/webgpu.h")
#include "../../../../deps/wgpu-native/include/webgpu/webgpu.h"
#elif __has_include("../../../../deps/wgpu-macos/include/webgpu/webgpu.h")
#include "../../../../deps/wgpu-macos/include/webgpu/webgpu.h"
#elif __has_include("../../../deps/wgpu-native/include/webgpu/webgpu.h")
#include "../../../deps/wgpu-native/include/webgpu/webgpu.h"
#elif __has_include("../../../deps/wgpu-macos/include/webgpu/webgpu.h")
#include "../../../deps/wgpu-macos/include/webgpu/webgpu.h"
#elif __has_include(<webgpu/webgpu.h>)
#include <webgpu/webgpu.h>
#endif

// GLFW
#define GLFW_EXPOSE_NATIVE_COCOA
#if __has_include("../../../../vendor/glfw/include/GLFW/glfw3.h")
#include "../../../../vendor/glfw/include/GLFW/glfw3.h"
#include "../../../../vendor/glfw/include/GLFW/glfw3native.h"
#elif __has_include("../../../vendor/glfw/include/GLFW/glfw3.h")
#include "../../../vendor/glfw/include/GLFW/glfw3.h"
#include "../../../vendor/glfw/include/GLFW/glfw3native.h"
#elif __has_include("/opt/homebrew/include/GLFW/glfw3.h")
#include "/opt/homebrew/include/GLFW/glfw3.h"
#include "/opt/homebrew/include/GLFW/glfw3native.h"
#elif __has_include("/usr/local/include/GLFW/glfw3.h")
#include "/usr/local/include/GLFW/glfw3.h"
#include "/usr/local/include/GLFW/glfw3native.h"
#elif __has_include(<GLFW/glfw3.h>)
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>
#endif

#include <stdio.h>

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

// GLFW window から wgpu Surface を作成 (macOS Metal backend)
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

#endif // __APPLE__
