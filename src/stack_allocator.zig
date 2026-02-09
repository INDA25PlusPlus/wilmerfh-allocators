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

    pub fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, _: usize) ?[*]u8 {
        const self: *StackAllocator = @ptrCast(@alignCast(ctx));

        const absPointer = @intFromPtr(self.buffer.ptr) + self.pointer;
        const memStart = alignment.forward(absPointer);
        const alignmentOffset = memStart - absPointer;

        const requiredMemory = len + alignmentOffset;
        const freeMemory = self.buffer.len - self.pointer;
        if (requiredMemory > freeMemory) {
            return null;
        }

        self.pointer += len + alignmentOffset;
        return @ptrFromInt(memStart);
    }

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
