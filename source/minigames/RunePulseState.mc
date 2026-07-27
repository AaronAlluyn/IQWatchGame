import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

class RunePulseState extends State {

    private var _manager as GameStateManager;
    private var _timeRemaining as Float = 10.0f;
    private var _hitCount as Number = 0;
    private var _baseSpeed as Float = 80.0f;

    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    public function enter() as Void {
        _timeRemaining = 10.0f;
        _hitCount = 0;
        _baseSpeed = 80.0f;

        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(_baseSpeed);
        spawnTargetBar();
    }

    private function spawnTargetBar() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(_baseSpeed + (_hitCount * 2.5f));

        var currentAngle = _radialSystem.getIndicatorAngle();
        // Spawn target closer ahead (45 to 100 degrees ahead) for easy reaction and smooth rhythm
        var aheadOffset = 45.0f + (Math.rand() % 55).toFloat();
        var startAngle = currentAngle + aheadOffset;
        while (startAngle >= 360.0f) { startAngle -= 360.0f; }

        var barWidth = 60.0f; // Wider target bar
        var endAngle = (startAngle + barWidth) >= 360.0f ? (startAngle + barWidth) - 360.0f : (startAngle + barWidth);

        // Gentle shrink rate (8 deg/s) for comfortable rhythm timing
        _radialSystem.spawnBar(
            startAngle, endAngle, 8.0f, 0.0f, Graphics.COLOR_YELLOW,
            null, method(:onTargetHit), method(:onTargetTimeout),
            :NORMAL, 1.0f, "PULSE"
        );
    }

    public function update(deltaTime as Float) as Void {
        if (_timeRemaining > 0.0f) {
            _timeRemaining -= deltaTime;
            if (_timeRemaining <= 0.0f) {
                _timeRemaining = 0.0f;
                finishMinigame();
            }
        }
    }

    public function onTargetHit(bar as RadialBar) as Void {
        _hitCount += 1;
        if (_tweenManager != null) {
            _tweenManager.triggerCoinJump(1);
        }
        spawnTargetBar();
    }

    public function onTargetTimeout(bar as RadialBar or Null) as Void {
        spawnTargetBar();
    }

    private function finishMinigame() as Void {
        if (_hitCount >= 10) {
            _manager.showMinigameResult(true, "RUNE BLITZ!", _hitCount + " Hits Landed!", :RELIC, 0);
        } else if (_hitCount >= 5) {
            _manager.showMinigameResult(true, "RUNE PULSE!", _hitCount + " Hits Landed!", :COINS, 15);
        } else {
            _manager.showMinigameResult(false, "RUNE PULSE", _hitCount + " Hits Landed", :COINS, 3);
        }
    }

    public function drawBackground(dc as Dc) as Void {
        dc.setColor(0x1a1a00, 0x1a1a00); // Dark amber pulse background
        dc.clear();
    }

    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.18).toNumber(), Graphics.FONT_MEDIUM, "RUNE PULSE", Graphics.TEXT_JUSTIFY_CENTER);

        // Timer display
        var timerStr = Lang.format("$1$s", [_timeRemaining.format("%.1f")]);
        dc.setColor(_timeRemaining < 3.0f ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.70).toNumber(), Graphics.FONT_MEDIUM, timerStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Hit counter
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.82).toNumber(), Graphics.FONT_XTINY, "Hits: " + _hitCount, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
