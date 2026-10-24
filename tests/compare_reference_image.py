"""从课件参考图读取颜色像素，与计算 CSV 的曲线位置比较。

参考图是栅格截图，比较结果仅说明图形吻合程度，不作为精确原始数据。
"""
from pathlib import Path
from zipfile import ZipFile
from io import BytesIO
import argparse
import csv
import json
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
COLORS = np.array([[0, 114, 189], [217, 83, 25], [237, 177, 32],
                   [126, 47, 142], [119, 172, 48]])
NAMES = ["KRLS", "KLMS", "FrKLMS", "FrKRLS", "KRGMC"]
parser = argparse.ArgumentParser(description="对照自行取得授权的课件截图与本地计算结果")
parser.add_argument("--deck", type=Path, required=True, help="自行取得授权的原版课件文件")
parser.add_argument("--results-dir", type=Path, required=True, help="本地生成的曲线 CSV 所在目录")
args = parser.parse_args()
if not args.deck.is_file() or not args.results_dir.is_dir():
    parser.error("课件或结果目录不存在；仓库不分发这些原始材料。")
REPORT = {}
with ZipFile(args.deck) as deck:
    for coord, media, box, limits in [
        ("X", "ppt/media/image78.png", (53, 486, 33, 375), (2, 14)),
        ("Y", "ppt/media/image79.png", (60, 493, 37, 379), (2, 16)),
    ]:
        pixels = np.array(Image.open(BytesIO(deck.read(media))).convert("RGB"))
        with (args.results_dir / f"learning_curve_{coord}.csv").open(
            encoding="utf-8-sig", newline=""
        ) as f:
            rows = list(csv.DictReader(f))
        left, right, top, bottom = box
        low, high = limits
        per_curve = {}
        for name, color in zip(NAMES, COLORS):
            distance = np.max(np.abs(pixels.astype(float) - color), axis=2)
            color_y, color_x = np.nonzero(distance < 18)
            # 仅图内数据，排除右上角图例中的同色线段。
            keep = ((color_x > left) & (color_x <= right) &
                    (color_y > top) & (color_y < bottom) &
                    ~((color_x > 350) & (color_y < 155)))
            color_x, color_y = color_x[keep], color_y[keep]
            errors = []
            pixel_errors = []
            occluded = []
            for n, row in enumerate(rows, 1):
                expected_x = left + n * (right-left) / 70
                expected_y = bottom - (float(row[name+"_dB"])-low) * (bottom-top)/(high-low)
                nearby = np.abs(color_x-expected_x) <= 1.5
                nearest = (np.min(np.hypot(color_x[nearby]-expected_x,
                                           color_y[nearby]-expected_y))
                           if np.any(nearby) else float("inf"))
                if nearest >= 3:
                    # 后绘制的线可能遮住前面的线，不能把另一算法的像素
                    # 算成当前算法的验证结果。只记录可证实的遮挡并跳过。
                    blockers = []
                    for later in range(NAMES.index(name)+1,len(NAMES)):
                        patch = pixels[max(0,int(expected_y)-3):int(expected_y)+4,
                                       max(0,int(expected_x)-2):int(expected_x)+3]
                        same_color = np.max(np.abs(patch.astype(float)-COLORS[later]),axis=2)<18
                        if np.any(same_color):
                            blockers.append(NAMES[later])
                    if blockers:
                        occluded.append({"iteration":n,"overlapping_curves":blockers})
                        continue
                    raise AssertionError(f"{coord}/{name}: sample {n} raster distance={nearest}")
                pixel_errors.append(float(nearest))
                # 按纵轴尺度换算像素距离，仅为截图比较的等效误差。
                errors.append(float(nearest*(high-low)/(bottom-top)))
            per_curve[name] = {"visible_samples_compared": len(errors),
                               "occluded_samples_not_individually_verified": occluded,
                               "max_pixel_distance": max(pixel_errors),
                               "median_pixel_distance": float(np.median(pixel_errors)),
                               "max_equivalent_db_distance": max(errors)}
            assert max(pixel_errors) < 3, f"{coord}/{name}: raster mismatch"
            assert len(errors) >= 45, f"{coord}/{name}: insufficient visible samples"
        REPORT[coord] = per_curve
REPORT["method"] = "70 sample positions per curve; nearest matching-color reference pixel; raster tolerance <3 px"
REPORT["limitation"] = "Reference screenshot has no original numeric series; raster agreement is not exact numerical equality."
destination = args.results_dir / "reference_comparison.json"
destination.write_text(json.dumps(REPORT, indent=2, ensure_ascii=False), encoding="utf-8")
print(json.dumps(REPORT, indent=2, ensure_ascii=False))
