# Enhanced Brutal Pong Game Features

## Implemented Features

### Player Movement
- **WASD Controls**: W/S for up/down, A/D for left/right movement
- **Middle Line Restriction**: Player cannot cross the middle line (x=500)
- **Enhanced Paddle**: Can move in all directions within their court

### Distance Attack System
- **Left Click Mechanics**:
  - Horizontal attacks: Hold left click to continuously attack
  - Vertical attacks: Single click required for up/down attacks
- **Attack Range**: 100 pixel radius from player
- **Force Application**: Applies directional force to the ball

### Ball Physics Improvements
- **Force System**: External forces can be applied to change trajectory
- **Speed Management**: Ball speed clamped between 300-1200 units
- **Improved Collision**: Better paddle interaction and trajectory changes
- **Anti-Reset**: Scoring only occurs at true edges (-50, 1050) to prevent constant resets

### Trap Systems

#### Spike Traps
- **Random Spawning**: Every 3 seconds in middle court area
- **Trajectory Effect**: Dramatically changes ball direction on collision
- **Player Damage**: Causes player to lose a life on contact
- **Auto-Remove**: Disappears after 8 seconds

#### Wall Traps (Flame Traps)
- **Random Walls**: Spawn on any of the 4 walls (left, right, top, bottom)
- **Flame Visual**: Orange colored flame effect
- **Player Damage**: Causes life loss on player contact
- **Duration**: Active for 3 seconds before disappearing

### Round System
- **Timer**: 60-second rounds
- **Round End**: Automatically transitions to shop when timer expires
- **Lives System**: Player starts with 3 lives

### Shop System
- **Currency**: Earned based on performance (10 + 5 per point scored)
- **Items Available**:
  - Extra Life (50 coins): Adds one life
  - Shield (30 coins): 10 seconds of trap protection
  - Speed Boost (40 coins): 1.5x movement speed for 15 seconds
  - Attack Power (35 coins): 2x attack force for 20 seconds
- **Temporary Effects**: Boosts automatically expire after duration

### Visual Enhancements
- **Middle Line**: Semi-transparent white line dividing the court
- **UI Elements**: Lives counter, round timer
- **Trap Visuals**: Red spikes, orange flame traps

## Game Controls
- **W/A/S/D**: Player movement (W=up, A=left, S=down, D=right)
- **Left Click**: Distance attacks (hold for horizontal, click for vertical)
- **Shop Navigation**: Click buttons to purchase items

## Game Flow
1. Round starts with 60-second timer
2. Player can move and attack ball with WASD and left click
3. Spike and wall traps spawn randomly and threaten the player
4. Round ends when timer expires → Shop opens
5. Player can purchase upgrades with earned currency
6. New round begins after shop closes
7. Game over when player loses all lives

## Technical Notes
- Ball trajectory affected by spikes, distance attacks, and paddle collisions
- Player movement restricted to left side of court (cannot cross middle line)
- Shield provides temporary immunity to all trap damage
- All boosts have visual feedback through console messages
- Trap spawning uses random positioning within safe zones