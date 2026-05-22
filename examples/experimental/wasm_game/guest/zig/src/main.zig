const screen_w: i32 = 320;
const screen_h: i32 = 240;
const target_tps: i32 = 60;

const BIRD_X: f64 = 60.0;
const BIRD_SIZE: f64 = 12.0;
const GRAVITY: f64 = 0.25;
const JUMP_VELOCITY: f64 = -4.5;
const PIPE_WIDTH: f64 = 36.0;
const PIPE_GAP: f64 = 70.0;
const PIPE_SPEED: f64 = 1.5;
const PIPE_INTERVAL: i32 = 120;
const GROUND_H: f64 = 20.0;
const KEY_SPACE: i32 = 32;
const KEY_UP: i32 = 38;
const MAX_PIPES: usize = 16;

const HEAP_BASE: usize = 8192;

// Colors
const SKY_FILL: i32 = 0x87CEEB;
const GROUND_FILL: i32 = 0x8B4513;
const BIRD_FILL: i32 = 0xFFD700;
const PIPE_FILL: i32 = 0x228B22;
const OVERLAY_FILL: i32 = 0x000000;

// --- Host imports ---

extern "kagura_host" fn log_i32_utf8(level: i32, ptr: [*]const u8, len: i32) i32;
extern "kagura_host" fn read_asset_len_i32_utf8(ptr: [*]const u8, len: i32) i32;
extern "kagura_host" fn read_asset_copy_i32_utf8(path_ptr: [*]const u8, path_len: i32, dst_ptr: [*]u8) i32;

// --- Bump allocator ---

var heap_offset: usize = HEAP_BASE;

fn allocBytes(size: usize) usize {
    const ptr = heap_offset;
    heap_offset += size;
    return ptr;
}

fn bumpReset() void {
    heap_offset = HEAP_BASE;
}

// --- Memory helpers ---

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

fn readI32(ptr: usize) i32 {
    const p: *align(1) const i32 = @ptrFromInt(ptr);
    return p.*;
}

fn readF64(ptr: usize) f64 {
    const p: *align(1) const f64 = @ptrFromInt(ptr);
    return p.*;
}

fn writeBytes(dst: usize, src: []const u8) void {
    var i: usize = 0;
    while (i < src.len) : (i += 1) {
        const out: *u8 = @ptrFromInt(dst + i);
        out.* = src[i];
    }
}

// --- Host service wrappers ---

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

// --- Config serialization ---

fn writeGuestConfigBytes(title: []const u8) i32 {
    const ptr = allocBytes(16 + title.len);
    writeI32(ptr, screen_w);
    writeI32(ptr + 4, screen_h);
    writeI32(ptr + 8, target_tps);
    writeI32(ptr + 12, @intCast(title.len));
    writeBytes(ptr + 16, title);
    return @intCast(ptr);
}

// --- NDC conversion ---

fn ndcX(x: f64, width: f64) f32 {
    return @floatCast((x / width) * 2.0 - 1.0);
}

fn ndcY(y: f64, height: f64) f32 {
    return @floatCast(1.0 - (y / height) * 2.0);
}

// --- Draw command ---

const CMD_SIZE: usize = 28 + 16 * 4 + 6 * 4; // header(28) + 4 verts * 4 floats + 6 indices

fn writeRectCommand(x: f64, y: f64, w: f64, h: f64, fill: i32, alpha: i32) void {
    const sw = @as(f64, @floatFromInt(screen_w));
    const sh = @as(f64, @floatFromInt(screen_h));
    const x0 = ndcX(x, sw);
    const y0 = ndcY(y, sh);
    const x1 = ndcX(x + w, sw);
    const y1 = ndcY(y + h, sh);

    const ptr = allocBytes(CMD_SIZE);
    writeI32(ptr, 4); // vertex_count
    writeI32(ptr + 4, 6); // index_count
    writeI32(ptr + 8, 0); // src_image_id
    writeI32(ptr + 12, (fill >> 16) & 0xFF); // r
    writeI32(ptr + 16, (fill >> 8) & 0xFF); // g
    writeI32(ptr + 20, fill & 0xFF); // b
    writeI32(ptr + 24, alpha); // a

    const vertices = [_]f32{
        x0, y0, 0.0, 0.0,
        x1, y0, 1.0, 0.0,
        x1, y1, 1.0, 1.0,
        x0, y1, 0.0, 1.0,
    };
    var vi: usize = 0;
    while (vi < vertices.len) : (vi += 1) {
        writeF32(ptr + 28 + vi * 4, vertices[vi]);
    }

    const idx_base = ptr + 28 + vertices.len * 4;
    const indices = [_]u32{ 0, 1, 2, 0, 2, 3 };
    var ii: usize = 0;
    while (ii < indices.len) : (ii += 1) {
        writeU32(idx_base + ii * 4, indices[ii]);
    }
}

