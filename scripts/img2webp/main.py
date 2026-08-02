"""
main.py - standalone image -> webp converter.

Self-contained: on first run it installs its own dependencies
(imageio-ffmpeg, which bundles a per-platform static ffmpeg binary, and
Pillow, used only to read image width) - no system-wide ffmpeg/ffprobe
install required. Just run: python main.py [options]
"""

import argparse
import importlib.util
import os
import subprocess
import sys
import zipfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from pathlib import Path
from shutil import rmtree
from typing import Optional

PACKAGE_TO_MODULE: dict[str, str] = {
    "imageio-ffmpeg": "imageio_ffmpeg",
    "Pillow": "PIL",
    "zlib_ng": "zlib",
}


def pip_install(package: str) -> None:
    base_cmd: list[str] = [sys.executable, "-m", "pip", "install", "--quiet", package]
    result = subprocess.run(base_cmd, capture_output=True, text=True)
    if result.returncode != 0 and "externally-managed-environment" in result.stderr:
        result = subprocess.run(
            base_cmd + ["--break-system-packages"], capture_output=True, text=True
        )
    if result.returncode != 0:
        raise RuntimeError(f"Failed to install {package}:\n{result.stderr.strip()}")


def ensure_dependencies() -> None:
    for package, module_name in PACKAGE_TO_MODULE.items():
        if importlib.util.find_spec(module_name) is None:
            print(f"Installing missing dependency: {package}")
            pip_install(package)


try:
    ensure_dependencies()
except RuntimeError as exc:
    print(exc)
    sys.exit(1)

from imageio_ffmpeg import get_ffmpeg_exe  # noqa: E402
from PIL import Image  # noqa: E402

BASE_PATH: Path = Path.cwd()
INPUT_PATH: Path = Path.joinpath(BASE_PATH, "input")
OUTPUT_PATH: Path = Path.joinpath(BASE_PATH, "output")
ARCHIVE_OUTPUT_PATH: Path = Path.joinpath(BASE_PATH, "archive")

IMAGE_EXT: list[str] = [
    "jpg",
    "jpeg",
    "png",
]
COMPRESS_EXT: list[str] = [
    "webp",
    "bmp",
]

FFMPEG_QUALITY: int = 82
FFMPEG_COMPRESSION_LEVEL: int = 6
FFMPEG_PRESET: str = "photo"


def default_worker_count() -> int:
    """
    Each ffmpeg call is process-spawn + disk I/O + encode, not pure CPU work,
    so a core sits idle during the spawn/I/O phases. Running somewhat more
    workers than cores lets those idle gaps get filled by other threads'
    encode work instead of wasting them - this matches Python's own default
    ThreadPoolExecutor sizing, which is tuned for exactly this kind of mixed
    I/O+CPU workload.
    """
    return min(32, (os.cpu_count() or 1) + 4)


def path_exist(path: Path) -> bool:
    return Path.exists(path)


def ensure_directories() -> None:
    """Create input/output/archive folders automatically if they're missing."""
    created: list[Path] = []
    for path in (INPUT_PATH, OUTPUT_PATH, ARCHIVE_OUTPUT_PATH):
        if not path_exist(path):
            path.mkdir(parents=True, exist_ok=True)
            created.append(path)
    if created:
        names = ", ".join(p.name for p in created)
        print(f"Created missing folder(s): {names}")


def get_input_images() -> Optional[list[list[Path]]]:
    if not path_exist(INPUT_PATH):
        return None
    files = Path.iterdir(INPUT_PATH)
    images: list[Path] = []
    compress_images: list[Path] = []
    for file in files:
        file_path: Path = file
        file_ext: str = file_path.suffix.replace(".", "")
        if file_ext in COMPRESS_EXT:
            compress_images.append(file_path)
        elif file_ext in IMAGE_EXT:
            images.append(file_path)
        else:
            continue
    return [images, compress_images]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert images in ./input to webp in ./output"
    )
    parser.add_argument(
        "--force",
        "--overwrite",
        dest="force",
        action="store_true",
        help="Overwrite existing output files instead of skipping them",
    )
    parser.add_argument(
        "--max-width",
        dest="max_width",
        type=int,
        default=None,
        help="Skip converting images wider than this (px) instead of processing them",
    )
    parser.add_argument(
        "--clean",
        dest="clean",
        action="store_true",
        help="Remove everything in the output folder before converting",
    )
    parser.add_argument(
        "--archive",
        dest="archive",
        action="store_true",
        help="After converting, zip the converted output files into the archive folder",
    )
    parser.add_argument(
        "--workers",
        dest="workers",
        type=int,
        default=None,
        help="Parallel ffmpeg workers (default: cpu_count + 4, capped at 32)",
    )
    return parser.parse_args()


def get_ffmpeg_path() -> Optional[Path]:
    try:
        return Path(get_ffmpeg_exe())
    except Exception as exc:
        print(f"Could not obtain bundled ffmpeg: {exc}")
        return None


def get_image_width(image: Path) -> Optional[int]:
    try:
        with Image.open(image) as img:
            # Image.open() only parses the header, it doesn't decode pixel
            # data, so this stays cheap even on large files.
            return img.width
    except Exception:
        return None


