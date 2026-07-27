import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

class LockpickerState extends State {

    private var _manager as GameStateManager;
    private var _stage as Number = 1; // 1, 2, 3
    private var _missesRemaining as Number = 2;

    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    public function enter() as Void {
        _stage = 1;
        _missesRemaining = 2;
        setupStage();
    }

    private function setupStage() as Void {
        _radialSystem.clearBars();

        var barWidth = 25.0f;
        var barColor = Graphics.COLOR_GREEN;
        var spinSpeed = 70.0f;

        if (_stage == 2) {
            barWidth = 16.0f;
            barColor = Graphics.COLOR_BLUE;
            spinSpeed = -95.0f;
        } else if (_stage == 3) {
            barWidth = 9.0f;
            barColor = Graphics.COLOR_YELLOW;
            spinSpeed = 120.0f;
        }

        _radialSystem.setSpinSpeed(spinSpeed);

        var startAngle = (Math.rand() % 300).toFloat() + 30.0f;
        var endAngle = (startAngle + barWidth) >= 360.0f ? (startAngle + barWidth) - 360.0f : (startAngle + barWidth);

        _radialSystem.spawnBar(
            startAngle, endAngle, 0.0f, 0.0f, barColor,
            null, method(:onTumblerHit), null,
            :NORMAL, 1.0f, "LOCK " + _stage
        );
    }

    public function onTumblerHit(bar as RadialBar) as Void {
        if (_tweenManager != null) {
            _tweenManager.triggerTrackShake(0.12f, 6);
        }

        _stage += 1;
        if (_stage > 3) {
            // All 3 Tumblers Cracked!
            _manager.showMinigameResult(true, "VAULT CRACKED!", "3 / 3 Tumblers Cracked!", :RELIC, 0);
        } else {
            setupStage();
        }
    }

    public function onEmptySpaceHit() as Void {
        _missesRemaining -= 1;
        if (_tweenManager != null) {
            _tweenManager.triggerScreenShake(0.20f, 6);
        }

        if (_missesRemaining <= 0) {
            _manager.showMinigameResult(false, "VAULT LOCKED!", "Lockpick Broke!", :NONE, 0);
        } else {
            _radialSystem.freezeIndicator(0.30f);
        }
    }

    public function drawBackground(dc as Dc) as Void {
        dc.setColor(0x051a05, 0x051a05); // Dark green vault tint
        dc.clear();
    }

    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.20).toNumber(), Graphics.FONT_MEDIUM, "VAULT LOCK", Graphics.TEXT_JUSTIFY_CENTER);

        // Progress indicators: [ ⬤  ◯  ◯ ]
        var statusStr = "";
        for (var i = 1; i <= 3; i++) {
            if (i < _stage) {
                statusStr += "[*] ";
            } else if (i == _stage) {
                statusStr += "[?] ";
            } else {
                statusStr += "[ ] ";
            }
        }

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.70).toNumber(), Graphics.FONT_TINY, statusStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.80).toNumber(), Graphics.FONT_XTINY, "Picks Left: " + _missesRemaining, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
