#include <gb/gb.h>
#include <stdio.h>
#include <rand.h>
#include <string.h>

#include "tiles.h"
#include "map.h"

// Game States
#define STATE_INTRO 0
#define STATE_OVERWORLD 1
#define STATE_BATTLE 2

// Battle States
#define BATTLE_WAIT_INPUT 0
#define BATTLE_ATTACK 1
#define BATTLE_ENEMY_TURN 2
#define BATTLE_WIN 3
#define BATTLE_LOSE 4
#define BATTLE_RUN 5

UINT8 currentState = STATE_INTRO;
UINT8 subState = 0;
UINT8 cursorIndex = 0; // 0=Fight, 1=Run

UINT8 playerX = 8;
UINT8 playerY = 8;
UINT8 spriteX = 0;
UINT8 spriteY = 0;

typedef struct {
    char name[12];
    INT16 hp;
    INT16 maxHP;
    UINT8 str;
    UINT8 def;
    UINT8 level;
    UINT16 exp;
    UINT16 nextLevelExp;
} Entity;

Entity player;
Entity enemy;

// Enemies Database
const Entity SlimeData =  {"SLIME", 10, 10, 4, 1, 1, 5, 0};
const Entity BatData =    {"BAT",   8,  8,  5, 0, 1, 8, 0};

// Helper: Custom string drawer for Window Layer
void draw_win_text(UINT8 x, UINT8 y, char *str) {
    UINT8 len = strlen(str);
    unsigned char tiles[20];
    UINT8 i;
    for(i=0; i<len; i++) {
        tiles[i] = str[i] + 0; 
    }
    set_win_tiles(x, y, len, 1, tiles);
}

// Helper: Custom string drawer for Background Layer
void draw_bkg_text(UINT8 x, UINT8 y, char *str) {
    UINT8 len = strlen(str);
    unsigned char tiles[20];
    UINT8 i;
    for(i=0; i<len; i++) {
        tiles[i] = str[i] + 0; 
    }
    set_bkg_tiles(x, y, len, 1, tiles);
}

void clear_win() {
    fill_win_rect(0, 0, 20, 18, 0); 
}

void draw_frame() {
    // FFL Style Frame on Window
    unsigned char top[20];
    UINT8 i;
    top[0] = 134; // TL
    for(i=1;i<19;i++) top[i] = 135; // T
    top[19] = 136; // TR
    set_win_tiles(0, 0, 20, 1, top);
    
    unsigned char bot[20];
    bot[0] = 139; // BL
    for(i=1;i<19;i++) bot[i] = 140; // B
    bot[19] = 141; // BR
    set_win_tiles(0, 3, 20, 1, bot);
    
    unsigned char sideL[] = {137, 137};
    unsigned char sideR[] = {138, 138};
    set_win_tiles(0, 1, 1, 2, sideL);
    set_win_tiles(19, 1, 1, 2, sideR);
    
    fill_win_rect(1, 1, 18, 2, 0); 
}

void SetupGraphics() {
    // Load Game Tiles at offset 128
    // We have 18 tiles (0-17) now
    set_bkg_data(128, 18, GameTiles); 
    set_sprite_data(128, 18, GameTiles);
    
    SHOW_BKG;
    SHOW_SPRITES;
    SHOW_WIN;
    DISPLAY_ON;
}

void ResetPlayer() {
    player.maxHP = 20;
    player.hp = player.maxHP;
    player.str = 5;
    player.def = 2;
    player.level = 1;
    player.exp = 0;
    player.nextLevelExp = 50;
    
    playerX = 8;
    playerY = 8;
}

