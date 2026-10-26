from pathlib import Path
from PIL import Image, ImageDraw
import sys

folder = Path(sys.argv[1] if len(sys.argv) > 1 else 'docs/screenshots')
files = sorted(folder.glob('*.png'))
for batch in range(0, len(files), 10):
    sheet = Image.new('RGB', (1100, 1010), '#eeeeee')
    draw = ImageDraw.Draw(sheet)
    for k, path in enumerate(files[batch:batch + 10]):
        im = Image.open(path).convert('RGB')
        im = im.crop((0, 0, im.width, min(im.height, im.width * 926 // 428)))
        im.thumbnail((214, 470))
        x, y = (k % 5) * 220 + 3, (k // 5) * 505 + 25
        sheet.paste(im, (x, y))
        draw.text((x, y - 20), path.stem[:30], fill='black')
    sheet.save(folder.parent / f'{folder.name}-sheet-{batch // 10 + 1}.jpg')
