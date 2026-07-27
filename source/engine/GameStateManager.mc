import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

class GameStateManager {
    private var _radialSystem as RadialSystem;
    private var _runContext as RunContext;
    private var _dungeonManager as DungeonManager;
    private var _tweenManager as TweenManager;
    private var _currentState as State or Null = null;
    private var _frameCount as Long = 0l;

    private var _minigamePool as Array<Symbol>;

    function initialize() {
        _radialSystem = new RadialSystem();
        _runContext = new RunContext();
        _dungeonManager = new DungeonManager();
        _tweenManager = new TweenManager();
        _frameCount = 0l;

        _minigamePool = [:LOCKPICKER, :RUNE_PULSE, :GLYPH_MEMORY];

        switchToMenuState();
    }

    public function saveActiveRun() as Void {
        if (_runContext != null && _dungeonManager != null && !(_currentState instanceof MenuState) && !(_currentState instanceof DeathState) && !(_currentState instanceof StatsState)) {
            _runContext.saveActiveRun(_dungeonManager);
        }
    }

    public function getTweenManager() as TweenManager {
        return _tweenManager;
    }

    public function switchToMenuState() as Void {
        var menuState = new MenuState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = menuState;
        menuState.enter();
    }

    public function switchToStatsState() as Void {
        var statsState = new StatsState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = statsState;
        statsState.enter();
    }

    public function switchToEncounterIntroState() as Void {
        var introState = new EncounterIntroState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = introState;
        introState.enter();
    }

    public function switchToFightState() as Void {
        var fightState = new FightState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = fightState;
        fightState.enter();
    }

    public function switchToShopState() as Void {
        var shopState = new ShopState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = shopState;
        shopState.enter();
    }

    public function switchToDungeonChoiceState() as Void {
        var choiceState = new DungeonChoiceState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = choiceState;
        choiceState.enter();
    }

    public function switchToLockpickerState() as Void {
        var lockState = new LockpickerState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = lockState;
        lockState.enter();
    }

    public function switchToRunePulseState() as Void {
        var pulseState = new RunePulseState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = pulseState;
        pulseState.enter();
    }

    public function switchToGlyphMemoryState() as Void {
        var glyphState = new GlyphMemoryState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = glyphState;
        glyphState.enter();
    }

    public function launchRandomMinigame() as Void {
        if (_minigamePool.size() > 0) {
            var idx = Math.rand() % _minigamePool.size();
            var pick = _minigamePool[idx];
            if (pick == :LOCKPICKER) {
                switchToLockpickerState();
                return;
            } else if (pick == :RUNE_PULSE) {
                switchToRunePulseState();
                return;
            } else if (pick == :GLYPH_MEMORY) {
                switchToGlyphMemoryState();
                return;
            }
        }
        switchToLockpickerState();
    }

    public function showMinigameResult(isWin as Boolean, title as String, summary as String, rewardType as Symbol, coinAmount as Number) as Void {
        var resultState = new MinigameResultState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        resultState.setupResult(isWin, title, summary, rewardType, coinAmount);
        _currentState = resultState;
        resultState.enter();
    }

    public function onMinigameWonRelic() as Void {
        switchToRelicRewardState();
    }

    public function onMinigameWonCoins(amount as Number) as Void {
        if (_runContext != null) {
            _runContext.addCoins(amount);
        }
        onEncounterCleared();
    }

    public function onMinigameFailed() as Void {
        onEncounterCleared();
    }

    public function switchToRelicRewardState() as Void {
        var relicState = new RelicRewardState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = relicState;
        relicState.enter();
    }

    public function switchToDeathState() as Void {
        var deathState = new DeathState(_radialSystem, _runContext, _dungeonManager, _tweenManager, self);
        _currentState = deathState;
        deathState.enter();
    }

    public function onEncounterCleared() as Void {
        _runContext.addCoins(5);
        var profileKey = _dungeonManager != null ? _dungeonManager.getCurrentEncounterKey() : :TEST_ENCOUNTER;
        if (profileKey == :SLIME_BOSS_ENCOUNTER && _runContext != null) {
            _runContext.recordBossKilled();
        }

        var floorCleared = _dungeonManager.advanceStep();
        if (floorCleared) {
            _runContext.floorsCleared += 1;
            _runContext.addCoins(10);
        }

        saveActiveRun();

        if (_dungeonManager.isChoiceStep()) {
            switchToDungeonChoiceState();
        } else {
            switchToEncounterIntroState();
        }
    }

    public function onPlayerDeath() as Void {
        switchToDeathState();
    }

    public function update(deltaTime as Float) as Void {
        _frameCount++;
        _tweenManager.update(deltaTime);

        if (_currentState != null) {
            _currentState.refillBars(_frameCount);
            _radialSystem.update(deltaTime, _frameCount);
            _currentState.update(deltaTime);
        }
    }

    public function handleInput() as Void {
        var hit = _radialSystem.handleInput(_frameCount);
        if (!hit && _currentState != null) {
            _currentState.onEmptySpaceHit();
        }
    }

    public function draw(dc as Dc) as Void {
        var screenDx = _tweenManager.getScreenShakeOffsetX();
        var screenDy = _tweenManager.getScreenShakeOffsetY();
        var trackDx = _tweenManager.getTrackShakeOffsetX();
        var trackDy = _tweenManager.getTrackShakeOffsetY();

        var totalTrackDx = screenDx + trackDx;
        var totalTrackDy = screenDy + trackDy;

        if (_currentState != null) {
            _currentState.drawBackground(dc);
        }
        _radialSystem.drawOffset(dc, totalTrackDx, totalTrackDy);
        if (_currentState != null) {
            _currentState.drawHUD(dc);
        }
    }
}