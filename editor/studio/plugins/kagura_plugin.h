#ifndef KAGURA_PANE_PLUGIN_V1_H
#define KAGURA_PANE_PLUGIN_V1_H
#include <stdint.h>
/* wasm32 exports. The module must also export linear `memory`.
 * Strings are UTF-8 JSON, lengths are bytes, each message is <= 4 MiB.
 * Input and result buffers must not overlap; neither is NUL-terminated.
 * Host copies the result before freeing it, then frees input. No host imports.
 */
uint32_t kagura_alloc(uint32_t length);
void kagura_free(uint32_t pointer, uint32_t length);
uint32_t kagura_manifest(void);
uint32_t kagura_invoke(uint32_t request_pointer, uint32_t request_length);
uint32_t kagura_result_len(void);
#endif
