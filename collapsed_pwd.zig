const std = @import("std");
const os = @import("builtin").os.tag;
const mem = std.mem;

fn shorten(allocator: *mem.Allocator, input: []const u8) ![]const u8 {
    const envMap = try std.process.getEnvMap(allocator);
    var buf = try std.ArrayList(u8).initCapacity(allocator, input.len);
    var start: usize = 0;
    if (envMap.get("HOME")) |home| { // posix only
        if (mem.startsWith(u8, input, home)) {
            try buf.appendSlice("~/");
            start = home.len;
        } else {
            try buf.append('/');
        }
    }

    var it = mem.tokenize(input[start..], &[_]u8{std.fs.path.sep});
    const cutOffLength = if (os == .windows) 5 else 4;
    while (it.next()) |part| {
        if (it.index < (it.buffer.len - it.delimiter_bytes.len)) {
            if (part.len > cutOffLength) {
                try buf.appendSlice(part[0..cutOffLength]);
                if (os == .windows) {
                    try buf.appendSlice("...");
                } else try buf.appendSlice("…");
            } else {
                try buf.appendSlice(part);
            }
            try buf.append(std.fs.path.sep);
        } else {
            try buf.appendSlice(part);
        }
    }
    return buf.toOwnedSlice();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;
    const out = std.io.getStdOut().outStream();
    const cwd = std.process.getCwdAlloc(allocator) catch |e| {
        try out.print("? {}\n", .{e});
        return;
    };
    try out.print("{}\n", .{ try shorten(allocator, cwd) });
}
