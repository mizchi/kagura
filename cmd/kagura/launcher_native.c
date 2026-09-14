#include <moonbit.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <process.h>
#else
#include <unistd.h>
#endif

static char *c_string(moonbit_bytes_t bytes) {
  size_t length = Moonbit_array_length(bytes);
  char *text = malloc(length + 1);
  if (!text) { fputs("kagura: out of memory\n", stderr); exit(1); }
  memcpy(text, bytes, length);
  text[length] = 0;
  return text;
}

// Only the native process/UTF-8 ABI lives in C. No shell string is evaluated.
void kagura_launch_node(moonbit_bytes_t script, moonbit_bytes_t payload) {
  char *source = c_string(script);
  char *data = c_string(payload);
  const char *args[] = {"node", "--input-type=module", "-e", source, "--", data, __FILE__, NULL};
#ifdef _WIN32
  intptr_t status = _spawnvp(_P_WAIT, "node", args);
  if (status != -1) exit((int)status);
#else
  execvp("node", (char *const *)args);
#endif
  perror("kagura: unable to start Node.js 24+");
  free(source);
  free(data);
  exit(127);
}
