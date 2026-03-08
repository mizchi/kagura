// Minimal linear algebra for CMA-ES: symmetric eigendecomposition (Jacobi method)
// Operates on flat Array[Double] in row-major order

// Symmetric matrix eigendecomposition using Jacobi rotations
// Input: n x n symmetric matrix (flat row-major)
// Output: (eigenvalues, eigenvectors as flat n*n row-major)
pub fn eigen_symmetric(
  mat : Array[Double],
  n : Int,
) -> (Array[Double], Array[Double]) {
  // Copy matrix
  let a = mat.copy()
  // Initialize eigenvectors as identity
  let v : Array[Double] = Array::make(n * n, 0.0)
  for i = 0; i < n; i = i + 1 {
    v[i * n + i] = 1.0
  }
  let max_iter = 100 * n * n
  for _iter = 0; _iter < max_iter; _iter = _iter + 1 {
    // Find largest off-diagonal element
    let mut max_val = 0.0
    let mut p = 0
    let mut q = 1
    for i = 0; i < n; i = i + 1 {
      for j = i + 1; j < n; j = j + 1 {
        let abs_val = a[i * n + j].abs()
        if abs_val > max_val {
          max_val = abs_val
          p = i
          q = j
        }
      }
    }
    // Convergence check
    if max_val < 1.0e-10 {
      break
    }
    // Compute rotation
    let app = a[p * n + p]
    let aqq = a[q * n + q]
    let apq = a[p * n + q]
    let theta = if (app - aqq).abs() < 1.0e-15 {
      @math.PI / 4.0
    } else {
      0.5 * @math.atan2(2.0 * apq, app - aqq)
    }
    let cos_t = @math.cos(theta)
    let sin_t = @math.sin(theta)
    // Apply rotation to A: A' = G^T * A * G
    for i = 0; i < n; i = i + 1 {
      if i != p && i != q {
        let aip = a[i * n + p]
        let aiq = a[i * n + q]
        a[i * n + p] = cos_t * aip + sin_t * aiq
        a[i * n + q] = -sin_t * aip + cos_t * aiq
        a[p * n + i] = a[i * n + p]
        a[q * n + i] = a[i * n + q]
      }
    }
    a[p * n + p] = cos_t * cos_t * app + 2.0 * sin_t * cos_t * apq + sin_t * sin_t * aqq
    a[q * n + q] = sin_t * sin_t * app - 2.0 * sin_t * cos_t * apq + cos_t * cos_t * aqq
    a[p * n + q] = 0.0
    a[q * n + p] = 0.0
    // Update eigenvectors
    for i = 0; i < n; i = i + 1 {
      let vip = v[i * n + p]
      let viq = v[i * n + q]
      v[i * n + p] = cos_t * vip + sin_t * viq
      v[i * n + q] = -sin_t * vip + cos_t * viq
    }
  }
  // Extract eigenvalues from diagonal
  let eigenvalues : Array[Double] = Array::make(n, 0.0)
  for i = 0; i < n; i = i + 1 {
    eigenvalues[i] = a[i * n + i]
  }
  (eigenvalues, v)
}
