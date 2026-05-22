#!/usr/bin/env python3

from __future__ import annotations

import argparse
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--mode", default="isolate")
    parser.add_argument("--padding", type=float, default=0.14)
    parser.add_argument("--size", type=int, default=1024)
    return parser.parse_args()


def mean_corner_palette(image: Image.Image) -> list[tuple[int, int, int]]:
    w, h = image.size
    offsets = [
        (0, 0),
        (w - 1, 0),
        (0, h - 1),
        (w - 1, h - 1),
    ]
    palette: list[tuple[int, int, int]] = []
    for x, y in offsets:
        rgb = image.getpixel((x, y))[:3]
        if rgb not in palette:
            palette.append(rgb)
    return palette


def color_distance(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    dr = a[0] - b[0]
    dg = a[1] - b[1]
    db = a[2] - b[2]
    return math.sqrt(dr * dr + dg * dg + db * db)


def build_foreground_mask(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    if alpha.getbbox() and alpha.getextrema()[0] < 250:
        return alpha.point(lambda value: 255 if value > 8 else 0)

    palette = mean_corner_palette(image)
    if not palette:
        return Image.new("L", image.size, 255)

    mask = Image.new("L", image.size, 0)
    pixels = image.load()
    dst = mask.load()
    for y in range(image.height):
        for x in range(image.width):
            rgb = pixels[x, y][:3]
            min_distance = min(color_distance(rgb, sample) for sample in palette)
            dst[x, y] = 255 if min_distance >= 42 else 0

    mask = mask.filter(ImageFilter.MaxFilter(5))
    mask = mask.filter(ImageFilter.MinFilter(3))
    return mask


def padded_bbox(mask: Image.Image, padding: float) -> tuple[int, int, int, int]:
    bbox = mask.getbbox()
    if not bbox:
        return (0, 0, mask.width, mask.height)

    left, top, right, bottom = bbox
    width = right - left
    height = bottom - top
    pad_x = max(8, int(width * padding))
    pad_y = max(8, int(height * padding))
    return (
        max(0, left - pad_x),
        max(0, top - pad_y),
        min(mask.width, right + pad_x),
        min(mask.height, bottom + pad_y),
    )


def composite_subject(source: Image.Image, mask: Image.Image, size: int, padding: float) -> Image.Image:
    bbox = padded_bbox(mask, padding)
    cropped = source.crop(bbox)
    cropped_mask = mask.crop(bbox)

    canvas = Image.new("RGBA", (size, size), (246, 244, 239, 255))
    available = max(1, int(size * (1.0 - padding * 2.0)))
    scale = min(available / cropped.width, available / cropped.height)
    scaled_size = (
        max(1, int(cropped.width * scale)),
        max(1, int(cropped.height * scale)),
    )
    subject = cropped.resize(scaled_size, Image.Resampling.LANCZOS)
    subject_mask = cropped_mask.resize(scaled_size, Image.Resampling.LANCZOS)

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    offset_x = (size - scaled_size[0]) // 2
    offset_y = (size - scaled_size[1]) // 2
    shadow_mask = subject_mask.filter(ImageFilter.GaussianBlur(10))
    shadow.paste((0, 0, 0, 48), (offset_x + 8, offset_y + 10), shadow_mask)
    canvas.alpha_composite(shadow)
    canvas.paste(subject, (offset_x, offset_y), subject_mask)
    return canvas


def preprocess_isolate(image: Image.Image, size: int, padding: float) -> Image.Image:
    mask = build_foreground_mask(image)
    if not mask.getbbox():
        return image.resize((size, size), Image.Resampling.LANCZOS)
    composite = composite_subject(image, mask, size, padding)
    trim = ImageChops.difference(
        composite,
        Image.new("RGBA", composite.size, (246, 244, 239, 255)),
    )
    return composite if trim.getbbox() else image.resize((size, size), Image.Resampling.LANCZOS)


def main() -> None:
    args = parse_args()
    image = Image.open(args.image).convert("RGBA")
    if args.mode not in ("isolate",):
        raise ValueError(f"unsupported preprocess mode: {args.mode}")
    output = preprocess_isolate(image, args.size, args.padding)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output.save(output_path)


if __name__ == "__main__":
    main()
