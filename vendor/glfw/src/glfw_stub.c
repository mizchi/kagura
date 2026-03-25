// GLFW Cross-Platform Stub (mizchi/glfw)

#include <moonbit.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

// GLFW headers
#if __has_include("../include/GLFW/glfw3.h")
#include "../include/GLFW/glfw3.h"
#elif __has_include("/opt/homebrew/include/GLFW/glfw3.h")
#include "/opt/homebrew/include/GLFW/glfw3.h"
#elif __has_include("/usr/local/include/GLFW/glfw3.h")
#include "/usr/local/include/GLFW/glfw3.h"
#elif __has_include(<GLFW/glfw3.h>)
#include <GLFW/glfw3.h>
#else
#error "GLFW headers not found. Install GLFW (brew install glfw / vcpkg install glfw3)."
#endif

// MoonBit WindowSize struct
struct $WindowSize {
  int32_t $0;  // width
  int32_t $1;  // height
};

// Platform-specific window setup (implemented in glfw_stub_macos.m on macOS)
#ifdef __APPLE__
extern void moonbit_glfw_platform_setup_window(GLFWwindow* window);
#else
static void moonbit_glfw_platform_setup_window(GLFWwindow* window) { (void)window; }
#endif

// === Cross-platform globals ===

static int g_windowed_x = 100;
static int g_windowed_y = 100;
static int g_windowed_width = 800;
static int g_windowed_height = 600;
GLFWwindow* g_input_window = NULL;  // non-static: accessed from platform files
static double g_scroll_x = 0.0;
static double g_scroll_y = 0.0;

// === Scroll callback ===

static void moonbit_glfw_scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
  if (window == NULL || window != g_input_window) {
    return;
  }
  g_scroll_x += xoffset;
  g_scroll_y += yoffset;
}

// === Window size ===

struct $WindowSize moonbit_glfw_get_window_size_struct(GLFWwindow* window) {
  int width, height;
  glfwGetWindowSize(window, &width, &height);
  struct $WindowSize result;
  result.$0 = width;
  result.$1 = height;
  return result;
}

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

int32_t moonbit_glfw_get_framebuffer_width(GLFWwindow* window) {
  int width, height;
  glfwGetFramebufferSize(window, &width, &height);
  return width;
}

int32_t moonbit_glfw_get_framebuffer_height(GLFWwindow* window) {
  int width, height;
  glfwGetFramebufferSize(window, &width, &height);
  return height;
}

// === Fullscreen ===

int32_t moonbit_glfw_is_fullscreen(GLFWwindow* window) {
  if (window == NULL) {
    return 0;
  }
  return glfwGetWindowMonitor(window) != NULL ? 1 : 0;
}

int32_t moonbit_glfw_set_fullscreen(GLFWwindow* window, int32_t enabled) {
  if (window == NULL) {
    return 0;
  }

  const int is_fullscreen = moonbit_glfw_is_fullscreen(window);
  if (enabled != 0) {
    if (is_fullscreen) {
      return 1;
    }
    GLFWmonitor* monitor = glfwGetPrimaryMonitor();
    if (monitor == NULL) {
      return 0;
    }
    const GLFWvidmode* mode = glfwGetVideoMode(monitor);
    if (mode == NULL) {
      return 0;
    }
    glfwGetWindowPos(window, &g_windowed_x, &g_windowed_y);
    glfwGetWindowSize(window, &g_windowed_width, &g_windowed_height);
    glfwSetWindowMonitor(
      window,
      monitor,
      0,
      0,
      mode->width,
      mode->height,
      mode->refreshRate
    );
    return moonbit_glfw_is_fullscreen(window);
  }

  if (!is_fullscreen) {
    return 0;
  }
  const int restore_width = g_windowed_width <= 0 ? 800 : g_windowed_width;
  const int restore_height = g_windowed_height <= 0 ? 600 : g_windowed_height;
  glfwSetWindowMonitor(
    window,
    NULL,
    g_windowed_x,
    g_windowed_y,
    restore_width,
    restore_height,
    0
  );
  return moonbit_glfw_is_fullscreen(window);
}

// === Cursor ===

