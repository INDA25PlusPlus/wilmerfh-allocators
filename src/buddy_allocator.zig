const std = @import("std");

pub const BuddyAllocator = struct {
    buffer: []u8,

    pub fn init(buffer: []u8) BuddyAllocator {
        return BuddyAllocator{ .buffer = buffer };
    }

    fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {}

    fn free(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {}

    fn resize(
        ctx: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_len: usize,
        ret_addr: usize,
    ) bool {}

    fn remap(
        ctx: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_len: usize,
        ret_addr: usize,
    ) ?[*]u8 {}

    const vtable = std.mem.Allocator.VTable{
        .alloc = alloc,
        .free = free,
        .resize = resize,
        .remap = remap,
    };

    pub fn allocator(self: *BuddyAllocator) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &vtable };
    }
};
