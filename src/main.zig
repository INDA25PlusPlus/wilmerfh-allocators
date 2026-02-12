const std = @import("std");
const StackAllocator = @import("stack_allocator.zig").StackAllocator;
const BuddyAllocator = @import("buddy_allocator.zig").BuddyAllocator;

pub fn main() !void {
    var stack_buffer: [128]u8 = undefined;
    var stack = StackAllocator.init(stack_buffer[0..]);
    const allocator = stack.allocator();

    var message: std.ArrayList(u8) = .empty;
    defer message.deinit(allocator);

    try message.appendSlice(allocator, "hello, stack!");
    std.debug.print("{s}\n", .{message.items});

    var buddy_buffer: [4096]u8 align(4096) = undefined;
    var buddy = BuddyAllocator.init(&buddy_buffer);

    const memory = buddy.alloc(13) orelse return;
    defer buddy.free(memory);

    const msg = "hello, buddy!";
    @memcpy(memory[0..msg.len], msg);
    std.debug.print("{s}\n", .{memory[0..msg.len]});
}
