const std = @import("std");
const os = @import("builtin").os.tag;
const mem = std.mem;

fn readAliasFile(allocator: *mem.Allocator, home_dir: ?[]const u8) !std.StringHashMap([]const u8) {
    var map = std.StringHashMap([]const u8).init(allocator);
    if (home_dir) |home| {
        const home_dir_handle = try std.fs.cwd().openDir(home, .{});
        const alias_file = try home_dir_handle.openFile(".bruh_aliases", .{});
        var reader = alias_file.reader();
        const alias_file_contents = try reader.readAllAlloc(allocator, (try alias_file.stat()).size);

        var tok_iter = mem.tokenize(alias_file_contents, "\n");
        while (tok_iter.next()) |line| {
            if (mem.lastIndexOfScalar(u8, line, ':')) |split_idx| {
                try map.put(line[0..split_idx], line[split_idx + 1 .. line.len]);
            } else {
                if (mem.lastIndexOfScalar(u8, line, '/')) |slash_idx| {
                    try map.put(line, line[slash_idx + 1 .. line.len]);
                }
            }
        }
    }
    return map;
}

const alias_highlight = "%F{blue}";
const reset_code = "%F{fb_default_code}";

fn shorten(allocator: *mem.Allocator, input: []const u8) ![]const u8 {
    const envMap = try std.process.getEnvMap(allocator);
    var buf = try std.ArrayList(u8).initCapacity(allocator, input.len);
    var home: ?[]const u8 = null;
    var start: usize = 0;

    if (envMap.get("HOME")) |captured_home| { // posix only
        home = captured_home;
        if (mem.startsWith(u8, input, captured_home)) {
            try buf.appendSlice("~/");
            start += captured_home.len;
        } else {
            try buf.append('/');
        }
    }

    var alias_map = readAliasFile(allocator, home) catch |e| null;
    if (alias_map) |map| {
        var iter = map.iterator();
        while (iter.next()) |entry| {
            if (mem.startsWith(u8, input, entry.key)) {
                start += entry.key.len;
                try buf.appendSlice(alias_highlight);
                try buf.appendSlice(entry.value);
                try buf.appendSlice(reset_code);
                try buf.append('/');
                break;
            }
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

    if (alias_map) |*map| {
        map.deinit();
    }

    return buf.toOwnedSlice();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;
    const out = std.io.getStdOut().outStream();
    const cwd = std.process.getCwdAlloc(allocator) catch |e| {
        try out.print("? {}\n", .{e});
        return;
    };
    try out.print("{}\n", .{try shorten(allocator, cwd)});
}
