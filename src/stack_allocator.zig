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

    pub fn free(ctx: *anyopaque, memory: []u8, _: std.mem.Alignment, _: usize) void {
        // TODO: Handle alignment issues
        // If the allocations alignment caused an offset to be inserted before
        // this memory block, that offset memory won't be freed

        const self: *StackAllocator = @ptrCast(@alignCast(ctx));
        self.pointer -= memory.len;
    }

    pub fn resize(
        ctx: *anyopaque,
        memory: []u8,
        _: std.mem.Alignment,
        new_len: usize,
        _: usize,
    ) bool {
        const self: *StackAllocator = @ptrCast(@alignCast(ctx));

        const base = @intFromPtr(self.buffer.ptr);
        const memStart = @intFromPtr(memory.ptr);
        const memEnd = memStart + memory.len;
        const top = base + self.pointer;

        if (memEnd != top) return false;

        const startOffset = memStart - base;
        const newTop = startOffset + new_len;
        if (newTop > self.buffer.len) return false;

        self.pointer = newTop;
        return true;
    }

    pub fn remap(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        const self: *StackAllocator = @ptrCast(@alignCast(ctx));

        if (self.resize(ctx, memory, alignment, new_len, ret_addr)) {
            return memory.ptr;
        }
        return null;
    }

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
