const screen_w: i32 = 320;
const screen_h: i32 = 240;
const target_tps: i32 = 60;

const sky_fill: i32 = 0x87CEEB;
const ground_fill: i32 = 0x8B4513;
const bird_fill: i32 = 0xFFD700;

const ground_h: f64 = 20.0;
const bird_x: f64 = 60.0;
const bird_y: f64 = 120.0;
const bird_size: f64 = 12.0;

var heap_offset: usize = 8192;
var game_started: bool = false;

extern "kagura_host" fn log_i32_utf8(level: i32, ptr: [*]const u8, len: i32) i32;
extern "kagura_host" fn read_asset_len_i32_utf8(ptr: [*]const u8, len: i32) i32;
extern "kagura_host" fn read_asset_copy_i32_utf8(path_ptr: [*]const u8, path_len: i32, dst_ptr: [*]u8) i32;

fn writeI32(ptr: usize, value: i32) void {
    const out: *align(1) i32 = @ptrFromInt(ptr);
    out.* = value;
}

fn writeU32(ptr: usize, value: u32) void {
    const out: *align(1) u32 = @ptrFromInt(ptr);
    out.* = value;
}

fn writeF32(ptr: usize, value: f32) void {
    const out: *align(1) f32 = @ptrFromInt(ptr);
    out.* = value;
}

fn allocBytes(size: usize) usize {
    const ptr = heap_offset;
    heap_offset += size;
    return ptr;
}

fn writeBytes(dst: usize, src: []const u8) void {
    var i: usize = 0;
    while (i < src.len) : (i += 1) {
        const out: *u8 = @ptrFromInt(dst + i);
        out.* = src[i];
    }
}

fn hostLogInfo(message: []const u8) void {
    _ = log_i32_utf8(2, message.ptr, @intCast(message.len));
}

fn hostReadAsset(path: []const u8) ?[]const u8 {
    const len = read_asset_len_i32_utf8(path.ptr, @intCast(path.len));
    if (len < 0) return null;
    const dst = allocBytes(@intCast(len));
    const copied = read_asset_copy_i32_utf8(
        path.ptr,
        @intCast(path.len),
        @ptrFromInt(dst),
    );
    if (copied < 0) return null;
    return @as([*]const u8, @ptrFromInt(dst))[0..@intCast(copied)];
}

fn writeGuestConfigBytes(title: []const u8) i32 {
    const ptr = allocBytes(16 + title.len);
    writeI32(ptr, screen_w);
    writeI32(ptr + 4, screen_h);
    writeI32(ptr + 8, target_tps);
    writeI32(ptr + 12, @intCast(title.len));
    writeBytes(ptr + 16, title);
    return @intCast(ptr);
}

fn ndcX(x: f64, width: f64) f32 {
    return @floatCast((x / width) * 2.0 - 1.0);
}

fn ndcY(y: f64, height: f64) f32 {
    return @floatCast(1.0 - (y / height) * 2.0);
}

fn writeRectCommand(
    ptr: usize,
    x: f64,
    y: f64,
    w: f64,
    h: f64,
    fill: i32,
    alpha: i32,
) usize {
    const sw = @as(f64, @floatFromInt(screen_w));
    const sh = @as(f64, @floatFromInt(screen_h));
    const x0 = ndcX(x, sw);
    const y0 = ndcY(y, sh);
    const x1 = ndcX(x + w, sw);
    const y1 = ndcY(y + h, sh);

    writeI32(ptr, 4);
    writeI32(ptr + 4, 6);
    writeI32(ptr + 8, 0);
    writeI32(ptr + 12, (fill >> 16) & 0xFF);
    writeI32(ptr + 16, (fill >> 8) & 0xFF);
    writeI32(ptr + 20, fill & 0xFF);
    writeI32(ptr + 24, alpha);

    const vertices = [_]f32{
        x0, y0, 0.0, 0.0,
        x1, y0, 1.0, 0.0,
        x1, y1, 1.0, 1.0,
        x0, y1, 0.0, 1.0,
    };
    var vertex_offset: usize = 0;
    while (vertex_offset < vertices.len) : (vertex_offset += 1) {
        writeF32(ptr + 28 + vertex_offset * 4, vertices[vertex_offset]);
    }

    const idx_base = ptr + 28 + vertices.len * 4;
    const indices = [_]u32{ 0, 1, 2, 0, 2, 3 };
    var index_offset: usize = 0;
    while (index_offset < indices.len) : (index_offset += 1) {
        writeU32(idx_base + index_offset * 4, indices[index_offset]);
    }

    return idx_base + indices.len * 4;
}

fn hasPressedKey(ptr: usize, key_code: i32) bool {
    const key_count_ptr = ptr + 32;
    const key_count = @as(*align(1) i32, @ptrFromInt(key_count_ptr)).*;
    var i: i32 = 0;
    while (i < key_count) : (i += 1) {
        const key_ptr = ptr + 36 + @as(usize, @intCast(i)) * 4;
        const current = @as(*align(1) i32, @ptrFromInt(key_ptr)).*;
        if (current == key_code) return true;
    }
    return false;
}

export fn kagura_alloc(size: i32) callconv(.c) i32 {
    return @intCast(allocBytes(@intCast(size)));
}

export fn kagura_guest_init(_: i32, _: i32) callconv(.c) i32 {
    heap_offset = 8192;
    game_started = false;
    hostLogInfo("guest init: zig/flappy");
    if (hostReadAsset("/guest-title.txt")) |title| {
        hostLogInfo("guest asset: /guest-title.txt");
        return writeGuestConfigBytes(title);
    }
    return writeGuestConfigBytes("Flappy Bird (Zig)");
}

export fn kagura_guest_update(ptr: i32, _: i32) callconv(.c) i32 {
    const input_ptr: usize = @intCast(ptr);
    if (hasPressedKey(input_ptr, 32)) {
        game_started = true;
    }
    return 1;
}

export fn kagura_guest_render() callconv(.c) i32 {
    heap_offset = 8192;
    const header_ptr = allocBytes(4);
    writeI32(header_ptr, 3);

    var cursor = header_ptr + 4;
    cursor = writeRectCommand(cursor, 0.0, 0.0, 320.0, 240.0, sky_fill, 255);
    cursor = writeRectCommand(cursor, 0.0, 240.0 - ground_h, 320.0, ground_h, ground_fill, 255);
    _ = game_started;
    _ = writeRectCommand(cursor, bird_x, bird_y, bird_size, bird_size, bird_fill, 255);
    return @intCast(header_ptr);
}

export fn kagura_guest_snapshot_state() callconv(.c) i32 {
    return 0;
}

export fn kagura_guest_restore_state(_: i32, _: i32) callconv(.c) i32 {
    return 0;
}

export fn kagura_guest_shutdown() callconv(.c) void {}
