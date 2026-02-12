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
            .rightChild = init(right_half, min_block_size),
        };
    }
};

pub const BuddyAllocator = struct {
    buffer: []u8,
    min_block_size: usize,
    root: MemoryTree,

    pub fn alloc(self: *BuddyAllocator, len: usize) ?[*]u8 {
        _ = self;
        _ = len;
        return null;
    }

    pub fn free(self: *BuddyAllocator, memory: [*]u8) void {
        _ = self;
        _ = memory;
    }
};
