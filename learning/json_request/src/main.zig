const std = @import("std");
const http = @import("std").net.http;

const JsonData = struct {
    // Define aquí los campos de tu estructura JSON.
    name: []const u8,
    age: u8,
};

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var req = http.Request{
        .method = http.Method.GET,
        .uri = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/",
        .headers = &[_]http.Header{},
        .body = null,
    };

    var connection = try http.Client.connect(allocator, "sedeaplicaciones.minetur.gob.es", 80);
    defer connection.close();

    var response = try connection.sendRequest(&req);
    defer response.deinit();

    const reader = std.json.TokenReader.init(response.body.reader());
    const data = try parseJsonData(reader, allocator);

    std.debug.print("Received data: {}\n", .{data});
}

fn parseJsonData(reader: std.json.TokenReader, allocator: *std.mem.Allocator) !JsonData {
    var data = JsonData{
        .name = null,
        .age = 0,
    };

    while (try reader.next()) |token| {
        if (token == std.json.Token.ObjectStart) {
            // nothing to do
        } else if (token == std.json.Token.ObjectEnd) {
            break;
        } else if (token == std.json.Token.KeyValue) {
            const key = try reader.readKey();
            if (std.mem.eql(u8, key, "name")) {
                data.name = try reader.readString(allocator);
            } else if (std.mem.eql(u8, key, "age")) {
                data.age = try reader.readInt(u8);
            } else {
                try reader.skipAny();
            }
        } else {
            try reader.skipAny();
        }
    }

    return data;
}
