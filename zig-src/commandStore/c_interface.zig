const std = @import("std");
const storage_interface = @import("storage_interface.zig");

// Declare the global variable
var storage: ?storage_interface.StorageInterface = null;

// Initialize the storage variable
pub fn initStorage() !void {
    if (storage == null) {
        storage = try storage_interface.StorageInterface.init(std.heap.page_allocator);
    }
}

export fn externalSet(key: [*:0]const u8, key_len: usize, value: [*:0]const u8, value_len: usize) void {
    try initStorage();
    const k = key[0..key_len];
    const v = value[0..value_len];
    storage.set(k, v);
}

export fn externalGet(key: [*:0]const u8, key_len: usize) ?[*:0]u8 {
    try initStorage();
    return storage.get(key[0..key_len]);
}

export fn externalDelete(key: [*:0]const u8, key_len: usize) bool {
    try initStorage();
    return storage.delete(key[0..key_len]);
}

export fn externalContains(key: [*:0]const u8, key_len: usize) bool {
    try initStorage();
    return storage.contains(key[0..key_len]);
}

export fn externalReplace(key: [*:0]const u8, key_len: usize, new_value: [*:0]const u8, new_value_len: usize) bool {
    try initStorage();
    const k = key[0..key_len];
    const v = new_value[0..new_value_len];
    return storage.replace(k, v);
}

export fn externalSize() usize {
    try initStorage();
    return storage.size();
}

export fn externalIncrement(key: [*:0]const u8, key_len: usize, amount: i64) i64 {
    try initStorage();
    return storage.increment(key[0..key_len], amount);
}

export fn externalDecrement(key: [*:0]const u8, key_len: usize, amount: i64) i64 {
    try initStorage();
    return storage.decrement(key[0..key_len], amount);
}

export fn externalMultiSet(items: []struct { key: [*:0]const u8, key_len: usize, value: [*:0]const u8, value_len: usize }) void {
    try initStorage();
    var converted_items = []struct { key: []const u8, value: []const u8 }{};
    for (0.., items) |index, item| {
        converted_items[index].key = item.key[0..item.key_len];
        converted_items[index].value = item.value[0..item.value_len];
    }
    storage.multiSet(converted_items);
}

export fn externalMultiGet(keys: [][][*:0]const u8, keys_len: []usize) [][][*:0]u8 {
    try initStorage();
    var zig_keys = [][]const u8{};
    for (0.., keys) |index, key| {
        zig_keys[index] = key[0..keys_len[index]];
    }
    return storage.multiGet(zig_keys);
}
