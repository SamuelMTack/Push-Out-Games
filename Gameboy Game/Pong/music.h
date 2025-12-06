#ifndef MUSIC_H
#define MUSIC_H

#include <gb/gb.h>

// Simple note structure
typedef struct {
    UWORD frequency;
    UINT8 duration;
} Note;

// Frequencies for C4 major scale
#define NOTE_C4 262
#define NOTE_D4 294
#define NOTE_E4 330
#define NOTE_F4 349
#define NOTE_G4 392
#define NOTE_A4 440
#define NOTE_B4 494
#define NOTE_C5 523

// Music state
const Note melody[] = {
    {NOTE_C4, 10}, {0, 2}, {NOTE_E4, 10}, {0, 2}, {NOTE_G4, 10}, {0, 2}, 
    {NOTE_E4, 10}, {0, 2}, {NOTE_G4, 10}, {0, 2}, {NOTE_B4, 10}, {0, 2},
    {NOTE_C5, 20}, {0, 10}
};
const UINT8 melody_length = 14; 

UINT8 current_note_index = 0;
UINT8 notes_timer = 0;


void init_music() {
    NR52_REG = 0x80; // Turn on sound handling
    NR50_REG = 0x77; // Master volume max
    NR51_REG = 0xFF; // Enable all channels
    
    NR21_REG = 0x81; // Duty cycle 50%
    NR22_REG = 0x73; // Volume envelope
    NR24_REG = 0x87; // Trigger
}

// Map frequency to Gameboy register value (approximate)
// Formula: x = 2048 - (131072 / freq)
UWORD freq_to_reg(UWORD freq) {
    if (freq == 0) return 0;
    return (2048 - (131072 / freq));
}

void update_music() {
    if (notes_timer == 0) {
        Note* note = &melody[current_note_index];
        notes_timer = note->duration;

        if (note->frequency > 0) {
            UWORD freq_reg = freq_to_reg(note->frequency);
            NR23_REG = (UINT8)(freq_reg & 0xFF);
            NR24_REG = 0x80 | (UINT8)((freq_reg >> 8) & 0x07); // Restart sound
        } else {
            // Rest
           // NR22_REG = 0x00; // Mute
           // Actually just not re-triggering might be enough or set vol to 0
        }

        current_note_index++;
        if (current_note_index >= melody_length) {
            current_note_index = 0;
        }
    } else {
        notes_timer--;
    }
}

#endif
