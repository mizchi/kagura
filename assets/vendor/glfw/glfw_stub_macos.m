// macOS-specific GLFW functions (touch input via Cocoa)

#ifdef __APPLE__

#include <moonbit.h>
#include <stdint.h>

#define GLFW_EXPOSE_NATIVE_COCOA
#if __has_include("../include/GLFW/glfw3.h")
#include "../include/GLFW/glfw3.h"
#include "../include/GLFW/glfw3native.h"
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

#import <QuartzCore/CAMetalLayer.h>
#import <Cocoa/Cocoa.h>

// Access cross-platform global
extern GLFWwindow* g_input_window;

// === Touch state ===

#define MOONBIT_MAX_TOUCHES 16
typedef struct {
  int32_t id;
  double x;
  double y;
  int32_t touch_type; // 0=Direct, 1=Indirect, 3=Unknown
} moonbit_touch_state;
static moonbit_touch_state g_touches[MOONBIT_MAX_TOUCHES];
static int32_t g_touch_count = 0;

// === Touch helpers ===

static int32_t moonbit_touch_id_from_identity(id identity) {
  if (identity == nil) {
    return -1;
  }
  const NSUInteger hash_value = [identity hash];
  return (int32_t)(hash_value & 0x7fffffffU);
}

static void moonbit_reset_touches(void) {
  g_touch_count = 0;
  for (int i = 0; i < MOONBIT_MAX_TOUCHES; i++) {
    g_touches[i].id = -1;
    g_touches[i].x = 0.0;
    g_touches[i].y = 0.0;
    g_touches[i].touch_type = 3;
  }
}

static void moonbit_update_touches(GLFWwindow* window) {
  moonbit_reset_touches();
  if (window == NULL || window != g_input_window) {
    return;
  }
  NSWindow* nswindow = glfwGetCocoaWindow(window);
  if (nswindow == nil) {
    return;
  }
  NSView* contentView = [nswindow contentView];
  if (contentView == nil) {
    return;
  }
  NSEvent* event = [NSApp currentEvent];
  if (event == nil) {
    return;
  }

  NSSet* touches = nil;
  @try {
    touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:contentView];
  } @catch (NSException* exception) {
    (void)exception;
    return;
  }
  if (touches == nil || [touches count] == 0) {
    return;
  }

  NSRect bounds = [contentView bounds];
  const double width = bounds.size.width > 0.0 ? bounds.size.width : 1.0;
  const double height = bounds.size.height > 0.0 ? bounds.size.height : 1.0;

  int32_t index = 0;
  for (NSTouch* touch in touches) {
    if (index >= MOONBIT_MAX_TOUCHES) {
      break;
    }
    const NSPoint normalized = [touch normalizedPosition];
    double x = normalized.x * width;
    double y = (1.0 - normalized.y) * height;
    if (x < 0.0) {
      x = 0.0;
    }
    if (y < 0.0) {
      y = 0.0;
    }
    g_touches[index].id = moonbit_touch_id_from_identity([touch identity]);
    if (g_touches[index].id < 0) {
      g_touches[index].id = index;
    }
    g_touches[index].x = x;
    g_touches[index].y = y;
    if ([touch respondsToSelector:@selector(type)]) {
      NSInteger touchType = [touch type];
      if (touchType == NSTouchTypeDirect) {
        g_touches[index].touch_type = 0;
      } else if (touchType == NSTouchTypeIndirect) {
        g_touches[index].touch_type = 1;
      } else {
        g_touches[index].touch_type = 3;
      }
    } else {
      g_touches[index].touch_type = 3;
    }
    index++;
  }
  g_touch_count = index;
}

// === Touch API ===

int32_t moonbit_glfw_touch_count(GLFWwindow* window) {
  moonbit_update_touches(window);
  return g_touch_count;
}

int32_t moonbit_glfw_touch_id_at(GLFWwindow* window, int32_t index) {
  moonbit_update_touches(window);
  if (index < 0 || index >= g_touch_count) {
    return -1;
  }
  return g_touches[index].id;
}

double moonbit_glfw_touch_x_at(GLFWwindow* window, int32_t index) {
  moonbit_update_touches(window);
  if (index < 0 || index >= g_touch_count) {
    return 0.0;
  }
  return g_touches[index].x;
}

double moonbit_glfw_touch_y_at(GLFWwindow* window, int32_t index) {
  moonbit_update_touches(window);
  if (index < 0 || index >= g_touch_count) {
    return 0.0;
  }
  return g_touches[index].y;
}

int32_t moonbit_glfw_touch_type_at(GLFWwindow* window, int32_t index) {
  moonbit_update_touches(window);
  if (index < 0 || index >= g_touch_count) {
    return 3;
  }
  return g_touches[index].touch_type;
}

// === Platform window setup ===

void moonbit_glfw_platform_setup_window(GLFWwindow* window) {
  NSWindow* nswindow = glfwGetCocoaWindow(window);
  if (nswindow != nil) {
    NSView* contentView = [nswindow contentView];
    if (contentView != nil) {
      if ([contentView respondsToSelector:@selector(setAllowedTouchTypes:)]) {
        [contentView setAllowedTouchTypes:(NSTouchTypeMaskDirect | NSTouchTypeMaskIndirect)];
      }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      if ([contentView respondsToSelector:@selector(setAcceptsTouchEvents:)]) {
        [contentView setAcceptsTouchEvents:YES];
      }
#pragma clang diagnostic pop
      if ([contentView respondsToSelector:@selector(setWantsRestingTouches:)]) {
        [contentView setWantsRestingTouches:YES];
      }
    }
  }
  moonbit_reset_touches();
}

#endif // __APPLE__