void InitTitle() {
    HIDE_WIN;
    HIDE_SPRITES;
    fill_bkg_rect(0, 0, 20, 18, 0); // Clear BKG
    
    draw_bkg_text(5, 5, "LEGEND OF");
    
    // Draw Big Logo "DOOM" manually using tiles 143, 144, 145 (15,16,17 + 128)
    // 15->143 (D), 16->144 (O), 17->145 (M)
    // "D O O M"
    unsigned char logo[] = {143, 0, 144, 144, 0, 145}; // D O O M with spaces? No, let's keep it tight.
    // 143, 144, 144, 145
    unsigned char d[] = {143};
    unsigned char o[] = {144};
    unsigned char m[] = {145};
    
    // Draw Scale: just single tiles for now as per minimal polish plan
    set_bkg_tiles(8, 7, 1, 1, d);
    set_bkg_tiles(9, 7, 1, 1, o);
    set_bkg_tiles(10, 7, 1, 1, o);
    set_bkg_tiles(11, 7, 1, 1, m);
    
    draw_bkg_text(6, 12, "PRESS START");
    
    // Configurable Cursor for Title? Just static for now
    // Sword Cursor is tile 14 (14+128=142)
    unsigned char cursor[] = {142}; 
    set_bkg_tiles(5, 12, 1, 1, cursor);
    
    draw_bkg_text(4, 16, "(C) 2025 AB");
}

void InitGame() {
    SHOW_WIN;
    SHOW_SPRITES;
    move_win(7, 112);
    
    // Reset map position and sprite
    set_sprite_tile(0, 129); // 1+128
    spriteX = playerX * 8 + 8;
    spriteY = playerY * 8 + 16;
    move_sprite(0, spriteX, spriteY);
    set_bkg_tiles(0, 0, 20, 18, WorldMap);
    
    draw_frame();
    draw_win_text(1, 1, "Welcome!          ");
    draw_win_text(1, 2, "                  ");
}

UBYTE check_collision(UINT8 newX, UINT8 newY) {
    UINT16 tileIndex = newY * 20 + newX;
    if (WorldMap[tileIndex] == 130) return 1; // Wall (2 + 128 = 130)
    if (WorldMap[tileIndex] == 131) return 0; // Chest (3 + 128 = 131)
    return 0;
}

