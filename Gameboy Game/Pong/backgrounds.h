#ifndef BACKGROUNDS_H
#define BACKGROUNDS_H

#include <gb/gb.h>

// Simple background tiles (8x8 pixels)
// We will just use the same sprite tiles but re-purpose them for background
// And maybe define a few more patterns
const unsigned char bg_tiles[] = {
    // Tile 0: Blank
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    // Tile 1: Dots
    0x00,0x00,0x18,0x18,0x00,0x00,0x18,0x18,
    0x00,0x00,0x18,0x18,0x00,0x00,0x18,0x18,
    // Tile 2: Stripes
    0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,
    0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,
    // Tile 3: Checks
    0xF0,0xF0,0xF0,0xF0,0x0F,0x0F,0x0F,0x0F,
    0xF0,0xF0,0xF0,0xF0,0x0F,0x0F,0x0F,0x0F
};

void init_backgrounds() {
    // Load background patterns starting at index 128 to avoid overwriting font
    set_bkg_data(128, 4, bg_tiles);
}

void set_background_pattern(UINT8 pattern_id) {
    UINT8 x, y;
    UINT8 tile_id = 128; // Default empty
    
    // Select tile based on pattern_id
    switch(pattern_id % 3) { // 3 different patterns
        case 0: tile_id = 129; break; // Dots
        case 1: tile_id = 130; break; // Stripes
        case 2: tile_id = 131; break; // Checks
        default: tile_id = 128; break; 
    }

    // Fill the background (20x18 tiles for 160x144, but map is 32x32)
    // We only need to fill the visible area, skipping the top row for score
    for (y = 1; y < 18; y++) {
        for (x = 0; x < 20; x++) {
            set_bkg_tiles(x, y, 1, 1, &tile_id);
        }
    }
}

#endif
