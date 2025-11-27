# Iron Havoc Dev Tasks

Things I have to achieve or have achieved.

## Version 0.0.6

### Completed (08:46 - 27/11/25)

Started implementing powerups. Currently, there is just a health restore powerup.

## Version 0.0.5

### Completed (18:43 - 26/11/25)

Add particle effects for bullet hits and tank explosions; implement bot spawner

- Created `bullet_hit_particles.gd` for bullet impact effects with debris emission.
- Developed `tank_explosion.gd` to manage tank explosion effects, including fire and smoke particles.
- Added corresponding scene files for tank explosions and bot spawner.
- Implemented `bot_spawner.gd` to handle bot instantiation with configurable spawn intervals and limits.

## Version 0.0.4

### Expectation (16:58 - 25/11/25)

- Started to implement navigation, so I expect to finish or improve.
- Adding bot decisions and shooting.

### Completed (16:58 - 25/11/25)

- The bot decisions are now better. Can chase, shoot, strafe or runaway (Tasks).

## Version 0.0.3

### Expectation (16:51 - 22/11/25)

- Started to implement navigation, so I expect to finish or improve.
- Adding bot decisions and shooting.

### Completed (22:07 - 23/11/25)

#### Adds bot AI decision system and refactors player logic

Introduces a behavior tree-based AI for bots, enabling movement, aiming, and shooting decisions.
Refactors player and bot movement, aiming, and shooting into modular actions for easier control and future extensibility.
Improves tank inheritance and streamlines user and bot player scenes for better maintainability.
Lays groundwork for scalable AI and user control strategies.

## Version 0.0.2

### Completed (16:48 - 22/11/25)

- Modulated so that tanks and players are separate entities.
- Added shooting and particles on hit.
