from PIL import Image
import os

files = [
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_sword.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_orbit.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_boomerang.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_bomb.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Enemies\enemy_goblin.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Enemies\enemy_giant.png"
]

for file_path in files:
    try:
        img = Image.open(file_path)
        img = img.convert("RGBA")
        # Get top-left pixel
        bg_color = img.getpixel((0, 0))
        print(f"File: {os.path.basename(file_path)}")
        print(f"  Top-left pixel: {bg_color}")
        
        # Sample a few more pixels to see if there's variation
        print(f"  (0, 1): {img.getpixel((0, 1))}")
        print(f"  (1, 0): {img.getpixel((1, 0))}")
        print(f"  (1, 1): {img.getpixel((1, 1))}")
        
        # Check if it has transparency already
        has_transparency = False
        for pixel in img.getdata():
            if pixel[3] < 255:
                has_transparency = True
                break
        print(f"  Has transparency: {has_transparency}")
        
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
