import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Minigame #3: Glyph Memory sequence rhythm challenge (Simon-Says radial pattern memory).
class GlyphMemoryState extends State {

    private var _manager as GameStateManager;
    private var _round as Number = 1; // 1, 2, 3
    private var _sequence as Array<Number>;
    private var _stepIndex as Number = 0;
    private var _isShowingPreview as Boolean = true;
    private var _previewTimer as Float = 0.0f;
    private var _previewStep as Number = 0;

    private var _cardinalAngles as Array<Float> = [180.0f, 0.0f, 90.0f, 270.0f]; // Left, Right, Top, Bottom

    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
        _sequence = [] as Array<Number>;
    }

    public function enter() as Void {
        _round = 1;
        startRound();
    }

    private function startRound() as Void {
        _sequence = [] as Array<Number>;
        var stepCount = _round + 2; // Round 1: 3 steps, Round 2: 4 steps, Round 3: 5 steps

        for (var i = 0; i < stepCount; i++) {
            _sequence.add(Math.rand() % 4);
        }

        _stepIndex = 0;
        _previewStep = 0;
        _isShowingPreview = true;
        _previewTimer = 0.50f;

        flashPreviewBar();
    }

    private function flashPreviewBar() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(0.0f);

        if (_previewStep < _sequence.size()) {
            var angleIdx = _sequence[_previewStep];
            var centerA = _cardinalAngles[angleIdx];
            var startA = centerA - 20.0f;
            var endA = centerA + 20.0f;
            while (startA < 0) { startA += 360.0f; }
            while (endA >= 360.0f) { endA -= 360.0f; }

            _radialSystem.spawnBar(
                startA, endA, 0.0f, 0.0f, Graphics.COLOR_PURPLE,
                null, null, null, :NORMAL, 1.0f, "GLYPH " + (_previewStep + 1)
            );
        }
    }

    public function update(deltaTime as Float) as Void {
        if (_isShowingPreview) {
            _previewTimer -= deltaTime;
            if (_previewTimer <= 0.0f) {
                _previewTimer = 0.45f;
                _previewStep++;

                if (_previewStep >= _sequence.size()) {
                    // Preview complete! Transition to Player Input Phase
                    _isShowingPreview = false;
                    _radialSystem.clearBars();
                    _radialSystem.setSpinSpeed(75.0f);
                    spawnCurrentSequenceTarget();
                } else {
                    flashPreviewBar();
                }
            }
        }
    }

    private function spawnCurrentSequenceTarget() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(75.0f + (_round * 10.0f));

        if (_stepIndex < _sequence.size()) {
            var angleIdx = _sequence[_stepIndex];
            var centerA = _cardinalAngles[angleIdx];
            var startA = centerA - 25.0f;
            var endA = centerA + 25.0f;
            while (startA < 0) { startA += 360.0f; }
            while (endA >= 360.0f) { endA -= 360.0f; }

            _radialSystem.spawnBar(
                startA, endA, 0.0f, 0.0f, Graphics.COLOR_PURPLE,
                null, method(:onTargetHit), null,
                :NORMAL, 1.0f, "HIT " + (_stepIndex + 1)
            );
        }
    }

    public function onTargetHit(bar as RadialBar) as Void {
        AttentionManager.vibrateHit();
        _stepIndex++;

        if (_stepIndex >= _sequence.size()) {
            // Round completed!
            _round++;
            if (_round > 3) {
                // Minigame Won! 3 / 3 Rounds Cracked!
                _manager.showMinigameResult(true, "MEMORY MASTER!", "3 / 3 Rounds Completed!", :RELIC, 0);
            } else {
                startRound();
            }
        } else {
            spawnCurrentSequenceTarget();
        }
    }

    public function onEmptySpaceHit() as Void {
        if (!_isShowingPreview) {
            AttentionManager.vibrateDamage();
            if (_round >= 3) {
                _manager.showMinigameResult(true, "GLYPH MEMORY!", "2 / 3 Rounds Completed!", :COINS, 15);
            } else if (_round >= 2) {
                _manager.showMinigameResult(true, "GLYPH MEMORY!", "1 / 3 Rounds Completed!", :COINS, 8);
            } else {
                _manager.showMinigameResult(false, "MEMORY BROKE!", "Failed Sequence!", :COINS, 3);
            }
        }
    }

    public function drawBackground(dc as Dc) as Void {
        dc.setColor(0x1a001a, 0x1a001a); // Dark purple background
        dc.clear();
    }

    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.18).toNumber(), Graphics.FONT_MEDIUM, "GLYPH MEMORY", Graphics.TEXT_JUSTIFY_CENTER);

        var statusStr = _isShowingPreview ? "WATCH SEQUENCE..." : "REPEAT PATTERN!";
        var statusColor = _isShowingPreview ? Graphics.COLOR_YELLOW : Graphics.COLOR_GREEN;

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.70).toNumber(), Graphics.FONT_XTINY, statusStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.82).toNumber(), Graphics.FONT_XTINY, "Round " + _round + " / 3", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
