const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

const server = @cImport({
    @cInclude("server.c");
});

export fn processCommand() i32 {
    const client: server.client = server.client{};
    const item = server.processCommand(client);
    return item;
}

pub fn main() !void {
    const z: i32 = processCommand();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("The process output{d}\n", .{z});
    try bw.flush();

    // const ret = c.printf("hello from c world!\n");
    // std.debug.print("C call return value: {d}\n", .{ret});

    // const buf = c.malloc(10);
    // if (buf == null) {
    //     std.debug.print("ERROR while allocating memory!\n", .{});
    //     return;
    // }
    // std.debug.print("buf address: {any}\n", .{buf});
    // c.free(buf);
}

// test "basic add functionality" {
//     try testing.expect(add(3, 7) == 10);
// }
