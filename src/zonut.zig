const std = @import("std");
const writer = std.io.getStdOut().writer();
const PI: f32 = 3.14159;
const screen_width: f32 = 80;
const screen_height: f32 = 24;

const theta_spacing: f32 = 0.03;
const phi_spacing: f32 = 0.01;

pub fn main() !void {
    const R1: f32 = 1;
    const R2: f32 = 2;
    // distance from screen, min 5
    const K1: f32 = ((screen_width / 2) - 10);
    const K2: f32 = 5;
    // colorize the output
    const lum_chars: [12][]const u8 = .{ "\x1b[38;5;141m.\x1b[0m", "\x1b[38;5;135m,\x1b[0m", "\x1b[38;5;54m-\x1b[0m", "\x1b[38;5;55m~\x1b[0m", "\x1b[38;5;56m:\x1b[0m", "\x1b[38;5;57m;\x1b[0m", "\x1b[38;5;92m=\x1b[0m", "\x1b[38;5;93m!\x1b[0m", "\x1b[38;5;128m*\x1b[0m", "\x1b[38;5;129m#\x1b[0m", "\x1b[38;5;165m$\x1b[0m", "\x1b[38;5;201m@\x1b[0m" };
    try writer.print("{c}", .{lum_chars[0]});
    var A: f32 = 0;
    var B: f32 = 0;
    var out: [screen_height][screen_width][]const u8 = undefined;
    var zbuffer: [screen_height][screen_width]f32 = undefined;

    try writer.print("\x1b[2J", .{});

    while (true) {
        const sinA: f32 = @sin(A);
        const cosA: f32 = @cos(A);
        const sinB: f32 = @sin(B);
        const cosB: f32 = @cos(B);
        out = .{.{" "} ** screen_width} ** screen_height;
        zbuffer = .{.{0} ** screen_width} ** screen_height;
        var theta: f32 = 0;
        while (theta < 2 * PI) : (theta += theta_spacing) {
            const costheta: f32 = @cos(theta);
            const sintheta: f32 = @sin(theta);
            var phi: f32 = 0;
            while (phi < 2 * PI) : (phi += phi_spacing) {
                const cosphi: f32 = @cos(phi);
                const sinphi: f32 = @sin(phi);
                const circle_x: f32 = R2 + R1 * costheta;
                const circle_y: f32 = R1 * sintheta;
                const x: f32 = circle_x * (cosB * cosphi + sinA * sinB * sinphi) - circle_y * cosA * sinB;
                const y: f32 = circle_x * (sinB * cosphi - sinA * cosB * sinphi) + circle_y * cosA * cosB;
                const z: f32 = K2 + cosA * circle_x * sinphi + circle_y * sinA;
                const ooz: f32 = 1 / z;
                const xp: u32 = @intFromFloat((screen_width / 2) + K1 * ooz * x);
                const yp: u32 = @intFromFloat((screen_height / 2) - (K1 / 2) * ooz * y);
                const L: f32 = cosphi * costheta * sinB - cosA * costheta * sinphi - sinA * sintheta + cosB * (cosA * sintheta - costheta * sinA * sinphi);
                if (L > 0) {
                    if (ooz > zbuffer[yp][xp]) {
                        zbuffer[yp][xp] = ooz;
                        const luminance_index: u32 = @intFromFloat(L * 8);
                        out[yp][xp] = lum_chars[luminance_index];
                        // out[yp][xp] = ".,-~:;=!*#$@"[luminance_index];
                    }
                }
            }
        }
        try writer.print("\x1b[H", .{});
        for (out) |height| {
            for (height) |char| {
                try writer.print("{s}", .{char});
            }
            try writer.print("\n", .{});
        }
        std.time.sleep(16_000_000);
        A = if (A < 6.28) (A + 0.07) else 0;
        B = if (B < 6.28) (B + 0.03) else 0;
        try writer.print("donut.zig", .{});
    }
}
