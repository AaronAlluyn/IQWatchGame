import Toybox.Lang;
import Toybox.Application.Storage;

// Tracks persistent state for a single roguelite run, mid-run save/resume, and permanent lifetime statistics.
class RunContext {
    public const DEFAULT_STARTING_MAX_HP = 4;

    public var playerHP as Number = 4;
    public var maxPlayerHP as Number = 4;
    public var coins as Number = 0;
    public var floorsCleared as Number = 0;
    public var damageDealt as Number = 0;
    public var coinsEarned as Number = 0;

    public var currentStreak as Number = 0;
    public var bestStreak as Number = 0;

    // Equipped Relic
    public var activeRelic as Symbol or Null = null;
    private var _relicHitCounter as Number = 0;

    // Permanent High Scores & Lifetime Stats
    public var highFloor as Number = 0;
    public var highCoins as Number = 0;
    public var lifetimeRuns as Number = 0;
    public var bossesKilled as Number = 0;
    public var bestStreakLifetime as Number = 0;

    public var isNewHighFloor as Boolean = false;
    public var isNewHighCoins as Boolean = false;

    function initialize() {
        loadHighScores();
        resetRun();
    }

    public function loadHighScores() as Void {
        try {
            var savedFloor = Storage.getValue("high_floor");
            if (savedFloor != null && savedFloor instanceof Number) {
                highFloor = savedFloor as Number;
            }
            var savedCoins = Storage.getValue("high_coins");
            if (savedCoins != null && savedCoins instanceof Number) {
                highCoins = savedCoins as Number;
            }
            var savedRuns = Storage.getValue("lifetime_runs");
            if (savedRuns != null && savedRuns instanceof Number) {
                lifetimeRuns = savedRuns as Number;
            }
            var savedBosses = Storage.getValue("bosses_killed");
            if (savedBosses != null && savedBosses instanceof Number) {
                bossesKilled = savedBosses as Number;
            }
            var savedStreak = Storage.getValue("best_streak_lifetime");
            if (savedStreak != null && savedStreak instanceof Number) {
                bestStreakLifetime = savedStreak as Number;
            }
        } catch (ex) {
            highFloor = 0;
            highCoins = 0;
            lifetimeRuns = 0;
            bossesKilled = 0;
            bestStreakLifetime = 0;
        }
    }

    public function recordBossKilled() as Void {
        bossesKilled++;
        try {
            Storage.setValue("bosses_killed", bossesKilled);
        } catch (ex) {}
    }

    public function hasActiveSavedRun() as Boolean {
        try {
            var hasRun = Storage.getValue("has_active_run");
            return (hasRun != null && hasRun instanceof Boolean && (hasRun as Boolean) == true);
        } catch (ex) {
            return false;
        }
    }

    public function saveActiveRun(dungeonManager as DungeonManager) as Void {
        try {
            Storage.setValue("has_active_run", true);
            Storage.setValue("run_player_hp", playerHP);
            Storage.setValue("run_max_hp", maxPlayerHP);
            Storage.setValue("run_coins", coins);
            Storage.setValue("run_floors_cleared", floorsCleared);
            Storage.setValue("run_damage_dealt", damageDealt);
            Storage.setValue("run_coins_earned", coinsEarned);
            Storage.setValue("run_current_floor", dungeonManager.getCurrentFloor());
            Storage.setValue("run_current_step", dungeonManager.getCurrentStep());

            if (activeRelic != null) {
                Storage.setValue("run_relic_str", activeRelic.toString());
            } else {
                Storage.deleteValue("run_relic_str");
            }
        } catch (ex) {}
    }

    public function loadActiveRun(dungeonManager as DungeonManager) as Boolean {
        if (!hasActiveSavedRun()) {
            return false;
        }

        try {
            var hp = Storage.getValue("run_player_hp");
            var maxHp = Storage.getValue("run_max_hp");
            var c = Storage.getValue("run_coins");
            var fl = Storage.getValue("run_floors_cleared");
            var dmg = Storage.getValue("run_damage_dealt");
            var earned = Storage.getValue("run_coins_earned");
            var floor = Storage.getValue("run_current_floor");
            var step = Storage.getValue("run_current_step");
            var relicStr = Storage.getValue("run_relic_str");

            if (hp != null) { playerHP = hp as Number; }
            if (maxHp != null) { maxPlayerHP = maxHp as Number; }
            if (c != null) { coins = c as Number; }
            if (fl != null) { floorsCleared = fl as Number; }
            if (dmg != null) { damageDealt = dmg as Number; }
            if (earned != null) { coinsEarned = earned as Number; }

            if (floor != null && step != null) {
                dungeonManager.setFloorAndStep(floor as Number, step as Number);
            }

            if (relicStr != null && relicStr instanceof String) {
                var s = relicStr as String;
                if (s.equals("VAMPIRE_TOOTH") || s.equals(":VAMPIRE_TOOTH")) {
                    activeRelic = :VAMPIRE_TOOTH;
                } else if (s.equals("GOLDEN_HORSESHOE") || s.equals(":GOLDEN_HORSESHOE")) {
                    activeRelic = :GOLDEN_HORSESHOE;
                } else if (s.equals("PARRY_SHIELD") || s.equals(":PARRY_SHIELD")) {
                    activeRelic = :PARRY_SHIELD;
                }
            }
            return true;
        } catch (ex) {
            return false;
        }
    }

