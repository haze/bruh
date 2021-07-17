// This file is responsible for creaeting nice looking time formats
const std = @import("std");
const bruh = @import("main.zig");

// Unsigned Duration type, can only be positive
// 5 seconds - 1 day = 0 nanos
const Duration = struct {
    const Unit = enum {
        nanos,
        micros,
        millis,
        seconds,
        minutes,
        hours,
        days,

        fn qualifier(self: Unit) []const u8 {
            return switch (self) {
                .nanos => "ns",
                .micros => "µs",
                .millis => "ms",
                .seconds => "s",
                .minutes => "m",
                .hours => "hr",
                .days => "d",
            };
        }

        fn toNanos(self: Unit, scalar: f64) f64 {
            return switch (self) {
                .nanos => scalar,
                .micros => scalar * std.time.ns_per_us,
                .millis => scalar * std.time.ns_per_ms,
                .seconds => scalar * std.time.ns_per_s,
                .minutes => scalar * std.time.ns_per_min,
                .hours => scalar * std.time.ns_per_hour,
                .days => scalar * std.time.ns_per_day,
            };
        }
    };
    ns: f64,
    largest_unit: Unit,

    fn from(unit: Unit, scalar: f64) Duration {
        var dur: Duration = undefined;
        dur.ns = unit.toNanos(scalar);
        dur.largest_unit = dur.getLargestUnit();
        return dur;
    }

    fn getLargestUnit(self: Duration) Unit {
        if (self.days() >= 1) {
            return .days;
        } else if (self.hours() >= 1) {
            return .hours;
        } else if (self.minutes() >= 1) {
            return .minutes;
        } else if (self.seconds() >= 1) {
            return .seconds;
        } else if (self.millis() >= 1) {
            return .millis;
        } else if (self.micros() >= 1) {
            return .micros;
        } else {
            return .nanos;
        }
    }

    fn nanos(self: Duration) f64 {
        return self.ns;
    }

    fn micros(self: Duration) f64 {
        return self.nanos() / std.time.ns_per_us;
    }

    fn millis(self: Duration) f64 {
        return self.nanos() / std.time.ns_per_ms;
    }

    fn seconds(self: Duration) f64 {
        return self.nanos() / std.time.ns_per_s;
    }

    fn minutes(self: Duration) f64 {
        return self.nanos() / std.time.ns_per_min;
    }

    fn hours(self: Duration) f64 {
        return self.nanos() / std.time.ns_per_hour;
    }

    fn days(self: Duration) f64 {
        return self.nanos() / std.time.ns_per_day;
    }

    fn as(self: Duration, unit: Unit) f64 {
        return switch (unit) {
            .nanos => self.ns,
            .millis => self.millis(),
            .days => self.days(),
            .hours => self.hours(),
            .minutes => self.minutes(),
            .seconds => self.seconds(),
            .micros => self.micros(),
        };
    }

    pub fn format(
        self: Duration,
        comptime fmt: []const u8,
        _: std.fmt.FormatOptions,
        out_stream: anytype,
    ) !void {
        _ = fmt;
        // if it has a fractional part, print with up to 2 places of precision
        if (std.math.modf(self.as(self.largest_unit)).fpart > 0) {
            // if we are seconds and above, print with more precision (we only want 2 for millis and below)
            if (@enumToInt(self.largest_unit) > @enumToInt(Unit.seconds)) {
                try std.fmt.format(out_stream, "{d:.2}{s}", .{ self.as(self.largest_unit), Unit.qualifier(self.largest_unit) });
            } else {
                try std.fmt.format(out_stream, "{d:.2}{s}", .{ self.as(self.largest_unit), Unit.qualifier(self.largest_unit) });
            }
        } else {
            // otherwise, print with none
            try std.fmt.format(out_stream, "{d}{s}", .{ self.as(self.largest_unit), Unit.qualifier(self.largest_unit) });
        }
    }
};

pub fn printFormattedTime(seconds: f64) void {
    var stdout = std.io.getStdOut().writer();
    stdout.print("{}\n", .{Duration.from(.seconds, seconds)}) catch |stdout_err| {
        bruh.lib_log.err("Failed to print calculated formatted time: {s}", .{@errorName(stdout_err)});
    };
}
