const std = @import("std");

const StackAllocator = struct {
    pointer: usize = 0,
    buffer: []u8,

    pub fn init(buffer: []u8) StackAllocator {
        return StackAllocator{
            .pointer = 0,
            .buffer = buffer,
        };
    }

    pub fn alloc() ?[*]u8 {}
    pub fn free() void {}
    pub fn resize() bool {}
    pub fn remap() ?[*]u8 {}

    const vtable = std.mem.Allocator.VTable{
        .alloc = alloc,
        .free = free,
        .resize = resize,
        .remap = remap,
    };
    pub fn allocator(self: *StackAllocator) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &vtable };
    }
};
