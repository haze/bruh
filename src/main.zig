const std = @import("std");
const cwd = @import("cwd.zig");
const tf = @import("time_format.zig");
pub const lib_log = std.log.scoped(.bruh);

pub const Config = struct {
    dir_cutoff_len: ?usize = cwd.DEFAULT_DIR_CUTOFF_LEN,
    early_dir_cutoff_len: ?usize = cwd.DEFAULT_EARLY_DIR_CUTOFF_LEN,
    home_dir: ?[]const u8 = null,

    fn fromEnv(env_map: std.BufMap) !Config {
        var conf = Config{};
        if (env_map.get(cwd.BRUH_DIR_CUTOFF_ENV_KEY)) |cutoff_len| {
            conf.dir_cutoff_len = try std.fmt.parseUnsigned(usize, cutoff_len, 10);
        }
        if (env_map.get(cwd.BRUH_EARLY_DIR_CUTOFF_ENV_KEY)) |cutoff_len| {
            conf.early_dir_cutoff_len = try std.fmt.parseUnsigned(usize, cutoff_len, 10);
        }
        if (env_map.get("HOME")) |home_dir| {
            conf.home_dir = home_dir;
        }
        return conf;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = &arena.allocator;

    var env_map = try std.process.getEnvMap(allocator);

    var config = try Config.fromEnv(env_map);

    var arg_iter = std.process.args();
    // skip executable
    _ = arg_iter.skip();

    if (arg_iter.next(allocator)) |maybe_arg| {
        const arg = try maybe_arg;
        if (std.mem.eql(u8, arg, "cwd")) {
            cwd.printCollapsedWorkingDir(allocator, config);
        } else if (std.mem.eql(u8, arg, "tf")) {
            if (arg_iter.next(allocator)) |maybe_seconds| {
                const seconds_arg = try maybe_seconds;
                tf.printFormattedTime(try std.fmt.parseFloat(f64, seconds_arg));
            } else {
                lib_log.err("No seconds given to time_format", .{});
            }
        } else lib_log.err("Invalid subcommand '{s}'", .{arg});
    }
}