def get_ffmpeg_cmd(ffmpeg_path: Path, input_path: Path, output_path: Path) -> list[str]:
    return [
        str(ffmpeg_path),
        "-y",
        "-loglevel",
        "error",
        "-i",
        str(input_path),
        "-c:v",
        "libwebp",
        "-preset",
        FFMPEG_PRESET,
        "-quality",
        str(FFMPEG_QUALITY),
        "-compression_level",
        str(FFMPEG_COMPRESSION_LEVEL),
        "-map_metadata",
        "-1",
        str(output_path),
    ]


def clean_output() -> int:
    if not path_exist(OUTPUT_PATH):
        return 0
    removed = 0
    for item in OUTPUT_PATH.iterdir():
        if item.is_dir() and not item.is_symlink():
            rmtree(item)
        else:
            item.unlink()
        removed += 1
    return removed


def process_image(
    image: Path,
    output_path: Path,
    ffmpeg_path: Path,
    force: bool,
    max_width: Optional[int],
) -> Optional[bool]:
    if (not image) or (not ffmpeg_path):
        return None
    if not path_exist(image):
        return None

    if path_exist(output_path) and not force:
        print(f"  skip {image.name} (output exists: {output_path.name})")
        return True

    if max_width:
        width = get_image_width(image)
        if width is not None and width > max_width:
            print(f"  skip {image.name} (width {width}px > max {max_width}px)")
            return True

    cmd: list[str] = get_ffmpeg_cmd(ffmpeg_path, image, output_path)
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"  x {image.name}: {result.stderr.strip()}")
        return False

    print(f"  ok {image.name} -> {output_path.name}")
    return True


def build_output_paths(images: list[Path]) -> dict[Path, Path]:
    stem_groups: dict[str, list[Path]] = {}
    for image in images:
        stem_groups.setdefault(image.stem, []).append(image)

    output_paths: dict[Path, Path] = {}
    for stem, group in stem_groups.items():
        if len(group) == 1:
            output_paths[group[0]] = Path.joinpath(OUTPUT_PATH, f"{stem}.webp")
            continue
        # same stem, different extensions (e.g. sample.jpg + sample.png) -
        # suffix each with its original extension so nothing gets overwritten
        print(f"  ! {len(group)} files named '{stem}', disambiguating by extension")
        for image in group:
            ext = image.suffix.lstrip(".")
            output_path = Path.joinpath(OUTPUT_PATH, f"{stem}_{ext}.webp")
            output_paths[image] = output_path
            print(f"      {image.name} -> {output_path.name}")
    return output_paths


def process_list_of_images(
    images: list[Path],
    ffmpeg_path: Path,
    force: bool,
    max_width: Optional[int],
    workers: int,
) -> tuple[Optional[bool], list[Path]]:
    """Convert every image, returning overall success and the list of output
    files that actually exist on disk afterwards (ready for archiving)."""
    if not images:
        return None, []
    if not path_exist(OUTPUT_PATH):
        OUTPUT_PATH.mkdir(parents=True, exist_ok=True)

    output_paths = build_output_paths(images)

    results: list[Optional[bool]] = []
    converted: list[Path] = []
    with ThreadPoolExecutor(max_workers=workers) as executor:
        future_to_output = {
            executor.submit(
                process_image, image, output_paths[image], ffmpeg_path, force, max_width
            ): output_paths[image]
            for image in images
        }
        for future in as_completed(future_to_output):
            ok = future.result()
            results.append(ok)
            output_path = future_to_output[future]
            if ok and path_exist(output_path):
                converted.append(output_path)

    return all(bool(r) for r in results), converted


def make_archive(files: list[Path]) -> Optional[Path]:
    """
    Zip converted outputs into ARCHIVE_OUTPUT_PATH.

    Uses ZIP_STORED (no compression) rather than ZIP_DEFLATED: webp output is
    already compressed, so re-compressing it inside the zip only burns CPU
    for zero size benefit. STORED just streams the bytes straight into the
    archive, which is as fast as the disk allows.
    """
    if not files:
        return None
    if not path_exist(ARCHIVE_OUTPUT_PATH):
        ARCHIVE_OUTPUT_PATH.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    archive_path = Path.joinpath(ARCHIVE_OUTPUT_PATH, f"output_{timestamp}.zip")

    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_STORED) as zf:
        for file in files:
            if path_exist(file):
                zf.write(file, arcname=file.name)

    return archive_path


def main() -> None:
    args = parse_args()

    ensure_directories()

    ffmpeg_path = get_ffmpeg_path()
    if ffmpeg_path is None:
        return

    if args.clean:
        removed = clean_output()
        print(f"Cleaned {removed} item(s) from {OUTPUT_PATH}")

    image_lists = get_input_images()
    if image_lists is None:
        print(f"Input directory not found: {INPUT_PATH}")
        return

    images, compress_images = image_lists
    all_images = images + compress_images
    if not all_images:
        print(f"No matching images in {INPUT_PATH}")
        return

    workers = args.workers or default_worker_count()
    print(f"Converting {len(all_images)} image(s) -> {OUTPUT_PATH} ({workers} workers)")
    success, converted_outputs = process_list_of_images(
        all_images, ffmpeg_path, args.force, args.max_width, workers
    )

    if args.archive:
        if converted_outputs:
            print(
                f"Archiving {len(converted_outputs)} file(s) -> {ARCHIVE_OUTPUT_PATH}"
            )
            archive_path = make_archive(converted_outputs)
            if archive_path:
                print(f"  ok archive created: {archive_path.name}")
        else:
            print("Nothing to archive (no converted output files)")

    print("Done" if success else "Done, with failures")


if __name__ == "__main__":
    main()
