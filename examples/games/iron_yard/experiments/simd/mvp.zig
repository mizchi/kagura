// Fixed-width f64 SIMD preserves the Double arithmetic used by math3d.Mat4.
// No fast-math/FMA: round to f32 only when writing uniform words.
export fn batch_mvp(vp_address: u32, models_address: u32, out_address: u32, count: u32) void {
    const vp: [*]const f64 = @ptrFromInt(vp_address);
    const models: [*]const f64 = @ptrFromInt(models_address);
    const out: [*]f32 = @ptrFromInt(out_address);
    for (0..count) |instance| {
        const model = models + instance * 16;
        for (0..4) |column| {
            for (0..2) |pair| {
                const row = pair * 2;
                var sum: @Vector(2, f64) = .{ 0, 0 };
                // Match Mat4.multiply's accumulation order, including +0.
                inline for (0..4) |k| {
                    const a: @Vector(2, f64) = .{ vp[k * 4 + row], vp[k * 4 + row + 1] };
                    const b: @Vector(2, f64) = @splat(model[column * 4 + k]);
                    sum = sum + a * b;
                }
                out[instance * 16 + column * 4 + row] = @floatCast(sum[0]);
                out[instance * 16 + column * 4 + row + 1] = @floatCast(sum[1]);
            }
        }
    }
}
