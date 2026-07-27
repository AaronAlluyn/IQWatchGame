import Toybox.Lang;
import Toybox.Graphics;

(:EncounterDefinitions)
module EncounterDefinitions {

    enum BarBehaviorType {
        ATTACK_NORMAL,
        ATTACK_ARMORED,
        ATTACK_MOVING,
        MODIFIER_REVERSE_INDICATOR,
        MODIFIER_SPEED_UP_INDICATOR,
        SPECIAL_STICKY_ZONE,
        SPECIAL_GROWING_BOMB
    }

    function getFightProfiles() as Dictionary {
        return {
            :SLIME_ENCOUNTER => {
                :enemyName => "Green Slime",
                :maxEnemyHP => 4,
                :backgroundColor => 0x001A00,
                :enemyBarColor => Graphics.COLOR_GREEN,
                :playerBarColor => Graphics.COLOR_WHITE,
                :hazardBarColor => Graphics.COLOR_YELLOW,

                :indicatorBaseSpeed => 60.0f,
                :indicatorMaxSpeed => 90.0f,

                :playerBarWidthMin => 45,
                :playerBarWidthMax => 80,
                :playerBarShrinkMin => 6,
                :playerBarShrinkMax => 10,

                :minPlayerBars => 1,
                :maxPlayerBars => 2,
                :minEnemyBars => 1,
                :maxEnemyBars => 2,

                :enemyBarWidthMin => 50,
                :enemyBarWidthMax => 80,
                :enemyBarShrinkMin => 6,
                :enemyBarShrinkMax => 10,

                :enemyBarMoveChance => 0.0f,
                :enemyBarRotationSpeedMin => 0.0f,
                :enemyBarRotationSpeedMax => 0.0f,

                :hazardBarWidthMin => 30,
                :hazardBarWidthMax => 60,
                :hazardBarShrinkMin => 8,
                :hazardBarShrinkMax => 14,
                :hazardSpawnChance => 0.0f,
                :stickyZoneChance => 0.0f,
                :missPenaltyFreezeDuration => 0.20f
            },
            :KNIGHT_ENCOUNTER => {
                :enemyName => "Iron Knight",
                :maxEnemyHP => 5,
                :backgroundColor => 0x0A1520, // High-contrast Dark Navy Blue background
                :enemyBarColor => Graphics.COLOR_BLUE, // Vibrant Steel Blue bars for clear contrast
                :playerBarColor => Graphics.COLOR_WHITE,
                :hazardBarColor => Graphics.COLOR_YELLOW,

                :indicatorBaseSpeed => 65.0f, // Relaxed pacing
                :indicatorMaxSpeed => 95.0f,

                :playerBarWidthMin => 50,
                :playerBarWidthMax => 80,
                :playerBarShrinkMin => 5,
                :playerBarShrinkMax => 9,

                :minPlayerBars => 1,
                :maxPlayerBars => 2,
                :minEnemyBars => 1,
                :maxEnemyBars => 2,

                :enemyBarWidthMin => 55,
                :enemyBarWidthMax => 85,
                :enemyBarShrinkMin => 5,
                :enemyBarShrinkMax => 9,

                :enemyBarMoveChance => 0.0f,
                :enemyBarRotationSpeedMin => 0.0f,
                :enemyBarRotationSpeedMax => 0.0f,

                :hazardBarWidthMin => 30,
                :hazardBarWidthMax => 60,
                :hazardBarShrinkMin => 6,
                :hazardBarShrinkMax => 10,
                :hazardSpawnChance => 5.0f,
                :stickyZoneChance => 0.0f,
                :missPenaltyFreezeDuration => 0.20f
            },
            :NINJA_ENCOUNTER => {
                :enemyName => "Shadow Ninja",
                :maxEnemyHP => 5,
                :backgroundColor => 0x050515,
                :enemyBarColor => Graphics.COLOR_PURPLE,
                :playerBarColor => Graphics.COLOR_WHITE,
                :hazardBarColor => Graphics.COLOR_YELLOW,

                :indicatorBaseSpeed => 80.0f,
                :indicatorMaxSpeed => 120.0f,

                :playerBarWidthMin => 40,
                :playerBarWidthMax => 70,
                :playerBarShrinkMin => 8,
                :playerBarShrinkMax => 14,

                :minPlayerBars => 1,
                :maxPlayerBars => 2,
                :minEnemyBars => 1,
                :maxEnemyBars => 3,

                :enemyBarWidthMin => 45,
                :enemyBarWidthMax => 75,
                :enemyBarShrinkMin => 8,
                :enemyBarShrinkMax => 14,

                :enemyBarMoveChance => 60.0f,
                :enemyBarRotationSpeedMin => -30.0f,
                :enemyBarRotationSpeedMax => 30.0f,

                :hazardBarWidthMin => 30,
                :hazardBarWidthMax => 60,
                :hazardBarShrinkMin => 8,
                :hazardBarShrinkMax => 14,
                :hazardSpawnChance => 10.0f,
                :stickyZoneChance => 0.0f,
                :missPenaltyFreezeDuration => 0.20f
            },
            :SLIME_BOSS_ENCOUNTER => {
                :enemyName => "King Slime",
                :maxEnemyHP => 10,
                :backgroundColor => 0x110033, // Phase 1 Dark Purple
                :phase2BackgroundColor => 0x330011, // Phase 2 Crimson Enrage
                :enemyBarColor => Graphics.COLOR_PURPLE,
                :playerBarColor => Graphics.COLOR_WHITE,
                :hazardBarColor => Graphics.COLOR_ORANGE,

                :indicatorBaseSpeed => 70.0f,
                :phase2IndicatorSpeed => 105.0f,
                :indicatorMaxSpeed => 140.0f,

                :playerBarWidthMin => 35,
                :playerBarWidthMax => 70,
                :playerBarShrinkMin => 8,
                :playerBarShrinkMax => 16,

                :minPlayerBars => 1,
                :maxPlayerBars => 2,
                :minEnemyBars => 2,
                :maxEnemyBars => 4,

                :enemyBarWidthMin => 45,
                :enemyBarWidthMax => 85,
                :enemyBarShrinkMin => 8,
                :enemyBarShrinkMax => 16,

                :enemyBarMoveChance => 30.0f,
                :enemyBarRotationSpeedMin => -25.0f,
                :enemyBarRotationSpeedMax => 25.0f,

                :hazardBarWidthMin => 30,
                :hazardBarWidthMax => 60,
                :hazardBarShrinkMin => 8,
                :hazardBarShrinkMax => 16,
                :hazardSpawnChance => 15.0f,
                :stickyZoneChance => 30.0f,
                :missPenaltyFreezeDuration => 0.35f
            },
            :TEST_ENCOUNTER => {
                :enemyName => "Training Dummy",
                :maxEnemyHP => 6,
                :backgroundColor => Graphics.COLOR_BLACK,
                :enemyBarColor => Graphics.COLOR_RED,
                :playerBarColor => Graphics.COLOR_WHITE,
                :hazardBarColor => Graphics.COLOR_YELLOW,

                :indicatorBaseSpeed => 70.0f,
                :indicatorMaxSpeed => 90.0f,

                :playerBarWidthMin => 60,
                :playerBarWidthMax => 60,
                :playerBarShrinkMin => 8,
                :playerBarShrinkMax => 8,

                :minPlayerBars => 1,
                :maxPlayerBars => 1,
                :minEnemyBars => 1,
                :maxEnemyBars => 1,

                :enemyBarWidthMin => 60,
                :enemyBarWidthMax => 60,
                :enemyBarShrinkMin => 8,
                :enemyBarShrinkMax => 8,

                :enemyBarMoveChance => 0.0f,
                :enemyBarRotationSpeedMin => 0.0f,
                :enemyBarRotationSpeedMax => 0.0f,

                :hazardBarWidthMin => 30,
                :hazardBarWidthMax => 60,
                :hazardBarShrinkMin => 10,
                :hazardBarShrinkMax => 10,
                :hazardSpawnChance => 0.0f,
                :stickyZoneChance => 0.0f,
                :missPenaltyFreezeDuration => 0.20f
            }
        };
    }
}