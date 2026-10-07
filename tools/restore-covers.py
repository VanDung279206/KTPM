"""Download catalog thumbnails from the reviewed sources manifest; no credentials needed."""
import concurrent.futures
import io
import json
from pathlib import Path
from urllib.request import Request, urlopen

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
COVERS = ROOT / "bookstore-backend/bookish/src/main/resources/covers"


def download(item):
    filename = item["file"]
    if Path(filename).name != filename or not filename.endswith(".jpg"):
        raise ValueError("Invalid cover filename")
    if not item["image"].startswith("https://"):
        raise ValueError("Cover source must use HTTPS")
    if (COVERS / filename).exists():
        return filename
    request = Request(item["image"], headers={"User-Agent": "Bookish-Catalog-Restore/1.0"})
    with urlopen(request, timeout=30) as response:
        content = response.read(15_000_001)
    if len(content) > 15_000_000:
        raise ValueError("Image exceeds 15 MB")
    # Normalize the container to JPEG because the existing catalog uses .jpg URLs.
    with Image.open(io.BytesIO(content)) as original:
        image = ImageOps.exif_transpose(original).convert("RGBA")
        background = Image.new("RGB", image.size, "white")
        background.paste(image, mask=image.getchannel("A"))
        background.save(COVERS / filename, "JPEG", quality=88, optimize=True)
    return filename


if __name__ == "__main__":
    sources = json.loads((COVERS / "sources.json").read_text(encoding="utf-8"))
    failures = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
        tasks = {pool.submit(download, item): item["file"] for item in sources}
        for task in concurrent.futures.as_completed(tasks):
            try:
                print("OK", task.result())
            except Exception as error:
                failures.append(tasks[task])
                print("FAILED", tasks[task], type(error).__name__, str(error))
    if failures:
        raise SystemExit(1)