void main() {
    UINT8 keys;
    UINT8 prevKeys = 0;
    UINT16 seed = 0;
    
    SetupGraphics();
    InitTitle();
    
    while(1) {
        keys = joypad();
        seed++;

        switch(currentState) {
            case STATE_INTRO:
                if (keys & J_START) {
                    initrand(seed);
                    ResetPlayer();
                    InitGame();
                    currentState = STATE_OVERWORLD;
                    wait_vbl_done();
                    delay(300);
                } 
                break;

            case STATE_OVERWORLD:
                if (keys & J_UP && !(prevKeys & J_UP)) {
                    if (!check_collision(playerX, playerY - 1)) playerY--;
                }
                if (keys & J_DOWN && !(prevKeys & J_DOWN)) {
                    if (!check_collision(playerX, playerY + 1)) playerY++;
                }
                if (keys & J_LEFT && !(prevKeys & J_LEFT)) {
                    if (!check_collision(playerX - 1, playerY)) playerX--;
                }
                if (keys & J_RIGHT && !(prevKeys & J_RIGHT)) {
                    if (!check_collision(playerX + 1, playerY)) playerX++;
                }

                // Update Sprite
                spriteX = playerX * 8 + 8;
                spriteY = playerY * 8 + 16;
                move_sprite(0, spriteX, spriteY);

                if ((keys & (J_UP|J_DOWN|J_LEFT|J_RIGHT)) && !(prevKeys & (J_UP|J_DOWN|J_LEFT|J_RIGHT))) {
                     if ((rand() & 0xFF) < 20) { 
                         currentState = STATE_BATTLE;
                         subState = BATTLE_WAIT_INPUT;
                         cursorIndex = 0;
                         delay(200);
                         
                         draw_frame();
                         
                         // Setup Enemy
                         UINT8 r = rand() & 3;
                         if (r == 0) enemy = BatData;
                         else enemy = SlimeData;
                         
                         enemy.maxHP += (player.level-1)*2;
                         enemy.hp = enemy.maxHP;
                         enemy.str += player.level/2;

                         UINT8 tile = (r == 0) ? 133 : 132; // Bat=5+128=133, Slime=4+128=132
                         set_sprite_tile(1, tile);
                         move_sprite(1, 80, 60);
                         SHOW_SPRITES;
                         
                         draw_win_text(1, 1, "MONSTER ATTACKS!  ");
                         draw_win_text(1, 2, "                  ");
                     }
                }
                break;

            case STATE_BATTLE:
                char buf[20];
                
                if (subState == BATTLE_WAIT_INPUT) {
                     sprintf(buf, "HP:%d/%d  FIGHT", player.hp, player.maxHP);
                     draw_win_text(1, 1, buf);
                     sprintf(buf, "LV:%d     RUN  ", player.level);
                     draw_win_text(1, 2, buf);
                     
                     // Cursor using Sword (Tile 14+128=142) or Space
                     unsigned char cursorTile = 142;
                     unsigned char spaceTile = 0; // or 32
                     unsigned char cTile[] = {cursorTile};
                     unsigned char sTile[] = {' '}; // Space

                     // Draw Cursor manually to avoid string conversion issues with raw tile ID 142
                     set_win_tiles(9, 1, 1, 1, cursorIndex==0 ? cTile : sTile);
                     set_win_tiles(9, 2, 1, 1, cursorIndex==1 ? cTile : sTile);
                    
                    if (keys & J_DOWN && !(prevKeys & J_DOWN)) cursorIndex = 1;
                    if (keys & J_UP && !(prevKeys & J_UP)) cursorIndex = 0;
                    
                    if (keys & J_A && !(prevKeys & J_A)) {
                        if (cursorIndex == 0) subState = BATTLE_ATTACK;
                        else subState = BATTLE_RUN;
                    }
                }
                else if (subState == BATTLE_ATTACK) {
                    INT16 dmg = (INT16)player.str - (INT16)enemy.def + (rand() & 3);
                    if (dmg < 1) dmg = 1;
                    enemy.hp -= dmg;
                    
                    sprintf(buf, "Hit for %d dmg!    ", dmg);
                    draw_win_text(1, 1, buf);
                    draw_win_text(1, 2, "                  ");
                    delay(500);
                    
                    if (enemy.hp <= 0) subState = BATTLE_WIN;
                    else subState = BATTLE_ENEMY_TURN;
                }
                else if (subState == BATTLE_RUN) {
                    if ((rand() & 0xFF) > 100) {
                        draw_win_text(1, 1, "Got away!         ");
                        delay(1000);
                        currentState = STATE_OVERWORLD;
                        InitGame(); 
                    } else {
                        draw_win_text(1, 1, "Can't run!        ");
                        delay(500);
                        subState = BATTLE_ENEMY_TURN;
                    }
                }
                else if (subState == BATTLE_ENEMY_TURN) {
                    INT16 dmg = (INT16)enemy.str - (INT16)player.def + (rand() & 1);
                    if (dmg < 0) dmg = 0;
                    player.hp -= dmg;
                    sprintf(buf, "%s hits %d!     ", enemy.name, dmg);
                    draw_win_text(1, 1, buf);
                    delay(500);
                    
                    if (player.hp <= 0) subState = BATTLE_LOSE;
                    else {
                        subState = BATTLE_WAIT_INPUT;
                    }
                }
                else if (subState == BATTLE_WIN) {
                    sprintf(buf, "Victory! +%d XP   ", enemy.exp);
                    draw_win_text(1, 1, buf);
                    
                    player.exp += enemy.exp;
                    if (player.exp >= player.nextLevelExp) {
                        player.level++;
                        player.maxHP += 5;
                        player.str++;
                        player.def++;
                        player.hp = player.maxHP;
                        player.nextLevelExp *= 2; 
                        delay(1000);
                        draw_win_text(1, 1, "LEVEL UP!         ");
                    }
                    delay(1000);
                    currentState = STATE_OVERWORLD;
                    InitGame();
                }
                else if (subState == BATTLE_LOSE) {
                    draw_win_text(1, 1, "SLAIN...          ");
                    delay(2000);
                    InitTitle(); // Back to title on death
                    currentState = STATE_INTRO;
                }
                break;
        }
        
        wait_vbl_done();
    }
}
