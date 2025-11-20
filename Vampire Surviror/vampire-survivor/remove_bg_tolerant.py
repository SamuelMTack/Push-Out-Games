from PIL import Image
import os

def remove_background_tolerant(file_path, threshold=230):
    try:
        img = Image.open(file_path)
        img = img.convert("RGBA")
        datas = img.getdata()

        newData = []
        for item in datas:
            # item is (r, g, b, a)
            # Check if pixel is close to white (light gray to white)
            if item[0] >= threshold and item[1] >= threshold and item[2] >= threshold:
                newData.append((255, 255, 255, 0))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(file_path, "PNG")
        print(f"Processed: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

files = [
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_sword.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_orbit.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_boomerang.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Weapons\weapon_bomb.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Enemies\enemy_goblin.png",
    r"c:\Users\Samuel\Documents\GitHub\Push-Out-Games\Vampire Surviror\vampire-survivor\Assets\Sprites\Enemies\enemy_giant.png"
]

for file in files:
    if os.path.exists(file):
        remove_background_tolerant(file)
    else:
        print(f"File not found: {file}")
