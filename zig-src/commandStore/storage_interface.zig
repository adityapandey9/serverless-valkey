// StorageInterface.zig
const std = @import("std");

pub const StorageInterface = struct {
    storage: std.AutoHashMap([]const u8, []u8),

    // Initialize storage
    pub fn init(allocator: std.mem.Allocator) !StorageInterface {
        return StorageInterface{
            .storage = try std.AutoHashMap([]const u8, []u8).init(allocator),
        };
    }

    // Set or update a value associated with a key
    pub fn set(self: *StorageInterface, key: []const u8, value: []const u8) void {
        self.storage.put(key, value);
    }

    // Get the value associated with a key, returns null if the key doesn't exist
    pub fn get(self: *StorageInterface, key: []const u8) ?[]u8 {
        return self.storage.get(key);
    }

    // Delete a key-value pair, returns true if the key was found and deleted
    pub fn delete(self: *StorageInterface, key: []const u8) bool {
        return self.storage.remove(key) != null;
    }

    // Check if a key exists in the storage
    pub fn contains(self: *StorageInterface, key: []const u8) bool {
        return self.storage.get(key) != null;
    }

    // Replace value if key exists, returns true if replaced, false if key was not present
    pub fn replace(self: *StorageInterface, key: []const u8, new_value: []const u8) bool {
        if (self.contains(key)) {
            self.set(key, new_value);
            return true;
        }
        return false;
    }

    // Get the count of stored entries
    pub fn size(self: *StorageInterface) usize {
        return self.storage.count();
    }

    // Atomic increment for integer values
    pub fn increment(self: *StorageInterface, key: []const u8, amount: i64) !i64 {
        const current_value = self.storage.get(key) orelse return amount;
        var parsed_value = try std.fmt.parseInt(i64, current_value, 10);
        parsed_value += amount;
        const new_value = try std.fmt.allocPrint(std.testing.allocator, "{}", .{parsed_value});
        self.set(key, new_value);
        return parsed_value;
    }

    // Atomic decrement for integer values
    pub fn decrement(self: *StorageInterface, key: []const u8, amount: i64) !i64 {
        return self.increment(key, -amount);
    }

    // Batch set for multiple key-value pairs
    pub fn multiSet(self: *StorageInterface, items: []const struct { key: []const u8, value: []const u8 }) void {
        for (items) |item| {
            self.set(item.key, item.value);
        }
    }

    // Batch get for multiple keys
    pub fn multiGet(self: *StorageInterface, keys: [][]const u8) []?[]u8 {
        var values: []?[]u8 = undefined;
        values = try std.mem.Allocator.allocate([]?[]u8, self.storage.allocator, keys.len);
        for (0.., keys) |index, key| {
            values[index] = self.get(key);
        }
        return values;
    }
};
