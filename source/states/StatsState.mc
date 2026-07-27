import Toybox.Lang;
import Toybox.Graphics;

// State displaying permanent lifetime records, highest floor, best streak, and boss kills.
class StatsState extends State {

    private var _manager as GameStateManager;

    // Initializes stats state dependencies
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    // Configures option bar for Back at 270 degrees
    public function enter() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        _radialSystem.spawnBottomOptionBar("BACK", Graphics.COLOR_BLUE, method(:onBackClicked));
    }

    // Renders dark background
    public function drawBackground(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    // Renders header title and lifetime record lines
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        // Header title at 0.18 height
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.18).toNumber(), Graphics.FONT_MEDIUM, "RECORDS", Graphics.TEXT_JUSTIFY_CENTER);

        if (_runContext == null) {
            return;
        }

        var startY = (height * 0.35).toNumber();
        var ySpacing = 18;

        // Best Floor
        var line1Y = startY;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line1Y, Graphics.FONT_XTINY, "Best Floor: ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line1Y, Graphics.FONT_XTINY, "" + _runContext.highFloor, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Best Gold Earned
        var line2Y = startY + ySpacing;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 15, line2Y, Graphics.FONT_XTINY, "Best Gold: ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        var iconX = cx - 5;
        UIUtils.drawDiamond(dc, iconX, line2Y, 4, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(iconX + 8, line2Y, Graphics.FONT_XTINY, "" + _runContext.highCoins, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Best Hit Streak
        var line3Y = startY + (ySpacing * 2);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line3Y, Graphics.FONT_XTINY, "Best Streak: ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line3Y, Graphics.FONT_XTINY, "" + _runContext.bestStreakLifetime, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Bosses Defeated
        var line4Y = startY + (ySpacing * 3);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line4Y, Graphics.FONT_XTINY, "Boss Kills: ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line4Y, Graphics.FONT_XTINY, "" + _runContext.bossesKilled, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Total Runs Started
        var line5Y = startY + (ySpacing * 4);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line5Y, Graphics.FONT_XTINY, "Total Runs: ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 5, line5Y, Graphics.FONT_XTINY, "" + _runContext.lifetimeRuns, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Navigates back to main menu
    public function onBackClicked(bar as RadialBar) as Void {
        _manager.switchToMenuState();
    }
}
