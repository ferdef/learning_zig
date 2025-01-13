const expect = @import("std").testing.expect;

const Result = union {
    int: i64,
    float: f64,
    bool: bool,
};

test "simple union" {
    // this will fail
    var result = Result{ .int = 1234 };
    result.float = 12.34;
}

const Tag = enum { a, b, c };

const Tagged = union(Tag) { a: u8, b: f32, c: bool };

test "switch on tagged union" {
    // Here we make use of payload capturing again, to switch on the tag type of a union while also capturing the value it contains.
    // Here we use a pointer capture; captured values are immutable, but with the |*value| syntax, we can capture a pointer to the values instead of the values themselves.
    // This allows us to use dereferencing to mutate the original value.
    var value = Tagged{ .b = 1.5 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*b| b.* = !b.*,
    }
    try expect(value.b == 3);
}

const Tagged2 = union(enum) { a: u8, b: f32, c: bool };
const Tagged3 = union(enum) { a: u8, b: f32, c: bool, none };
