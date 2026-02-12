pub const BuddyAllocator = struct {
    const MIN = 5;
    const LEVELS = 8;
    const PAGE = 1 << (MIN + LEVELS - 1);

    const Status = enum { free, taken };

    const Head = struct {
        status: Status,
        level: u8,
        next: ?*Head = null,
        prev: ?*Head = null,
    };

    pub fn alloc(self: *BuddyAllocator, size: usize) ?[*]u8 {
        _ = self;
        _ = size;
        return null;
    }

    pub fn free(self: *BuddyAllocator, memory: [*]u8) void {
        _ = self;
        _ = memory;
    }
};
