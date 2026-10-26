from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
panels = [('05', 'EXPLORE'), ('18', 'RANKING'), ('22', 'NFT DETAILS'), ('34', 'PROFILE'), ('43', 'MY WALLET'), ('50', 'HELP CENTER')]
width, height, gap = 300, 649, 24
canvas = Image.new('RGB', (gap + (width+gap)*3, 2*(height+58)+gap), '#100F0E')
draw = ImageDraw.Draw(canvas)
font = ImageFont.truetype(str(root/'assets/fonts/SpaceGrotesk-Medium.ttf'), 17)
for i, (number, title) in enumerate(panels):
    x, y = gap+(i%3)*(width+gap), gap+(i//3)*(height+58)
    draw.text((x,y), f'{number}  /  {title}', font=font, fill='#F8BB5A')
    image = Image.open(root/'docs/screenshots'/f'{number}.png').convert('RGB')
    image = image.resize((width,height), Image.Resampling.LANCZOS)
    canvas.paste(image, (x,y+30))
canvas.save(root/'docs/app-overview.png')
