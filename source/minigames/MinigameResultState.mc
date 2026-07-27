import Toybox.Lang;
import Toybox.Graphics;

// Minigame completion summary card displaying performance metrics and reward claim action bars.
class MinigameResultState extends State {

    private var _manager as GameStateManager;

    private var _isWin as Boolean = true;
    private var _titleText as String = "VICTORY!";
    private var _summaryText as String = "3/3 Tumblers Cracked!";
    private var _rewardType as Symbol = :RELIC; // :RELIC, :COINS, :NONE
    private var _coinAmount as Number = 0;

    // Initializes minigame result state
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    // Sets result parameters before transition
    public function setupResult(isWin as Boolean, title as String, summary as String, rewardType as Symbol, coinAmount as Number) as Void {
        _isWin = isWin;
        _titleText = title;
        _summaryText = summary;
        _rewardType = rewardType;
        _coinAmount = coinAmount;
    }

    // Configures option bar based on reward type (CLAIM RELIC at 270 deg or CONTINUE at 270 deg)
    public function enter() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        if (_isWin) {
            AttentionManager.vibrateVictory();
        }

        if (_rewardType == :RELIC) {
            _radialSystem.spawnBottomOptionBar("CLAIM RELIC", Graphics.COLOR_GREEN, method(:onClaimRelicClicked));
        } else {
            _radialSystem.spawnBottomOptionBar("CONTINUE", Graphics.COLOR_BLUE, method(:onContinueClicked));
        }
    }

    // Renders result title, metric summary, and explicit reward line
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        var headerColor = _isWin ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        dc.setColor(headerColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.25).toNumber(), Graphics.FONT_MEDIUM, _titleText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.40).toNumber(), Graphics.FONT_XTINY, _summaryText, Graphics.TEXT_JUSTIFY_CENTER);

        var rewardY = (height * 0.52).toNumber();
        if (_rewardType == :RELIC) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, rewardY, Graphics.FONT_XTINY, "REWARD: RELIC CHOICE!", Graphics.TEXT_JUSTIFY_CENTER);
        } else if (_rewardType == :COINS && _coinAmount > 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx - 20, rewardY, Graphics.FONT_XTINY, "REWARD: ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

            var iconX = cx - 12;
            UIUtils.drawDiamond(dc, iconX, rewardY, 5, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);

            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(iconX + 10, rewardY, Graphics.FONT_XTINY, "" + _coinAmount + " Gold", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, rewardY, Graphics.FONT_XTINY, "REWARD: NONE", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    public function drawBackground(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    public function onClaimRelicClicked(bar as RadialBar) as Void {
        _manager.onMinigameWonRelic();
    }

    public function onContinueClicked(bar as RadialBar) as Void {
        if (_rewardType == :COINS) {
            _manager.onMinigameWonCoins(_coinAmount);
        } else {
            _manager.onMinigameFailed();
        }
    }
}
