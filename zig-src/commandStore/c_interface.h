#ifndef C_INTERFACE_H
#define C_INTERFACE_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

// Declares external functions for Redis operations, implemented in Zig

void externalSet(const unsigned char *key, size_t key_len, const unsigned char *value, size_t value_len);
unsigned char *externalGet(const unsigned char *key, size_t key_len);
bool externalDelete(const unsigned char *key, size_t key_len);
bool externalContains(const unsigned char *key, size_t key_len);
bool externalReplace(const unsigned char *key, size_t key_len, const unsigned char *new_value, size_t new_value_len);
size_t externalSize();
int64_t externalIncrement(const unsigned char *key, size_t key_len, int64_t amount);
int64_t externalDecrement(const unsigned char *key, size_t key_len, int64_t amount);

void externalMultiSet(const struct MultiSetItem *items, size_t item_count);
unsigned char **externalMultiGet(const unsigned char *keys[], const size_t key_lens[], size_t key_count);

// Struct definition for batch operations in multiSet
struct MultiSetItem {
    const unsigned char *key;
    size_t key_len;
    const unsigned char *value;
    size_t value_len;
};

#endif // C_INTERFACE_H
