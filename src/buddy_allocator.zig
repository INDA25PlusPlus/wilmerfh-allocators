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

    fn push(self: *BuddyAllocator, block: *Head) void {
        block.next = self.flists[block.level];
        block.prev = null;
        if (self.flists[block.level]) |first| {
            first.prev = block;
        }
        self.flists[block.level] = block;
    }

    fn remove(self: *BuddyAllocator, block: *Head) void {
        if (block.prev) |prev| {
            prev.next = block.next;
        } else {
            self.flists[block.level] = block.next;
        }
        if (block.next) |next| {
            next.prev = block.prev;
        }
    }

    fn find(self: *BuddyAllocator, idx: usize) ?*Head {
        if (idx >= LEVELS) return null;

        if (self.flists[idx]) |block| {
            self.remove(block);
            block.status = .taken;
            return block;
        }

        const block = self.find(idx + 1) orelse return null;
        const bud = split(block);
        self.push(bud);
        block.status = .taken;
        return block;
    }

    fn insert(self: *BuddyAllocator, block: *Head) void {
        if (block.level >= LEVELS - 1) {
            block.status = .free;
            self.push(block);
            return;
        }

        const bud = buddy(block);
        if (bud.status == .free and bud.level == block.level) {
            self.remove(bud);
            const pri = primary(block);
            pri.level += 1;
            self.insert(pri);
        } else {
            block.status = .free;
            self.push(block);
        }
    }

    pub fn alloc(self: *BuddyAllocator, size: usize) ?[*]u8 {
        if (size == 0) return null;
        const idx = getLevel(size) orelse return null;
        const block = self.find(idx) orelse return null;
        return hide(block);
    }

    pub fn free(self: *BuddyAllocator, memory: [*]u8) void {
        const block = magic(memory);
        self.insert(block);
    }
};