static int32_t moonbit_cursor_mode_from_glfw(int glfw_mode) {
  switch (glfw_mode) {
    case GLFW_CURSOR_HIDDEN:
      return 1;
    case GLFW_CURSOR_DISABLED:
      return 2;
    case GLFW_CURSOR_NORMAL:
    default:
      return 0;
  }
}

static int moonbit_cursor_mode_to_glfw(int32_t cursor_mode) {
  switch (cursor_mode) {
    case 1:
      return GLFW_CURSOR_HIDDEN;
    case 2:
      return GLFW_CURSOR_DISABLED;
    case 0:
    default:
      return GLFW_CURSOR_NORMAL;
  }
}

int32_t moonbit_glfw_set_cursor_mode(GLFWwindow* window, int32_t cursor_mode) {
  if (window == NULL) {
    return 0;
  }
  glfwSetInputMode(window, GLFW_CURSOR, moonbit_cursor_mode_to_glfw(cursor_mode));
  const int current = glfwGetInputMode(window, GLFW_CURSOR);
  return moonbit_cursor_mode_from_glfw(current);
}

int32_t moonbit_glfw_get_cursor_mode(GLFWwindow* window) {
  if (window == NULL) {
    return 0;
  }
  const int current = glfwGetInputMode(window, GLFW_CURSOR);
  return moonbit_cursor_mode_from_glfw(current);
}

double moonbit_glfw_get_cursor_x(GLFWwindow* window) {
  if (window == NULL) {
    return 0.0;
  }
  double cursor_x = 0.0;
  double cursor_y = 0.0;
  glfwGetCursorPos(window, &cursor_x, &cursor_y);
  return cursor_x;
}

double moonbit_glfw_get_cursor_y(GLFWwindow* window) {
  if (window == NULL) {
    return 0.0;
  }
  double cursor_x = 0.0;
  double cursor_y = 0.0;
  glfwGetCursorPos(window, &cursor_x, &cursor_y);
  return cursor_y;
}

// === Scroll ===

double moonbit_glfw_take_scroll_x(GLFWwindow* window) {
  if (window == NULL || window != g_input_window) {
    return 0.0;
  }
  const double current = g_scroll_x;
  g_scroll_x = 0.0;
  return current;
}

double moonbit_glfw_take_scroll_y(GLFWwindow* window) {
  if (window == NULL || window != g_input_window) {
    return 0.0;
  }
  const double current = g_scroll_y;
  g_scroll_y = 0.0;
  return current;
}

// === Keyboard ===

int32_t moonbit_glfw_pressed_key_count(GLFWwindow* window) {
  if (window == NULL) {
    return 0;
  }
  int32_t count = 0;
  for (int key = GLFW_KEY_SPACE; key <= GLFW_KEY_LAST; key++) {
    const int state = glfwGetKey(window, key);
    if (state == GLFW_PRESS || state == GLFW_REPEAT) {
      count++;
    }
  }
  return count;
}

int32_t moonbit_glfw_pressed_key_at(GLFWwindow* window, int32_t index) {
  if (window == NULL || index < 0) {
    return -1;
  }
  int32_t current_index = 0;
  for (int key = GLFW_KEY_SPACE; key <= GLFW_KEY_LAST; key++) {
    const int state = glfwGetKey(window, key);
    if (state == GLFW_PRESS || state == GLFW_REPEAT) {
      if (current_index == index) {
        return key;
      }
      current_index++;
    }
  }
  return -1;
}

// === Mouse buttons ===

int32_t moonbit_glfw_pressed_mouse_button_count(GLFWwindow* window) {
  if (window == NULL) {
    return 0;
  }
  int32_t count = 0;
  for (int button = GLFW_MOUSE_BUTTON_1; button <= GLFW_MOUSE_BUTTON_LAST; button++) {
    const int state = glfwGetMouseButton(window, button);
    if (state == GLFW_PRESS) {
      count++;
    }
  }
  return count;
}

