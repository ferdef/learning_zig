const std = @import("std");

const Error = error{
    AllocatorError,
    OtherError,
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("Hello World!\n", .{});

    try measure_execution("Page allocation", page_allocator_test);
    try measure_execution("Fixed Buffer allocation", fixed_buffer_allocator_test);
}

fn page_allocator_test() !void {
    const allocator = std.heap.page_allocator;
    const buffer_size = std.mem.page_size / 1_000;
    std.debug.print("Buffer size: {} - Page size: {}\n", .{ buffer_size, std.mem.page_size });
    var counter: u16 = 0;
    while (counter < 1_000) : (counter += 1) {
        const page = try allocator.alloc(u8, buffer_size);
        allocator.free(page);
    }
}

fn fixed_buffer_allocator_test() !void {
    var buffer: [4096]u8 = undefined;

    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const buffer_size = std.mem.page_size / 1_000;
    std.debug.print("Buffer size: {} - Page size: {}\n", .{ buffer_size, buffer.len });
    var counter: u16 = 0;
    while (counter < 1_000) : (counter += 1) {
        const page = try allocator.alloc(u8, buffer_size);
        allocator.free(page);
    }
}

fn measure_execution(name: []const u8, func: anytype) !void {
    const start = std.time.nanoTimestamp();
    const result = func();
    const end = std.time.nanoTimestamp();
    const elapsed = end - start;
    std.debug.print("Function {s} executed in {d} ns\n", .{ name, elapsed });
    return result;
}