// --- Input reading ---

const InputState = struct {
    keys: [16]i32,
    key_count: usize,
    mouse_btn_count: usize,
};

fn readInput(base: usize) InputState {
    // Skip cursor_x(f64), cursor_y(f64), wheel_x(f64), wheel_y(f64) = 32 bytes
    _ = readF64(base);
    const key_count_raw: usize = @intCast(readI32(base + 32));
    const key_count = if (key_count_raw > 16) 16 else key_count_raw;
    var keys = [_]i32{0} ** 16;
    var i: usize = 0;
    while (i < key_count) : (i += 1) {
        keys[i] = readI32(base + 36 + i * 4);
    }
    const mouse_offset = 36 + key_count_raw * 4;
    const mouse_btn_count: usize = @intCast(readI32(base + mouse_offset));
    return InputState{
        .keys = keys,
        .key_count = key_count,
        .mouse_btn_count = mouse_btn_count,
    };
}

fn isKeyPressed(input: *const InputState, key_code: i32) bool {
    var i: usize = 0;
    while (i < input.key_count) : (i += 1) {
        if (input.keys[i] == key_code) return true;
    }
    return false;
}

// --- Game state ---

const Pipe = struct {
    x: f64,
    gap_y: f64,
};

var game = Game{
    .game_mode = 0,
    .score = 0,
    .bird_y = @as(f64, @floatFromInt(screen_h)) / 2.0,
    .velocity = 0.0,
    .frame_count = 0,
    .pipe_timer = 0,
    .pipe_count = 0,
    .pipes = [_]Pipe{.{ .x = 0.0, .gap_y = 0.0 }} ** MAX_PIPES,
    .prev_action = false,
};

