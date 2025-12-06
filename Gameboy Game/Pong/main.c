#include <gb/gb.h>
#include <stdio.h>
#include <gbdk/console.h>

// Game constants
#include "music.h"
#include "backgrounds.h"

#define SCREEN_WIDTH 160
#define SCREEN_HEIGHT 144
#define PADDLE_X 10
#define PADDLE_HEIGHT 24
#define BALL_SIZE 8

// Global variables
UINT8 paddle_y = 60;
UINT8 ball_x = 80;
UINT8 ball_y = 72;
INT8 ball_dx = 1;
INT8 ball_dy = 1;
UINT8 score = 0;

// Sprite tiles (simple block for paddle and ball)
const unsigned char sprite_tiles[] = {
    0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
    0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
};

void setup() {
    // Load sprite data
    set_sprite_data(0, 1, sprite_tiles);

    // Setup paddle sprite (using 3 sprites for height)
    set_sprite_tile(0, 0);
    set_sprite_tile(1, 0);
    set_sprite_tile(2, 0);

    // Setup ball sprite
    set_sprite_tile(3, 0);

    // Show sprites
    SHOW_SPRITES;
    SHOW_BKG;
    DISPLAY_ON;
}

void process_input() {
    UINT8 keys = joypad();
    if (keys & J_UP) {
        if (paddle_y > 16) paddle_y -= 2;
    }
    if (keys & J_DOWN) {
        if (paddle_y < SCREEN_HEIGHT - PADDLE_HEIGHT + 8) paddle_y += 2;
    }
}

void update_ball() {
    ball_x += ball_dx;
    ball_y += ball_dy;

    // Wall collisions
    if (ball_x >= SCREEN_WIDTH - 8) {
        ball_dx = -ball_dx; // Bounce off right wall
    }
    if (ball_y <= 16 || ball_y >= SCREEN_HEIGHT) {
        ball_dy = -ball_dy; // Bounce off top/bottom
    }

    // Paddle collision
    if (ball_x <= PADDLE_X + 8 && ball_x >= PADDLE_X) {
        if (ball_y + 8 >= paddle_y && ball_y <= paddle_y + PADDLE_HEIGHT) {
            ball_dx = -ball_dx;
            score++;
            
            // Check for background change
            if (score % 10 == 0) {
                set_background_pattern(score / 10);
            }

            // Simple beep
            NR10_REG = 0x00;
            NR11_REG = 0x81;
            NR12_REG = 0x43;
            NR13_REG = 0x73;
            NR14_REG = 0x86;
            
            // Update score display
            gotoxy(0, 0);
            printf("Score: %u", score);
        }
    }

    // Game over (ball goes past paddle)
    if (ball_x < PADDLE_X - 5) {
        // Reset ball
        ball_x = 80;
        ball_y = 72;
        ball_dx = 1;
        score = 0;
        
        // Reset score display
        gotoxy(0, 0);
        printf("Score: %u", score);
    }
}

void draw() {
    // Move paddle sprites
    move_sprite(0, PADDLE_X, paddle_y);
    move_sprite(1, PADDLE_X, paddle_y + 8);
    move_sprite(2, PADDLE_X, paddle_y + 16);

    // Move ball sprite
    move_sprite(3, ball_x, ball_y);
}

void main() {
    setup();

    // Init music and backgrounds
    init_music();
    init_backgrounds();
    set_background_pattern(0);
    
    // Initial score
    gotoxy(0, 0);
    printf("Score: 0");
    
    // Enable sound
    NR52_REG = 0x80;
    NR50_REG = 0x77;
    NR51_REG = 0xFF;

    while(1) {
        process_input();
        update_ball();
        update_music();
        draw();
        
        // Simple delay to control speed
        wait_vbl_done();
        // delay(20);
    }
}