int32_t moonbit_glfw_pressed_mouse_button_at(GLFWwindow* window, int32_t index) {
  if (window == NULL || index < 0) {
    return -1;
  }
  int32_t current_index = 0;
  for (int button = GLFW_MOUSE_BUTTON_1; button <= GLFW_MOUSE_BUTTON_LAST; button++) {
    const int state = glfwGetMouseButton(window, button);
    if (state == GLFW_PRESS) {
      if (current_index == index) {
        return button;
      }
      current_index++;
    }
  }
  return -1;
}

// === Touch (non-macOS fallback) ===

#ifndef __APPLE__
int32_t moonbit_glfw_touch_count(GLFWwindow* window) {
  (void)window;
  return 0;
}

int32_t moonbit_glfw_touch_id_at(GLFWwindow* window, int32_t index) {
  (void)window; (void)index;
  return -1;
}

double moonbit_glfw_touch_x_at(GLFWwindow* window, int32_t index) {
  (void)window; (void)index;
  return 0.0;
}

double moonbit_glfw_touch_y_at(GLFWwindow* window, int32_t index) {
  (void)window; (void)index;
  return 0.0;
}

int32_t moonbit_glfw_touch_type_at(GLFWwindow* window, int32_t index) {
  (void)window; (void)index;
  return 3; // Unknown
}
#endif

// === Gamepad ===

#if defined(GLFW_GAMEPAD_AXIS_LAST) && defined(GLFW_GAMEPAD_BUTTON_LAST)
static int32_t moonbit_glfw_gamepad_jid_at(int32_t index) {
  if (index < 0) {
    return -1;
  }
  int32_t current_index = 0;
  for (int jid = GLFW_JOYSTICK_1; jid <= GLFW_JOYSTICK_LAST; jid++) {
    if (glfwJoystickPresent(jid) != GLFW_TRUE) {
      continue;
    }
    if (glfwJoystickIsGamepad(jid) != GLFW_TRUE) {
      continue;
    }
    if (current_index == index) {
      return (int32_t)jid;
    }
    current_index++;
  }
  return -1;
}

int32_t moonbit_glfw_gamepad_count(void) {
  int32_t count = 0;
  for (int jid = GLFW_JOYSTICK_1; jid <= GLFW_JOYSTICK_LAST; jid++) {
    if (glfwJoystickPresent(jid) == GLFW_TRUE && glfwJoystickIsGamepad(jid) == GLFW_TRUE) {
      count++;
    }
  }
  return count;
}

int32_t moonbit_glfw_gamepad_id_at(int32_t index) {
  return moonbit_glfw_gamepad_jid_at(index);
}

int32_t moonbit_glfw_gamepad_axis_count(int32_t index) {
  const int32_t jid = moonbit_glfw_gamepad_jid_at(index);
  if (jid < 0) {
    return 0;
  }
  GLFWgamepadstate state;
  if (glfwGetGamepadState((int)jid, &state) != GLFW_TRUE) {
    return 0;
  }
  return (int32_t)(GLFW_GAMEPAD_AXIS_LAST + 1);
}

double moonbit_glfw_gamepad_axis_at(int32_t gamepad_index, int32_t axis_index) {
  if (axis_index < 0 || axis_index > GLFW_GAMEPAD_AXIS_LAST) {
    return 0.0;
  }
  const int32_t jid = moonbit_glfw_gamepad_jid_at(gamepad_index);
  if (jid < 0) {
    return 0.0;
  }
  GLFWgamepadstate state;
  if (glfwGetGamepadState((int)jid, &state) != GLFW_TRUE) {
    return 0.0;
  }
  return (double)state.axes[axis_index];
}

int32_t moonbit_glfw_gamepad_pressed_button_count(int32_t index) {
  const int32_t jid = moonbit_glfw_gamepad_jid_at(index);
  if (jid < 0) {
    return 0;
  }
  GLFWgamepadstate state;
  if (glfwGetGamepadState((int)jid, &state) != GLFW_TRUE) {
    return 0;
  }
  int32_t count = 0;
  for (int button = 0; button <= GLFW_GAMEPAD_BUTTON_LAST; button++) {
    if (state.buttons[button] == GLFW_PRESS) {
      count++;
    }
  }
  return count;
}

