const std = @import("std");
const StackAllocator = @import("stack_allocator.zig").StackAllocator;

pub fn main() !void {
    var buffer: [128]u8 = undefined;
    var stack = StackAllocator.init(buffer[0..]);
    const allocator = stack.allocator();

    var message: std.ArrayList(u8) = .empty;
    defer message.deinit(allocator);

    try message.appendSlice(allocator, "hello, stack!");
    std.debug.print("{s}\n", .{message.items});
}
