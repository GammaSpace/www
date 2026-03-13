#!/bin/bash

# Generate responsive screenshot variants

GAMES_DIR="static/content/games"

echo "🎮 Generating responsive screenshot variants..."
echo ""

for game_dir in "$GAMES_DIR"/*/ ; do
  game_name=$(basename "$game_dir")
  images_dir="${game_dir}images"

  if [ ! -d "$images_dir" ]; then
    continue
  fi

  # Find all original screenshots (png/jpg but not variants)
  screenshots=$(find "$images_dir" -type f \( -name "*.png" -o -name "*.jpg" \) ! -name "*-640w*" ! -name "*-1024w*" ! -name "*-1920w*")

  if [ -z "$screenshots" ]; then
    echo "${game_name}: No screenshots found"
    continue
  fi

  count=$(echo "$screenshots" | wc -l | tr -d ' ')
  echo "📁 ${game_name} (${count} images)"

  for img in $screenshots; do
    filename=$(basename "$img")
    base="${img%.*}"
    ext="${img##*.}"

    echo "  Processing: ${filename}"

    # Generate 640w variant (mobile)
    magick "$img" -resize 640x -quality 85 "${base}-temp-640.png"
    cwebp -q 75 "${base}-temp-640.png" -o "${base}-640w.webp" 2>/dev/null
    rm -f "${base}-temp-640.png"
    size_640=$(du -h "${base}-640w.webp" | cut -f1)
    echo "    ✓ 640w.webp (${size_640})"

    # Generate 1024w variant (tablet)
    magick "$img" -resize 1024x -quality 85 "${base}-temp-1024.png"
    cwebp -q 80 "${base}-temp-1024.png" -o "${base}-1024w.webp" 2>/dev/null
    rm -f "${base}-temp-1024.png"
    size_1024=$(du -h "${base}-1024w.webp" | cut -f1)
    echo "    ✓ 1024w.webp (${size_1024})"

    # Generate 1920w variant (desktop)
    magick "$img" -resize 1920x -quality 85 "${base}-temp-1920.png"
    cwebp -q 82 "${base}-temp-1920.png" -o "${base}-1920w.webp" 2>/dev/null
    rm -f "${base}-temp-1920.png"
    size_1920=$(du -h "${base}-1920w.webp" | cut -f1)
    echo "    ✓ 1920w.webp (${size_1920})"
  done

  echo ""
done

echo "✨ Done!"
