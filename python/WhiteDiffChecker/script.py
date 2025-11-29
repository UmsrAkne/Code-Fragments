from PIL import Image
import numpy as np
from skimage.metrics import structural_similarity as ssim
import glob
import sys
import os

# パスの決定ロジック
if len(sys.argv) > 1:
    # 引数指定あり → それを使う
    target_dir = sys.argv[1]
else:
    # 引数なし → bash のカレントディレクトリ
    target_dir = os.getcwd()

# 最後にスラッシュが無ければ付ける（globのため）
if not target_dir.endswith("/") and not target_dir.endswith("\\"):
    target_dir += os.sep

print(f"Target directory: {target_dir}")

# PNG 検索
paths = sorted(glob.glob(os.path.join(target_dir, "*.png")))
if not paths:
    print("No PNG files found.")
    sys.exit(1)

white_ratios = []
images = []

for p in paths:
    # img = cv2.imread(p, cv2.IMREAD_GRAYSCALE)
    img = Image.open(p).convert("L")
    img = np.array(img)

    if img is None:
        print("読み込み失敗:", p)
        continue

    if img.size == 0:
        print("空画像:", p, "shape=", img.shape)
        continue

    print("読み込み成功", p)
    images.append(img)

    # 白の閾値設定
    white = np.sum(img > 230)
    total = img.size
    white_ratios.append(white / total)

# 白飛び判定
high_white_images = [i for i, w in enumerate(white_ratios) if w > 0.95]

# デバッグ出力
for i, w in enumerate(white_ratios):
    print(f"{i:04d} {paths[i]} : {w}")

print("mean:", np.mean(white_ratios))
print("std:", np.std(white_ratios))

# 画像の重複チェック
similar_pairs = []
for i in range(1, len(images)):
    print(f"Comparing {i:04d}/{len(images)-1:04d}...")

    img1 = images[i]
    img2 = images[i - 1]

    # --- 高速プリチェック（差分の総和）------------------------
    diff = np.sum(np.abs(img1 - img2))
    if diff > 200000:   # 閾値は好みに調整
        continue

    # --- 必要な場合だけ SSIM（重い） --------------------------
    score = ssim(img1, img2)
    if score > 0.95:
        similar_pairs.append((i - 1, i))

# ---- 出力をファイル名に変更 ----
print("\n=== Similar Images ===")
for a, b in similar_pairs:
    print(f"{paths[a]}  <==>  {paths[b]}")

print("\n=== High White Images ===")
for i in high_white_images:
    print(paths[i])