    public function clearActiveRun() as Void {
        try {
            Storage.setValue("has_active_run", false);
            Storage.deleteValue("run_player_hp");
            Storage.deleteValue("run_max_hp");
            Storage.deleteValue("run_coins");
            Storage.deleteValue("run_floors_cleared");
            Storage.deleteValue("run_damage_dealt");
            Storage.deleteValue("run_coins_earned");
            Storage.deleteValue("run_current_floor");
            Storage.deleteValue("run_current_step");
            Storage.deleteValue("run_relic_str");
        } catch (ex) {}
    }

    public function recordDeath() as Void {
        clearActiveRun();
        isNewHighFloor = false;
        isNewHighCoins = false;

        if (floorsCleared > highFloor) {
            highFloor = floorsCleared;
            try {
                Storage.setValue("high_floor", highFloor);
            } catch (ex) {}
            isNewHighFloor = true;
        }

        if (coinsEarned > highCoins) {
            highCoins = coinsEarned;
            try {
                Storage.setValue("high_coins", highCoins);
            } catch (ex) {}
            isNewHighCoins = true;
        }
    }

    public function resetRun() as Void {
        lifetimeRuns++;
        try {
            Storage.setValue("lifetime_runs", lifetimeRuns);
        } catch (ex) {}

        maxPlayerHP = DEFAULT_STARTING_MAX_HP;
        playerHP = maxPlayerHP;
        coins = 0;
        floorsCleared = 0;
        damageDealt = 0;
        coinsEarned = 0;
        currentStreak = 0;
        bestStreak = 0;
        activeRelic = null;
        _relicHitCounter = 0;
        isNewHighFloor = false;
        isNewHighCoins = false;
    }

    public function registerHit() as Number {
        currentStreak += 1;
        if (currentStreak > bestStreak) {
            bestStreak = currentStreak;
        }
        if (currentStreak > bestStreakLifetime) {
            bestStreakLifetime = currentStreak;
            try {
                Storage.setValue("best_streak_lifetime", bestStreakLifetime);
            } catch (ex) {}
        }

        var baseReward = (currentStreak >= 3) ? 2 : 1;
        var reward = (baseReward.toFloat() * getCoinBonusMultiplier()).toNumber();
        if (reward < 1) { reward = 1; }
        addCoins(reward);

        if (activeRelic == :VAMPIRE_TOOTH) {
            _relicHitCounter++;
            if (_relicHitCounter >= 5) {
                _relicHitCounter = 0;
                heal(1);
            }
        }

        return reward;
    }

    public function onBlockRelicEffect(radialSystem as RadialSystem) as Void {
        if (activeRelic == :PARRY_SHIELD) {
            radialSystem.freezeIndicator(0.40f);
        }
    }

    public function getCoinBonusMultiplier() as Float {
        if (activeRelic == :GOLDEN_HORSESHOE) {
            return 1.5f;
        }
        return 1.0f;
    }

    public function resetStreak() as Void {
        currentStreak = 0;
    }

    public function heal(amount as Number) as Void {
        playerHP += amount;
        if (playerHP > maxPlayerHP) {
            playerHP = maxPlayerHP;
        }
    }

    public function takeDamage(amount as Number) as Boolean {
        resetStreak();
        playerHP -= amount;
        if (playerHP < 0) {
            playerHP = 0;
        }
        return (playerHP <= 0);
    }

    public function addMaxHP(amount as Number) as Void {
        maxPlayerHP += amount;
        playerHP += amount;
    }

    public function addCoins(amount as Number) as Void {
        if (amount > 0) {
            coins += amount;
            coinsEarned += amount;
        }
    }

    public function spendCoins(amount as Number) as Boolean {
        if (coins >= amount) {
            coins -= amount;
            return true;
        }
        return false;
    }
}
