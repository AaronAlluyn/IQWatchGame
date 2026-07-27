import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Core real-time combat state managing enemy AI, attack bar generation, player HP, and phase enrage transitions.
class FightState extends State {

    private var _manager as GameStateManager;
    private var _enemyHP as Number = 0;
    private var _maxEnemyHP as Number = 0;
    private var _fightProfile as Dictionary;
    private var _currentPhase as Number = 1;

    private var _playerDamageTimer as Float = 0.0f;
    private var _playerDamagedHP as Number = 0;
    private var _enemyDamageTimer as Float = 0.0f;
    private var _enemyDamagedHP as Number = 0;

    // Initializes combat state dependencies
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
        _fightProfile = EncounterDefinitions.getFightProfiles()[:TEST_ENCOUNTER] as Dictionary;
    }

    // Configures enemy fight profile, health scaling, spin speeds, and initial bars
    public function enter() as Void {
        var profileKey = _dungeonManager != null ? _dungeonManager.getCurrentEncounterKey() : :TEST_ENCOUNTER;
        var profiles = EncounterDefinitions.getFightProfiles() as Dictionary;
        if (profiles.hasKey(profileKey)) {
            _fightProfile = profiles[profileKey] as Dictionary;
        } else {
            _fightProfile = profiles[:TEST_ENCOUNTER] as Dictionary;
        }

        var healthBonus = _dungeonManager != null ? _dungeonManager.getFloorHealthBonus() : 0;
        _maxEnemyHP = (_fightProfile[:maxEnemyHP] as Number) + healthBonus;
        _enemyHP = _maxEnemyHP;
        _currentPhase = 1;

        _playerDamageTimer = 0.0f;
        _playerDamagedHP = 0;
        _enemyDamageTimer = 0.0f;
        _enemyDamagedHP = 0;

        var speedMult = _dungeonManager != null ? _dungeonManager.getFloorSpeedMultiplier() : 1.0f;
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed((_fightProfile[:indicatorBaseSpeed] as Float) * speedMult);
        checkAndRefillBars(0l);
    }

    // Updates damage flash timers, dynamic spin speeds, and sub-50% HP Phase 2 enrage transitions
    public function update(deltaTime as Float) as Void {
        if (_playerDamageTimer > 0.0f) {
            _playerDamageTimer -= deltaTime;
            if (_playerDamageTimer < 0.0f) { _playerDamageTimer = 0.0f; }
        }

        if (_enemyDamageTimer > 0.0f) {
            _enemyDamageTimer -= deltaTime;
            if (_enemyDamageTimer < 0.0f) { _enemyDamageTimer = 0.0f; }
        }

        var speedMult = _dungeonManager != null ? _dungeonManager.getFloorSpeedMultiplier() : 1.0f;
        var hpPercent = _enemyHP.toFloat() / (_maxEnemyHP > 0 ? _maxEnemyHP.toFloat() : 1.0f);

        if (hpPercent <= 0.50f && _currentPhase == 1 && _fightProfile.hasKey(:phase2BackgroundColor)) {
            _currentPhase = 2;
            AttentionManager.vibrateDamage();
            if (_tweenManager != null) {
                _tweenManager.triggerScreenShake(0.35f, 10);
            }
        }

        var baseSpeed = (_fightProfile[:indicatorBaseSpeed] as Float) * speedMult;
        if (_currentPhase == 2 && _fightProfile.hasKey(:phase2IndicatorSpeed)) {
            baseSpeed = (_fightProfile[:phase2IndicatorSpeed] as Float) * speedMult;
        }
        var maxSpeed = (_fightProfile[:indicatorMaxSpeed] as Float) * speedMult;

        var newSpeed = baseSpeed + (maxSpeed - baseSpeed) * (1.0f - hpPercent);
        _radialSystem.setSpinSpeed(newSpeed);
    }

    public function refillBars(frameCount as Long) as Void {
        checkAndRefillBars(frameCount);
    }

    private function spawnPlayerAttackBar(frameCount as Long) as Void {
        var widthMin = _fightProfile[:playerBarWidthMin] as Number;
        var widthMax = _fightProfile[:playerBarWidthMax] as Number;
        var shrinkMin = _fightProfile[:playerBarShrinkMin] as Number;
        var shrinkMax = _fightProfile[:playerBarShrinkMax] as Number;

        var retries = 10;
        var widthRange = widthMax - widthMin;
        var shrinkRange = shrinkMax - shrinkMin;

        for (var i = 0; i < retries; i++) {
            var barWidth = (widthMin + (widthRange > 0 ? (Math.rand() % widthRange) : 0)).toFloat();
            var shrinkRate = (shrinkMin + (shrinkRange > 0 ? (Math.rand() % shrinkRange) : 0)).toFloat();

            var startAngle = (Math.rand() % 360).toFloat();
            var endAngle = (startAngle + barWidth) >= 360.0f ? (startAngle + barWidth) - 360.0f : (startAngle + barWidth);

            if (_radialSystem.isSpaceFree(startAngle, endAngle)) {
                var playerColor = _fightProfile.hasKey(:playerBarColor) ? (_fightProfile[:playerBarColor] as Number) : Graphics.COLOR_WHITE;
                _radialSystem.spawnBar(
                    startAngle, endAngle, shrinkRate, 0.0f, playerColor,
                    null, method(:handlePlayerAttackSuccess), method(:handlePlayerAttackTimeout),
                    :NORMAL, 1.0f, null
                );
                return;
            }
        }
    }

    private function spawnEnemyAttackBar(frameCount as Long) as Void {
        var widthMin = _fightProfile[:enemyBarWidthMin] as Number;
        var widthMax = _fightProfile[:enemyBarWidthMax] as Number;
        var shrinkMin = _fightProfile[:enemyBarShrinkMin] as Number;
        var shrinkMax = _fightProfile[:enemyBarShrinkMax] as Number;

        var retries = 10;
        var widthRange = widthMax - widthMin;
        var shrinkRange = shrinkMax - shrinkMin;
        var rotationSpeed = 0.0f;

        if (_fightProfile.hasKey(:enemyBarMoveChance) && _fightProfile.hasKey(:enemyBarRotationSpeedMin)) {
            var moveChance = _fightProfile[:enemyBarMoveChance] as Float;
            if (moveChance > 0.0f && (Math.rand() % 100) < moveChance) {
                var rotMin = _fightProfile[:enemyBarRotationSpeedMin] as Float;
                var rotMax = _fightProfile[:enemyBarRotationSpeedMax] as Float;
                var rotRange = (rotMax - rotMin).toLong();
                if (rotRange > 0) {
                    rotationSpeed = (rotMin + (Math.rand() % rotRange)).toFloat();
                } else {
                    rotationSpeed = rotMin;
                }
            }
        }

        for (var i = 0; i < retries; i++) {
            var barWidth = (widthMin + (widthRange > 0 ? (Math.rand() % widthRange) : 0)).toFloat();
            var shrinkRate = (shrinkMin + (shrinkRange > 0 ? (Math.rand() % shrinkRange) : 0)).toFloat();
            var startAngle = (Math.rand() % 340).toFloat() + 10.0f;

            var checkStart = startAngle;
            var checkEnd = startAngle + barWidth;
            if (rotationSpeed != 0.0f) {
                var padding = 30.0f;
                checkStart -= padding;
                checkEnd += padding;
            }

            while (checkStart < 0) { checkStart += 360.0f; }
            while (checkEnd >= 360.0f) { checkEnd -= 360.0f; }

            if (_radialSystem.isSpaceFree(checkStart, checkEnd)) {
                var enemyColor = _fightProfile[:enemyBarColor] as Number;
                _radialSystem.spawnBar(
                    startAngle, (startAngle + barWidth) >= 360.0f ? (startAngle + barWidth) - 360.0f : (startAngle + barWidth), 
                    shrinkRate, rotationSpeed, enemyColor,
                    null, method(:handleEnemyAttackBlocked), method(:handleEnemyAttackHits),
                    :NORMAL, 1.0f, null
                );
                return;
            }
        }
    }

    private function spawnStickyZoneBar(frameCount as Long) as Void {
        var retries = 10;
        for (var i = 0; i < retries; i++) {
            var barWidth = 50.0f;
            var startAngle = (Math.rand() % 360).toFloat();
            var endAngle = (startAngle + barWidth) >= 360.0f ? (startAngle + barWidth) - 360.0f : (startAngle + barWidth);

            if (_radialSystem.isSpaceFree(startAngle, endAngle)) {
                _radialSystem.spawnBar(
                    startAngle, endAngle, 0.0f, 0.0f, Graphics.COLOR_DK_GREEN,
                    null, null, null,
                    :STICKY_ZONE, 0.4f, null
                );
                return;
            }
        }
    }

    private function spawnHazardBar(frameCount as Long) as Void {
        if (!_fightProfile.hasKey(:hazardSpawnChance) || !_fightProfile.hasKey(:hazardBarWidthMin)) {
            return;
        }

        var spawnChance = _fightProfile[:hazardSpawnChance] as Float;
        if (spawnChance <= 0.0f) {
            return;
        }

        var widthMin = _fightProfile[:hazardBarWidthMin] as Number;
        var widthMax = _fightProfile[:hazardBarWidthMax] as Number;
        var shrinkMin = _fightProfile[:hazardBarShrinkMin] as Number;
        var shrinkMax = _fightProfile[:hazardBarShrinkMax] as Number;

        var retries = 10;
        var widthRange = widthMax - widthMin;
        var shrinkRange = shrinkMax - shrinkMin;

        for (var i = 0; i < retries; i++) {
            var barWidth = (widthMin + (widthRange > 0 ? (Math.rand() % widthRange) : 0)).toFloat();
            var shrinkRate = (shrinkMin + (shrinkRange > 0 ? (Math.rand() % shrinkRange) : 0)).toFloat();

            var startAngle = (Math.rand() % 360).toFloat();
            var endAngle = startAngle + barWidth;
            endAngle = endAngle >= 360.0f ? endAngle - 360.0f : endAngle;

            if (_radialSystem.isSpaceFree(startAngle, endAngle)) {
                var hazardColor = _fightProfile[:hazardBarColor] as Number;
                _radialSystem.spawnBar(
                    startAngle, endAngle, shrinkRate, 0.0f, hazardColor,
                    null, method(:handleHazardHit), method(:handleHazardTimeout),
                    :MODIFIER_REVERSE_INDICATOR, 1.0f, null
                );
                return;
            }
        }
    }

    private function checkAndRefillBars(frameCount as Long) as Void {
        if (_runContext != null && _runContext.playerHP <= 0) {
            return;
        }

        if (_enemyHP <= 0) {
            return;
        }

        if (_radialSystem.getOccupiedSpace() > 270.0f) {
            return;
        }

        var playerColor = _fightProfile.hasKey(:playerBarColor) ? (_fightProfile[:playerBarColor] as Number) : Graphics.COLOR_WHITE;
        var hazardColor = _fightProfile.hasKey(:hazardBarColor) ? (_fightProfile[:hazardBarColor] as Number) : Graphics.COLOR_YELLOW;

        var activePlayerBars = 0;
        var activeEnemyBars = 0;
        var activeHazardBars = 0;
        var activeStickyBars = 0;

        for (var i = 0; i < _radialSystem.getBarCount(); i++) {
            var bar = _radialSystem.getBar(i);
            if (bar.isActive) {
                if (bar.color == playerColor) {
                    activePlayerBars++;
                } else if (bar.behaviorType == :STICKY_ZONE) {
                    activeStickyBars++;
                } else if (bar.color == hazardColor) {
                    activeHazardBars++;
                } else {
                    activeEnemyBars++;
                }
            }
        }

        var minPlayerBars = _fightProfile[:minPlayerBars] as Number;
        var maxPlayerBars = _fightProfile[:maxPlayerBars] as Number;
        var playerRange = maxPlayerBars - minPlayerBars + 1;
        var targetPlayerBars = minPlayerBars + (playerRange > 1 ? (Math.rand() % playerRange) : 0);

        var minEnemyBars = _fightProfile[:minEnemyBars] as Number;
        var maxEnemyBars = _fightProfile[:maxEnemyBars] as Number;
        var enemyRange = maxEnemyBars - minEnemyBars + 1;
        var targetEnemyBars = minEnemyBars + (enemyRange > 1 ? (Math.rand() % enemyRange) : 0);

        while (activePlayerBars < targetPlayerBars) {
            spawnPlayerAttackBar(frameCount);
            activePlayerBars++;
        }

        if (_fightProfile.hasKey(:stickyZoneChance) && activeStickyBars == 0) {
            var stickyChance = _fightProfile[:stickyZoneChance] as Float;
            if (stickyChance > 0.0f && (Math.rand() % 100) < stickyChance) {
                spawnStickyZoneBar(frameCount);
            }
        }

        var hazardChance = _fightProfile.hasKey(:hazardSpawnChance) ? (_fightProfile[:hazardSpawnChance] as Float) : 0.0f;
        while (activeEnemyBars + activeHazardBars < targetEnemyBars) {
            if (hazardChance > 0.0f && (Math.rand() % 100) < hazardChance) {
                spawnHazardBar(frameCount);
                activeHazardBars++;
            } else {
                spawnEnemyAttackBar(frameCount);
                activeEnemyBars++;
            }
        }
    }

    // Renders background color with phase 2 crimson tinting
    public function drawBackground(dc as Dc) as Void {
        var bgColor = _fightProfile.hasKey(:backgroundColor) ? (_fightProfile[:backgroundColor] as Number) : Graphics.COLOR_BLACK;
        if (_currentPhase == 2 && _fightProfile.hasKey(:phase2BackgroundColor)) {
            bgColor = _fightProfile[:phase2BackgroundColor] as Number;
        }
        dc.setColor(bgColor, bgColor);
        dc.clear();
    }

    // Renders enemy HP, player HP, and coin counter
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        drawEnemyHealth(dc, width, height);
        drawPlayerHealth(dc, width, height);

        if (_runContext != null) {
            var jumpOffsetY = _tweenManager != null ? _tweenManager.getCoinJumpOffsetY() : 0;
            UIUtils.drawCoinCounter(dc, width, height, _runContext.coins, jumpOffsetY);
        }
    }

    // Handles player attack bar hit
    public function handlePlayerAttackSuccess(bar as RadialBar) as Void {
        AttentionManager.vibrateHit();
        _enemyDamagedHP = _enemyHP;
        _enemyDamageTimer = 0.25f;
        _enemyHP -= 1;

        if (_runContext != null) {
            _runContext.damageDealt += 1;
            var reward = _runContext.registerHit();
            if (_tweenManager != null) {
                _tweenManager.triggerCoinJump(reward);
            }
        }

        if (_enemyHP <= 0) {
            _enemyHP = 0;
            AttentionManager.vibrateVictory();

            if (_runContext != null) {
                _runContext.addCoins(10);
            }

            var profileKey = _dungeonManager != null ? _dungeonManager.getCurrentEncounterKey() : :TEST_ENCOUNTER;
            if (profileKey == :SLIME_BOSS_ENCOUNTER) {
                _manager.switchToRelicRewardState();
            } else {
                _manager.onEncounterCleared();
            }
        }
    }

    public function handlePlayerAttackTimeout(bar as RadialBar or Null) as Void {
        if (_runContext != null) {
            _runContext.resetStreak();
        }
    }

    public function handleEnemyAttackBlocked(bar as RadialBar) as Void {
        AttentionManager.vibrateBlock();
        if (_runContext != null) {
            _runContext.onBlockRelicEffect(_radialSystem);
        }
    }

    public function handleHazardHit(bar as RadialBar) as Void {
        AttentionManager.vibrateBlock();
        _radialSystem.reverseSpinDirection();
    }

    public function handleHazardTimeout(bar as RadialBar or Null) as Void {
    }

    public function handleEnemyAttackHits(bar as RadialBar or Null) as Void {
        AttentionManager.vibrateDamage();
        if (_tweenManager != null) {
            _tweenManager.triggerScreenShake(0.22f, 8);
        }

        if (_runContext != null) {
            _playerDamagedHP = _runContext.playerHP;
            _playerDamageTimer = 0.25f;
            var isDead = _runContext.takeDamage(1);
            if (isDead) {
                _manager.onPlayerDeath();
            }
        }
    }

    private function drawPlayerHealth(dc as Dc, width as Number, height as Number) as Void {
        var heartSize = 10;
        var heartSpacing = 24;
        var maxHP = _runContext != null ? _runContext.maxPlayerHP : 4;
        var currentHP = _runContext != null ? _runContext.playerHP : 4;

        var numHearts = (maxHP + 1) / 2;
        var startX = (width / 2) - ((numHearts - 1) * heartSpacing / 2);
        var baseY = (height * 0.78).toNumber();

        for (var i = 0; i < numHearts; i++) {
            var leftValue = (i * 2) + 1;
            var rightValue = (i * 2) + 2;

            var leftColor = Graphics.COLOR_DK_GRAY;
            var rightColor = Graphics.COLOR_DK_GRAY;
            var shakeDx = 0;
            var shakeDy = 0;

            if (currentHP >= rightValue) {
                leftColor = Graphics.COLOR_RED;
                rightColor = Graphics.COLOR_RED;
            } else if (currentHP >= leftValue) {
                leftColor = Graphics.COLOR_RED;
                rightColor = Graphics.COLOR_DK_GRAY;
            }

            if (_playerDamageTimer > 0.0f) {
                if (_playerDamagedHP == leftValue) {
                    leftColor = Graphics.COLOR_WHITE;
                    shakeDx = (Math.rand() % 9) - 4;
                    shakeDy = (Math.rand() % 9) - 4;
                } else if (_playerDamagedHP == rightValue) {
                    rightColor = Graphics.COLOR_WHITE;
                    shakeDx = (Math.rand() % 9) - 4;
                    shakeDy = (Math.rand() % 9) - 4;
                }
            }

            UIUtils.drawDiamond(dc, startX + (i * heartSpacing) + shakeDx, baseY + shakeDy, heartSize, leftColor, rightColor);
        }
    }

    private function drawEnemyHealth(dc as Dc, width as Number, height as Number) as Void {
        var diamondSize = 8;
        var diamondSpacing = 18;
        var numDiamonds = (_maxEnemyHP + 1) / 2;
        var startX = (width / 2) - ((numDiamonds - 1) * diamondSpacing / 2);
        var baseY = (height * 0.25).toNumber();

        for (var i = 0; i < numDiamonds; i++) {
            var leftValue = (i * 2) + 1;
            var rightValue = (i * 2) + 2;

            var leftColor = Graphics.COLOR_DK_GRAY;
            var rightColor = Graphics.COLOR_DK_GRAY;
            var shakeDx = 0;
            var shakeDy = 0;

            if (_enemyHP >= rightValue) {
                leftColor = Graphics.COLOR_YELLOW;
                rightColor = Graphics.COLOR_YELLOW;
            } else if (_enemyHP >= leftValue) {
                leftColor = Graphics.COLOR_YELLOW;
                rightColor = Graphics.COLOR_DK_GRAY;
            }

            if (_enemyDamageTimer > 0.0f) {
                if (_enemyDamagedHP == leftValue) {
                    leftColor = Graphics.COLOR_WHITE;
                    shakeDx = (Math.rand() % 9) - 4;
                    shakeDy = (Math.rand() % 9) - 4;
                } else if (_enemyDamagedHP == rightValue) {
                    rightColor = Graphics.COLOR_WHITE;
                    shakeDx = (Math.rand() % 9) - 4;
                    shakeDy = (Math.rand() % 9) - 4;
                }
            }

            UIUtils.drawDiamond(dc, startX + (i * diamondSpacing) + shakeDx, baseY + shakeDy, diamondSize, leftColor, rightColor);
        }
    }

    public function onEmptySpaceHit() as Void {
        if (_runContext != null) {
            _runContext.resetStreak();
        }
        var freezeDuration = 0.20f;
        if (_fightProfile.hasKey(:missPenaltyFreezeDuration)) {
            freezeDuration = _fightProfile[:missPenaltyFreezeDuration] as Float;
        }
        _radialSystem.freezeIndicator(freezeDuration);
    }
}
