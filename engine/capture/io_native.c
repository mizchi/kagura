#include <moonbit.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

static unsigned char *kgr_capture_buffer;

/* The runner sets an absolute path per child process, avoiding shared config files. */
MOONBIT_FFI_EXPORT int kgr_capture_load(const unsigned char *path, int length, int config) {
  free(kgr_capture_buffer);
  kgr_capture_buffer = NULL;
  char *name = malloc((size_t)length + 1);
  if (!name) return -2;
  memcpy(name, path, (size_t)length);
  name[length] = 0;
  const char *override = config ? getenv("KAGURA_CAPTURE_CONFIG") : NULL;
  FILE *file = fopen(override ? override : name, "rb");
  free(name);
  if (!file) return (!override && errno == ENOENT) ? -1 : -2;
  if (fseek(file, 0, SEEK_END) != 0) { fclose(file); return -2; }
  long size = ftell(file);
  if (size < 0 || size > 16 * 1024 * 1024 || fseek(file, 0, SEEK_SET) != 0) {
    fclose(file); return -2;
  }
  kgr_capture_buffer = malloc((size_t)size + 1);
  if (!kgr_capture_buffer) { fclose(file); return -2; }
  size_t read_size = fread(kgr_capture_buffer, 1, (size_t)size, file);
  int close_status = fclose(file);
  if (read_size != (size_t)size || close_status != 0) {
    free(kgr_capture_buffer); kgr_capture_buffer = NULL; return -2;
  }
  return (int)size;
}
MOONBIT_FFI_EXPORT int kgr_capture_byte(int offset) { return kgr_capture_buffer[offset]; }
MOONBIT_FFI_EXPORT void kgr_capture_release(void) {
  free(kgr_capture_buffer); kgr_capture_buffer = NULL;
}
MOONBIT_FFI_EXPORT int kgr_capture_write(const unsigned char *path, int length,
                                       const unsigned char *data, int size) {
  char *name = malloc((size_t)length + 1);
  if (!name) return 0;
  memcpy(name, path, (size_t)length); name[length] = 0;
  FILE *file = fopen(name, "wb"); free(name);
  if (!file) return 0;
  size_t written = fwrite(data, 1, (size_t)size, file);
  int closed = fclose(file);
  return written == (size_t)size && closed == 0;
}
