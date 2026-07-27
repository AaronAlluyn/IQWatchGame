import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Game over state displaying run statistics, damage metrics, animated high score badges, and main menu routing.
class DeathState extends State {

    private var _manager as GameStateManager;
    private var _animTimer as Float = 0.0f;

    private var _leftDiamondPoints as Array<[Numeric, Numeric]>;
    private var _rightDiamondPoints as Array<[Numeric, Numeric]>;

    // Initializes state data structures and diamond polygon buffers
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;

        _leftDiamondPoints = [ [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric] ];
        _rightDiamondPoints = [ [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric] ];
    }

    // Configures game over state, evaluates high score updates, and spawns main menu option bar at 270 degrees
    public function enter() as Void {
        _animTimer = 0.0f;
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        if (_runContext != null) {
            _runContext.recordDeath();
        }

        // Main menu navigation bar positioned at 270 degrees
        _radialSystem.spawnBar(
            240.0f, 300.0f, 0.0f, 0.0f,
            Graphics.COLOR_BLUE, null,
            method(:onMainMenuClicked), null,
            :NORMAL, 1.0f, "MAIN MENU"
        );
    }

    // Advances badge animation timers
    public function update(deltaTime as Float) as Void {
        _animTimer += deltaTime;
    }

    // Renders dark solid background
    public function drawBackground(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    // Renders game over header, summary statistics, and animated best badges
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        // Header positioned at top 18% height
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.18).toNumber(), Graphics.FONT_MEDIUM, "GAME OVER", Graphics.TEXT_JUSTIFY_CENTER);

        if (_runContext == null) {
            return;
        }

        var startY = (height * 0.39).toNumber();
        var ySpacing = 24;

        // Floors cleared stat line
        var line1Y = startY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 6, line1Y, Graphics.FONT_XTINY, "Floor ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 6, line1Y, Graphics.FONT_XTINY, "" + _runContext.floorsCleared, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_runContext.isNewHighFloor) {
            drawBobbingNewBest(dc, (width * 0.83).toNumber(), line1Y);
        }

        // Coins earned stat line
        var line2Y = startY + ySpacing;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 15, line2Y, Graphics.FONT_XTINY, "Earned ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        var iconX = cx - 5;
        drawDiamond(dc, iconX, line2Y, 5, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(iconX + 10, line2Y, Graphics.FONT_XTINY, "" + _runContext.coinsEarned, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_runContext.isNewHighCoins) {
            drawBobbingNewBest(dc, (width * 0.83).toNumber(), line2Y);
        }

        // Total damage dealt stat line
        var line3Y = startY + (ySpacing * 2);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 8, line3Y, Graphics.FONT_XTINY, "Damage Dealt ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 8, line3Y, Graphics.FONT_XTINY, "" + _runContext.damageDealt, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Renders animated two-line high score badge with vertical sinusoidal bobbing
    private function drawBobbingNewBest(dc as Dc, badgeX as Number, badgeY as Number) as Void {
        var bobOffsetY = (Math.sin(_animTimer * 7.0f) * 3.0f).toNumber();
        var y = badgeY + bobOffsetY;

        drawOutlinedText(dc, badgeX, y - 6, Graphics.FONT_XTINY, "NEW", Graphics.COLOR_YELLOW, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawOutlinedText(dc, badgeX, y + 6, Graphics.FONT_XTINY, "BEST", Graphics.COLOR_YELLOW, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Renders text with a four-way black outline shadow for readability
    private function drawOutlinedText(dc as Dc, x as Number, y as Number, font as Graphics.FontDefinition, text as String, textColor as Number, justify as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 1, y, font, text, justify);
        dc.drawText(x - 1, y, font, text, justify);
        dc.drawText(x, y + 1, font, text, justify);
        dc.drawText(x, y - 1, font, text, justify);

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justify);
    }

    // Renders dual-polygon diamond symbol
    private function drawDiamond(dc as Dc, cx as Number, cy as Number, size as Number, leftColor as Number, rightColor as Number) as Void {
        var s = size;
        
        _leftDiamondPoints[0][0] = cx;     _leftDiamondPoints[0][1] = cy - s;
        _leftDiamondPoints[1][0] = cx - s; _leftDiamondPoints[1][1] = cy;
        _leftDiamondPoints[2][0] = cx;     _leftDiamondPoints[2][1] = cy + s;

        _rightDiamondPoints[0][0] = cx;     _rightDiamondPoints[0][1] = cy - s;
        _rightDiamondPoints[1][0] = cx + s; _rightDiamondPoints[1][1] = cy;
        _rightDiamondPoints[2][0] = cx;     _rightDiamondPoints[2][1] = cy + s;

        dc.setColor(leftColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(_leftDiamondPoints);

        dc.setColor(rightColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(_rightDiamondPoints);
    }

    // Handles selection of main menu navigation bar
    public function onMainMenuClicked(bar as RadialBar) as Void {
        _manager.switchToMenuState();
    }
}
