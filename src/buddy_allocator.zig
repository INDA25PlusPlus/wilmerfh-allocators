const std = @import("std");

pub const MemoryTree = struct {
    pub const State = enum { free, split, used };
    buffer: []u8,
    state: State = .free,
    leftChild: ?MemoryTree,
    rightChild: ?MemoryTree,

    fn init(buffer: []u8, min_block_size: u8) ?MemoryTree {
        if (buffer.len < min_block_size) {
            return null;
        }

        if (buffer.len < min_block_size * 2) {
            return MemoryTree{
                .buffer = buffer,
                .state = .free,
                .leftChild = null,
                .rightChild = null,
            };
        }

        const mid = buffer.len / 2;
        const left_half = buffer[0..mid];
        const right_half = buffer[mid..];

        return MemoryTree{
            .buffer = buffer,
            .state = .free,
            .leftChild = init(left_half, min_block_size),
            .rightchild = init(right_half, min_block_size),
        };
    }
};

pub const BuddyAllocator = struct {
    buffer: []u8,
    min_block_size: usize,
    root: MemoryTree,

    fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        _ = ctx;
        _ = len;
        _ = alignment;
        _ = ret_addr;

        return null;
    }

    fn free(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
        _ = ctx;
        _ = memory;
        _ = alignment;
        _ = ret_addr;
    }

    fn resize(
        ctx: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_len: usize,
        ret_addr: usize,
    ) bool {
        _ = ctx;
        _ = memory;
        _ = alignment;
        _ = new_len;
        _ = ret_addr;
        return false;
    }

    fn remap(
        ctx: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_len: usize,
        ret_addr: usize,
    ) ?[*]u8 {
        _ = ctx;
        _ = memory;
        _ = alignment;
        _ = new_len;
        _ = ret_addr;
        return null;
    }

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