int32_t moonbit_glfw_gamepad_pressed_button_at(int32_t gamepad_index, int32_t button_index) {
  if (button_index < 0) {
    return -1;
  }
  const int32_t jid = moonbit_glfw_gamepad_jid_at(gamepad_index);
  if (jid < 0) {
    return -1;
  }
  GLFWgamepadstate state;
  if (glfwGetGamepadState((int)jid, &state) != GLFW_TRUE) {
    return -1;
  }
  int32_t current_index = 0;
  for (int button = 0; button <= GLFW_GAMEPAD_BUTTON_LAST; button++) {
    if (state.buttons[button] == GLFW_PRESS) {
      if (current_index == button_index) {
        return (int32_t)button;
      }
      current_index++;
    }
  }
  return -1;
}
#else
int32_t moonbit_glfw_gamepad_count(void) {
  return 0;
}

int32_t moonbit_glfw_gamepad_id_at(int32_t index) {
  (void)index;
  return -1;
}

int32_t moonbit_glfw_gamepad_axis_count(int32_t index) {
  (void)index;
  return 0;
}

double moonbit_glfw_gamepad_axis_at(int32_t gamepad_index, int32_t axis_index) {
  (void)gamepad_index;
  (void)axis_index;
  return 0.0;
}

int32_t moonbit_glfw_gamepad_pressed_button_count(int32_t index) {
  (void)index;
  return 0;
}

int32_t moonbit_glfw_gamepad_pressed_button_at(int32_t gamepad_index, int32_t button_index) {
  (void)gamepad_index;
  (void)button_index;
  return -1;
}
#endif

// === Content scale / Window attention ===

double moonbit_glfw_get_window_content_scale(GLFWwindow* window) {
  if (window == NULL) {
    return 1.0;
  }
  float xscale = 1.0f;
  float yscale = 1.0f;
  glfwGetWindowContentScale(window, &xscale, &yscale);
  if (xscale <= 0.0f) {
    return 1.0;
  }
  return (double)xscale;
}

void moonbit_glfw_request_window_attention_safe(GLFWwindow* window) {
  if (window == NULL) {
    return;
  }
#if defined(GLFW_VERSION_MAJOR) && (GLFW_VERSION_MAJOR > 3 || (GLFW_VERSION_MAJOR == 3 && GLFW_VERSION_MINOR >= 3))
  glfwRequestWindowAttention(window);
#endif
}

// === Window creation ===

GLFWwindow* moonbit_glfw_create_window_safe(int32_t width, int32_t height, uint16_t* title_utf16) {
  // UTF-16 to UTF-8 (ASCII range only)
  char title_utf8[256] = {0};
  if (title_utf16) {
    int i = 0;
    while (i < 255 && title_utf16[i] != 0) {
      if (title_utf16[i] < 0x80) {
        title_utf8[i] = (char)title_utf16[i];
      } else {
        title_utf8[i] = '?';
      }
      i++;
    }
    title_utf8[i] = '\0';
  } else {
    strcpy(title_utf8, "Window");
  }

  glfwWindowHint(0x00022001, 0);  // GLFW_CLIENT_API = GLFW_NO_API
  glfwWindowHint(0x00020003, 1);  // GLFW_RESIZABLE = GLFW_TRUE

  GLFWwindow* window = glfwCreateWindow(width, height, title_utf8, NULL, NULL);
  g_input_window = window;
  g_scroll_x = 0.0;
  g_scroll_y = 0.0;
  if (window != NULL) {
    glfwSetScrollCallback(window, moonbit_glfw_scroll_callback);
    moonbit_glfw_platform_setup_window(window);
  }

  return window;
}

GLFWwindow* moonbit_glfw_create_hidden_window(int32_t width, int32_t height) {
  glfwWindowHint(0x00022001, 0);  // GLFW_CLIENT_API = GLFW_NO_API
  glfwWindowHint(0x00020003, 0);  // GLFW_RESIZABLE = GLFW_FALSE
  glfwWindowHint(0x00020004, 0);  // GLFW_VISIBLE = GLFW_FALSE

  GLFWwindow* window = glfwCreateWindow(width, height, "headless", NULL, NULL);
  // Reset hints to defaults for subsequent window creation
  glfwWindowHint(0x00020004, 1);  // GLFW_VISIBLE = GLFW_TRUE
  return window;
}
