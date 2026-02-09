const std = @import("std");

const StackAllocator = struct {
    var pointer: usize = 0;

    pub fn alloc() void {}
    pub fn free() void {}
    pub fn resize() void {}
    pub fn remap() void {}

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
