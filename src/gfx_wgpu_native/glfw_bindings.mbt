// GLFW バインディング（ウィンドウ管理用）

///|
// 不透明ポインタ型
#external
type GLFWwindow

///|
// ===============================
// 構造体定義
// ===============================

///|
pub struct WindowSize {
  width : Int
  height : Int
}

///|
// ===============================
// C関数の宣言（extern "C"）
// ===============================

// GLFW 初期化
extern "C" fn glfwInit() -> Int = "glfwInit"

///|
extern "C" fn glfwTerminate() -> Unit = "glfwTerminate"

///|
// ウィンドウ作成（安全なラッパー経由）
#borrow(title)
extern "C" fn moonbit_glfw_create_window_safe(
  width : Int,
  height : Int,
  title : String,
) -> GLFWwindow = "moonbit_glfw_create_window_safe"

///|
extern "C" fn glfwDestroyWindow(window : GLFWwindow) -> Unit = "glfwDestroyWindow"

// イベント処理

///|
extern "C" fn glfwPollEvents() -> Unit = "glfwPollEvents"

///|
extern "C" fn glfwWindowShouldClose(window : GLFWwindow) -> Int = "glfwWindowShouldClose"

///|
extern "C" fn glfwSetWindowShouldClose(
  window : GLFWwindow,
  value : Int,
) -> Unit = "glfwSetWindowShouldClose"

///|
// SwapBuffers（バックバッファとフロントバッファを交換）
extern "C" fn glfwSwapBuffers(window : GLFWwindow) -> Unit = "glfwSwapBuffers"

///|
// ウィンドウサイズ取得（分割版）
extern "C" fn glfwGetWindowWidth(window : GLFWwindow) -> Int = "moonbit_glfw_get_window_width"

///|
extern "C" fn glfwGetWindowHeight(window : GLFWwindow) -> Int = "moonbit_glfw_get_window_height"

///|
// ===============================
// 高レベルラッパー関数
// ===============================

// GLFW 初期化
pub fn glfw_init() -> Bool {
  glfwInit() != 0
}

///|
pub fn terminate() -> Unit {
  glfwTerminate()
}

///|
// ウィンドウ作成（WebGPU 用に CLIENT_API を NO_API に設定）
pub fn create_window(width : Int, height : Int, title : String) -> GLFWwindow {
  // C スタブの安全なラッパー経由でウィンドウ作成
  // (ウィンドウヒント設定も含む)
  moonbit_glfw_create_window_safe(width, height, title)
}

///|
pub fn destroy_window(window : GLFWwindow) -> Unit {
  glfwDestroyWindow(window)
}

///|
pub fn poll_events() -> Unit {
  glfwPollEvents()
}

///|
pub fn window_should_close(window : GLFWwindow) -> Bool {
  glfwWindowShouldClose(window) != 0
}

///|
pub fn set_window_should_close(window : GLFWwindow, value : Bool) -> Unit {
  glfwSetWindowShouldClose(window, if value { 1 } else { 0 })
}

///|
pub fn swap_buffers(window : GLFWwindow) -> Unit {
  glfwSwapBuffers(window)
}

///|
pub fn get_window_size(window : GLFWwindow) -> WindowSize {
  // moonbit_glfw_get_window_size_struct(window)  // 構造体返却版（クラッシュ）
  // 代わりに分割版を使用
  { width: glfwGetWindowWidth(window), height: glfwGetWindowHeight(window) }
}

///|
pub fn get_window_width(window : GLFWwindow) -> Int {
  glfwGetWindowWidth(window)
}

///|
pub fn get_window_height(window : GLFWwindow) -> Int {
  glfwGetWindowHeight(window)
}
