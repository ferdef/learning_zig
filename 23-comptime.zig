const expect = @import("std").testing.expect;

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "comptime blocks" {
    const x = comptime fibonacci(10);
    const y = comptime blk: {
        break :blk fibonacci(10);
    };

    try expect(y == 55);
    try expect(x == 55);
}

test "branching on types" {
    const a = 5;
    const b: if (a < 10) f32 else i32 = 5;
    try expect(b == 5);
    try expect(@TypeOf(b) == f32);
}

fn Matrix(
    comptime T: type,
    comptime width: comptime_int,
    comptime height: comptime_int,
) type {
    return [height][width]T;
}

test "returning a type" {
    try expect(Matrix(f32, 4, 4) == [4][4]f32);
}

fn addSmallInts(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16)
            a + b
        else
            @compileError("ints too large"),
        else => @compileError("inly ints accepted"),
    };
}

test "typeinfo switch" {
    const x = addSmallInts(u16, 20, 30);
    try expect(@TypeOf(x) == u16);
    try expect(x == 50);
}
