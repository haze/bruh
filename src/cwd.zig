const std = @import("std");
const bruh = @import("main.zig");

/// Any paths longer than this variable will be cut off
pub const DEFAULT_DIR_CUTOFF_LEN: usize = 5;
pub const DEFAULT_EARLY_DIR_CUTOFF_LEN: usize = 3;
pub const BRUH_DIR_CUTOFF_ENV_KEY = "BRUH_DIR_CUTOFF_LEN";
pub const BRUH_EARLY_DIR_CUTOFF_ENV_KEY = "BRUH_EARLY_DIR_CUTOFF_LEN";
pub const SEPARATING_CHARS = "-_ ";

fn createCollapsedWorkingDir(allocator: *std.mem.Allocator, config: bruh.Config) ![]const u8 {
    var in_home_dir = false;
    var current_working_dir = try std.process.getCwdAlloc(allocator);
    if (config.home_dir) |home_dir| {
        if (std.mem.startsWith(u8, current_working_dir, home_dir)) {
            in_home_dir = true;
            current_working_dir = current_working_dir[home_dir.len..];
        }
    }
    var new_working_dir = try std.ArrayList(u8).initCapacity(allocator, current_working_dir.len);
    if (in_home_dir) {
        try new_working_dir.append('~');
        try new_working_dir.append(std.fs.path.sep);
    } else try new_working_dir.append('/');
    // TODO(haze): this is kinda naive
    const num_paths: usize = std.mem.count(u8, current_working_dir, std.fs.path.sep_str);
    var path_iterator = std.mem.tokenize(u8, current_working_dir, std.fs.path.sep_str);
    var path_idx: usize = 0;
    while (path_iterator.next()) |path_segment| {
        try appendPathHelper(&new_working_dir, path_idx, num_paths, path_iterator, config, path_segment);
        path_idx += 1;
    }
    return new_working_dir.toOwnedSlice();
}

fn appendElipses(buf: *std.ArrayList(u8)) !void {
    if (@import("builtin").os.tag == .windows)
        try buf.appendSlice("...")
    else
        try buf.appendSlice("…");
}

fn appendPathHelper(buf: *std.ArrayList(u8), path_idx: usize, total_num_paths: usize, path_iterator: std.mem.TokenIterator(u8), config: bruh.Config, path_segment: []const u8) !void {
    const is_last_path = path_iterator.rest().len == 0;
    var print_without_truncating = true;
    if (!is_last_path) {
        var is_early_cutoff = path_idx >= (total_num_paths / 2);
        var segment_head: usize = 0;
        // how many chars can we add before we need to shorten?
        var count: usize = 0;
        while (segment_head < path_segment.len) : (segment_head += 1) {
            if (config.early_dir_cutoff_len) |cutoff_len| {
                if (count > cutoff_len) {
                    if (is_early_cutoff) {
                        try buf.appendSlice(path_segment[0..count]);
                        try appendElipses(buf);
                    } else try buf.append(path_segment[0]);
                    print_without_truncating = false;
                    break;
                }
            }
            // if we find a separating char at our head, reset the count
            if (std.mem.indexOfScalar(u8, SEPARATING_CHARS, path_segment[segment_head]) != null) {
                count = 0;
                continue;
            }
            count += 1;
        }
    }
    if (print_without_truncating)
        try buf.appendSlice(path_segment);
    if (!is_last_path)
        try buf.append(std.fs.path.sep);
}

pub fn printCollapsedWorkingDir(allocator: *std.mem.Allocator, config: bruh.Config) void {
    const stdOut = std.io.getStdOut().writer();
    const shortened_cwd = createCollapsedWorkingDir(allocator, config) catch |shortened_cwd_err| {
        stdOut.print("ERR({s})\n", .{@errorName(shortened_cwd_err)}) catch |stdout_err| {
            bruh.lib_log.err("Failed to write to stdout: {s}", .{@errorName(stdout_err)});
        };
        return;
    };
    stdOut.print("{s}\n", .{shortened_cwd}) catch |stdout_err_prime| {
        bruh.lib_log.err("Failed to write to stdout: {s}", .{@errorName(stdout_err_prime)});
    };
}
