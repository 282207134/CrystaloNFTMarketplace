from pathlib import Path
from PIL import Image, ImageDraw
import math
import json

root = Path(__file__).resolve().parents[1]

def icon(path, size):
    im = Image.new('RGB', (size, size), '#F8BB5A')
    draw = ImageDraw.Draw(im)
    center = (size / 2, size / 2)
    radius = size * .34
    draw.ellipse((size*.12, size*.12, size*.88, size*.88), fill='#181817')
    for i in range(6):
        a, b = -math.pi / 2 + i * math.pi / 3, -math.pi / 2 + (i+1) * math.pi / 3
        points = [center, (center[0]+math.cos(a)*radius, center[1]+math.sin(a)*radius), (center[0]+math.cos(b)*radius, center[1]+math.sin(b)*radius)]
        centroid = tuple(sum(p[j] for p in points)/3 for j in (0,1))
        points = [(centroid[0]+(p[0]-centroid[0])*.78, centroid[1]+(p[1]-centroid[1])*.78) for p in points]
        draw.polygon(points, fill='#F8BB5A')
    im.save(path)

for folder in ['android/app/src/main/res', 'ios/Runner/Assets.xcassets/AppIcon.appiconset', 'web']:
    for path in (root / folder).rglob('*.png'):
        if path.name.startswith(('ic_launcher', 'Icon-', 'Icon-App-', 'favicon')):
            with Image.open(path) as original:
                size = original.width
            icon(path, size)

for folder in ['drawable', 'drawable-v21']:
    path = root / 'android/app/src/main/res' / folder / 'launch_background.xml'
    path.write_text('''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/crystalo_gold" />
</layer-list>
''', encoding='utf-8')

manifest = root / 'web/manifest.json'
data = json.loads(manifest.read_text())
data.update(name='Crystalo', short_name='Crystalo', background_color='#181817', theme_color='#F8BB5A', description='Discover, collect and sell digital artwork on Crystalo.')
manifest.write_text(json.dumps(data, indent=2), encoding='utf-8')
index = root / 'web/index.html'
index.write_text(index.read_text().replace('A new Flutter project.', 'Crystalo NFT Marketplace').replace('<title>crystalo</title>', '<title>Crystalo</title>'), encoding='utf-8')
