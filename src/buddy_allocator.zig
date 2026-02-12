pub const BuddyAllocator = struct {
    const MIN = 5;
    const LEVELS = 8;
    const Status = enum { free, taken };

    const Head = struct {
        status: Status,
        level: u6,
        next: ?*Head = null,
        prev: ?*Head = null,
    };

    flists: [LEVELS]?*Head = .{null} ** LEVELS,

    pub fn init(buffer: [*]u8) BuddyAllocator {
        var self = BuddyAllocator{};
        const block: *Head = @ptrCast(@alignCast(buffer));
        block.* = .{ .status = .free, .level = LEVELS - 1 };
        self.flists[LEVELS - 1] = block;
        return self;
    }

    fn blockSize(level: u6) usize {
        return @as(usize, 1) << (level + MIN);
    }

    fn buddy(block: *Head) *Head {
        return @ptrFromInt(@intFromPtr(block) ^ blockSize(block.level));
    }

    fn split(block: *Head) *Head {
        block.level -= 1;
        const bud: *Head = @ptrFromInt(@intFromPtr(block) + blockSize(block.level));
        bud.* = .{ .status = .free, .level = block.level };
        return bud;
    }

    fn primary(block: *Head) *Head {
        const mask = ~(blockSize(block.level) * 2 - 1);
        return @ptrFromInt(@intFromPtr(block) & mask);
    }

    fn hide(block: *Head) [*]u8 {
        return @ptrFromInt(@intFromPtr(block) + @sizeOf(Head));
    }

    fn magic(memory: [*]u8) *Head {
        return @ptrFromInt(@intFromPtr(memory) - @sizeOf(Head));
    }

    fn getLevel(req: usize) ?usize {
        var i: usize = 0;
        var size: usize = blockSize(0);
        const total = req + @sizeOf(Head);
        while (total > size) {
            size *= 2;
            i += 1;
        }
        if (i >= LEVELS) return null;
        return i;
    }

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
