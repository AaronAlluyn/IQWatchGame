# Radial Rogue

A 360-degree precision action roguelite designed exclusively for **Garmin Connect IQ smartwatches**, built in Monkey C.

The game centers around a rotating needle spinning around a 360° circular track. Gameplay relies on timing single taps when the spinning indicator aligns with target arcs on the watch face.

### Combat Bars

* **Player Action Bars**: Target arcs tapped to execute player attacks to deal damage to enemies and build combo streaks.
* **Enemy Action Bars**: Target arcs tapped to parry or block incoming enemy attacks, mitigating damage and triggering passive relic counters.
* **Click-Trigger Modifier Bars**: Reactive hazard arcs that trigger instant game mechanics upon being clicked (such as reversing indicator spin direction, triggering speed surges, or resetting combos).
* **Passive Overlap Zones**: Environmental arcs that apply effects continuously whenever the indicator needle passes over them without requiring a tap (such as quicksand zones that slow indicator speed).

### Boss Fight Features
Boss encounters introduce multi-phase mechanics:
* **Enrage & Phase Transitions**: Bosses alter their behavior dynamically as health drops below key thresholds.
* **Environmental Shift**: Phase changes trigger visual background color shifts and screen shake.
* **Dynamic Speed Escalation**: Spin speeds accelerate dynamically as boss health depletes.
* **Custom Modifier Patterns**: Bosses combine movement bars, sticky zones, and directional hazards simultaneously.

## Dungeon Progression & Economy

Dungeon runs consist of randomized procedural paths leading to a boss encounter at the end of each floor. Players navigate branching choices to manage their health, currency, and powerups.

### Dungeon Node Types
* **Combat Encounters**: Battle against unique enemy archetypes with distinct movement patterns and movesets.
* **Dungeon Choice Nodes**: Present choices allowing players to enter a Shop, earn relics or gold in a Minigame, or go forward to the next encounter.
* **Shops**: Multi-purchase merchant nodes featuring consumable items and permanent stat upgrades.
* **Minigame Nodes**: Time-based reflex challenges offering bonus coins or relic rewards.
* **Boss Nodes**: Floor-ending encounters that unlock Relic Rewards upon victory.

### Relics
Defeating floor bosses or mastering minigames awards passive Relics that modify core combat rules for the remainder of the run:
* **Vampire Tooth**: Heals 1 HP for every 5 successful attacks landed.
* **Golden Horseshoe**: Grants a +50\% bonus gold multiplier on all earned gold.
* **Parry Shield**: Momentarily freezes the indicator needle for 0.40 seconds upon a successful block.

### Shop Inventory
The shop pool features replenishing consumable and permanent stat upgrades:
* **Heal 2 HP**: Restores 2 HP.
* **Heal 4 HP**: Restores 4 HP.
* **+2 Max HP**: Permanently increases maximum player HP capacity by 2 HP.

### Minigames & Reward Tiers
Minigames offer skill-based challenges outside of standard combat:
* **Vault Lockpicker**: A 3-stage tumbler timing challenge requiring precise hits on shrinking target arcs with limited pick attempts.
* **Rune Pulse**: A 10-second reflex blitz testing how many forward-spawning targets the player can hit before time expires.
* **Glyph Memory**: A 3-round Simon-Says radial pattern memory challenge where players watch sequence patterns flash before repeating them.

**Reward Structure**:
* **Flawless Victory**: Unlocks a Relic Choice offering a selection of relics.
* **Partial Success**: Grants gold payouts scaled to player performance.
* **Failure**: Minimal gold payout.

## Data Persistence & Lifetime Records

The game automatically persists active run states and lifetime metrics to smartwatch storage:

* **Mid-Run Resume**: Active run state (player HP, max HP, floor, step, coins, and equipped relic) automatically saves whenever an encounter completes or when exiting the application. Tapping **CONTINUE** on the Main Menu restores the exact mid-run state.
* **Lifetime Records Tracked**:
  * **Best Floor**: Highest floor cleared across all runs.
  * **Best Gold**: Most gold earned in a single run.
  * **Best Streak**: Longest uninterrupted hit combo streak achieved.
  * **Boss Kills**: Total boss encounters defeated across all runs.
  * **Total Runs**: Total runs started.

## System Architecture & Design Principles

* **State Machine Pattern**: Clean separation of game flow states (Menu, Combat, Shop, Minigames, Results, Death, Records) managed by a central state router.
* **Decoupled Engine Core**: Radial physics, polar collision detection, object pooling, and animation tweening operate independently of game rules.
* **Zero-Allocation Object Pool**: Reuses fixed arrays of radial target bars to eliminate garbage collection pauses on resource-constrained watch hardware.
* **Unified UI Utilities**: Centralized UI components to minimise code duplication and help keep design lanuage consistent.
* **Adding New Enemies & Movesets**: Defined entirely through data profiles specifying movement speeds, bar widths, shrink rates, moveset colors, and phase transitions.
* **Adding New Minigames**: Plug-and-play architecture allows new minigame states to be registered directly into the modular minigame router pool.
* **Adding New Relics & Shop Items**: Event-driven relic hooks allow new passive items to register handlers for combat events (onHit, onBlock, onDamage) without altering combat loop logic.


## Supported Devices

* **Garmin Forerunner 165**
* **Garmin Forerunner 255 Music**
* **Garmin Venu 2S**
* **Garmin Vivoactive 5**

## Development & Deployment

### Development Setup
1. Open the project folder in **VS Code**.
2. Ensure the **Garmin Connect IQ Extension** for VS Code is installed.
3. Press `F5` (or `Ctrl + F5`) to launch the project in the **Connect IQ Simulator**.
4. Select a target device profile (e.g. Forerunner 255 Music, Forerunner 165) when prompted.

### Building and Deploying to Device Hardware
1. Open the VS Code Command Palette (`Ctrl + Shift + P` on Windows/Linux or `Cmd + Shift + P` on macOS).
2. Run `Monkey C: Build for Device`.
3. Select your target device and destination output folder to generate the compiled `.prg` binary file.
4. Connect your Garmin smartwatch to your computer via USB.
5. Copy the compiled `.prg` file into the `GARMIN/APPS/` directory on the watch.
6. Disconnect the watch. The app will be available in the device activity/app launcher menu.