const Game = struct {
    game_mode: i32, // 0=start, 1=playing, 2=game_over
    score: i32,
    bird_y: f64,
    velocity: f64,
    frame_count: i32,
    pipe_timer: i32,
    pipe_count: usize,
    pipes: [MAX_PIPES]Pipe,
    prev_action: bool,

    fn reset(self: *Game) void {
        self.bird_y = @as(f64, @floatFromInt(screen_h)) / 2.0;
        self.velocity = 0.0;
        self.game_mode = 0;
        self.score = 0;
        self.pipe_count = 0;
        self.pipe_timer = 0;
    }

    fn update(self: *Game, input: *const InputState) void {
        self.frame_count += 1;
        const current_action = isKeyPressed(input, KEY_SPACE) or
            isKeyPressed(input, KEY_UP) or
            (input.mouse_btn_count > 0);
        const action = current_action and !self.prev_action;
        self.prev_action = current_action;

        switch (self.game_mode) {
            0 => {
                if (action) {
                    self.game_mode = 1;
                    self.velocity = JUMP_VELOCITY;
                }
            },
            1 => {
                // Physics
                self.velocity += GRAVITY;
                self.bird_y += self.velocity;
                if (action) {
                    self.velocity = JUMP_VELOCITY;
                }

                // Pipe generation
                self.pipe_timer += 1;
                if (self.pipe_timer >= PIPE_INTERVAL and self.pipe_count < MAX_PIPES) {
                    self.pipe_timer = 0;
                    const sh = @as(f64, @floatFromInt(screen_h));
                    const min_gap_y: f64 = 40.0;
                    const max_gap_y: f64 = sh - GROUND_H - PIPE_GAP - 40.0;
                    const gap_y = min_gap_y + pseudoRandom(self.frame_count) * (max_gap_y - min_gap_y);
                    self.pipes[self.pipe_count] = Pipe{ .x = @as(f64, @floatFromInt(screen_w)), .gap_y = gap_y };
                    self.pipe_count += 1;
                }

                // Move pipes and check scoring
                var i: usize = 0;
                while (i < self.pipe_count) : (i += 1) {
                    const old_x = self.pipes[i].x;
                    self.pipes[i].x -= PIPE_SPEED;
                    const pr = old_x + PIPE_WIDTH;
                    const pr_new = self.pipes[i].x + PIPE_WIDTH;
                    if (pr >= BIRD_X and pr_new < BIRD_X) {
                        self.score += 1;
                    }
                }

                // Remove off-screen pipes
                var write_idx: usize = 0;
                var read_idx: usize = 0;
                while (read_idx < self.pipe_count) : (read_idx += 1) {
                    if (self.pipes[read_idx].x + PIPE_WIDTH > 0.0) {
                        self.pipes[write_idx] = self.pipes[read_idx];
                        write_idx += 1;
                    }
                }
                self.pipe_count = write_idx;

                // Collision: ground/ceiling
                const ground_top = @as(f64, @floatFromInt(screen_h)) - GROUND_H;
                if (self.bird_y + BIRD_SIZE > ground_top or self.bird_y < 0.0) {
                    self.game_mode = 2;
                }

                // Collision: pipes
                var pi: usize = 0;
                while (pi < self.pipe_count) : (pi += 1) {
                    const pipe = self.pipes[pi];
                    const bird_right = BIRD_X + BIRD_SIZE;
                    const bird_bottom = self.bird_y + BIRD_SIZE;
                    const pipe_right = pipe.x + PIPE_WIDTH;
                    if (bird_right > pipe.x and BIRD_X < pipe_right) {
                        const gap_bottom = pipe.gap_y + PIPE_GAP;
                        if (self.bird_y < pipe.gap_y or bird_bottom > gap_bottom) {
                            self.game_mode = 2;
                        }
                    }
                }
            },
            else => {
                if (action) {
                    self.reset();
                }
            },
        }
    }

    fn countDrawCommands(self: *const Game) i32 {
        const ground_y = @as(f64, @floatFromInt(screen_h)) - GROUND_H;
        var count: i32 = 3; // sky + ground + bird
        var i: usize = 0;
        while (i < self.pipe_count) : (i += 1) {
            const pipe = self.pipes[i];
            if (pipe.gap_y > 0.0) count += 1; // upper pipe
            const lower_h = ground_y - (pipe.gap_y + PIPE_GAP);
            if (lower_h > 0.0) count += 1; // lower pipe
        }
        if (self.game_mode == 2) count += 1; // game over overlay
        return count;
    }

    fn draw(self: *const Game) i32 {
        bumpReset();
        const sw = @as(f64, @floatFromInt(screen_w));
        const sh = @as(f64, @floatFromInt(screen_h));
        const ground_y = sh - GROUND_H;

        const cmd_count = self.countDrawCommands();
        const header_ptr = allocBytes(4);
        writeI32(header_ptr, cmd_count);

        // Sky
        writeRectCommand(0.0, 0.0, sw, sh, SKY_FILL, 255);
        // Ground
        writeRectCommand(0.0, ground_y, sw, GROUND_H, GROUND_FILL, 255);
        // Pipes
        var i: usize = 0;
        while (i < self.pipe_count) : (i += 1) {
            const pipe = self.pipes[i];
            // Upper pipe
            if (pipe.gap_y > 0.0) {
                writeRectCommand(pipe.x, 0.0, PIPE_WIDTH, pipe.gap_y, PIPE_FILL, 255);
            }
            // Lower pipe
            const lower_y = pipe.gap_y + PIPE_GAP;
            const lower_h = ground_y - lower_y;
            if (lower_h > 0.0) {
                writeRectCommand(pipe.x, lower_y, PIPE_WIDTH, lower_h, PIPE_FILL, 255);
            }
        }
        // Bird
        writeRectCommand(BIRD_X, self.bird_y, BIRD_SIZE, BIRD_SIZE, BIRD_FILL, 255);
        // Game over overlay
        if (self.game_mode == 2) {
            writeRectCommand(
                sw / 2.0 - 50.0,
                sh / 2.0 - 20.0,
                100.0,
                40.0,
                OVERLAY_FILL,
                128,
            );
        }

        return @intCast(header_ptr);
    }
};

fn pseudoRandom(seed: i32) f64 {
    const x = @as(i32, @truncate(@as(i64, seed) *% 1103515245 +% 12345));
    return @as(f64, @floatFromInt((x >> 16) & 0x7FFF)) / 32767.0;
}

// --- WASM Exports ---

export fn kagura_alloc(size: i32) callconv(.c) i32 {
    return @intCast(allocBytes(@intCast(size)));
}

export fn kagura_guest_init(_: i32, _: i32) callconv(.c) i32 {
    heap_offset = HEAP_BASE;
    game.reset();
    game.frame_count = 0;
    game.prev_action = false;
    hostLogInfo("guest init: zig/flappy");
    if (hostReadAsset("/guest-title.txt")) |title| {
        hostLogInfo("guest asset: /guest-title.txt");
        return writeGuestConfigBytes(title);
    }
    return writeGuestConfigBytes("Flappy Bird (Zig)");
}

export fn kagura_guest_update(ptr: i32, _: i32) callconv(.c) i32 {
    const input = readInput(@intCast(ptr));
    game.update(&input);
    return 1;
}

export fn kagura_guest_render() callconv(.c) i32 {
    return game.draw();
}

export fn kagura_guest_snapshot_state() callconv(.c) i32 {
    return 0;
}

export fn kagura_guest_restore_state(_: i32, _: i32) callconv(.c) i32 {
    return 0;
}

export fn kagura_guest_shutdown() callconv(.c) void {}
