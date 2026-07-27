import Toybox.Lang;
import Toybox.Graphics;

// Pre-fight breathing card displaying enemy preview, health, floor step code, and dynamic moveset legend.
class EncounterIntroState extends State {

    private var _manager as GameStateManager;
    private var _fightProfile as Dictionary;
    private var _maxEnemyHP as Number = 0;

    // Initializes encounter intro dependencies
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
        _fightProfile = EncounterDefinitions.getFightProfiles()[:TEST_ENCOUNTER] as Dictionary;
    }

    // Configures pre-fight preview data and spawns Fight button at 270 degrees
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

        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        _radialSystem.spawnBottomOptionBar("FIGHT!", Graphics.COLOR_GREEN, method(:onFightClicked));
    }

    // Renders enemy-themed background color
    public function drawBackground(dc as Dc) as Void {
        var bgColor = _fightProfile.hasKey(:backgroundColor) ? (_fightProfile[:backgroundColor] as Number) : Graphics.COLOR_BLACK;
        dc.setColor(bgColor, bgColor);
        dc.clear();
    }

    // Renders step code, enemy title, health diamonds, and multi-line moveset legend
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        var stepNum = _dungeonManager != null ? _dungeonManager.getCurrentStep() : 1;
        var floorNum = _dungeonManager != null ? _dungeonManager.getCurrentFloor() : 1;
        var codeText = "E" + stepNum + "F" + floorNum;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.13).toNumber(), Graphics.FONT_XTINY, codeText, Graphics.TEXT_JUSTIFY_CENTER);

        var enemyName = _fightProfile.hasKey(:enemyName) ? (_fightProfile[:enemyName] as String) : "ENEMY";
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.24).toNumber(), Graphics.FONT_MEDIUM, enemyName, Graphics.TEXT_JUSTIFY_CENTER);

        var diamondSize = 8;
        var diamondSpacing = 18;
        var numDiamonds = (_maxEnemyHP + 1) / 2;
        var startX = cx - ((numDiamonds - 1) * diamondSpacing / 2);
        var healthY = (height * 0.38).toNumber();

        for (var i = 0; i < numDiamonds; i++) {
            var currentX = startX + (i * diamondSpacing);
            UIUtils.drawDiamond(dc, currentX, healthY, diamondSize, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);
        }

        drawMultiLineLegend(dc, width, (height * 0.48).toNumber());
    }

    // Renders compact multi-line color square moveset legend
    private function drawMultiLineLegend(dc as Dc, width as Number, startY as Number) as Void {
        var items = [] as Array<Dictionary>;

        if (_fightProfile.hasKey(:enemyBarColor)) {
            items.add({ :color => _fightProfile[:enemyBarColor] as Number, :label => "Block" });
        }

        if (_fightProfile.hasKey(:hazardSpawnChance) && (_fightProfile[:hazardSpawnChance] as Float) > 0.0f) {
            if (_fightProfile.hasKey(:hazardBarColor)) {
                items.add({ :color => _fightProfile[:hazardBarColor] as Number, :label => "Reverse" });
            }
        }

        if (_fightProfile.hasKey(:stickyZoneChance) && (_fightProfile[:stickyZoneChance] as Float) > 0.0f) {
            items.add({ :color => Graphics.COLOR_DK_GREEN, :label => "Slow" });
        }

        if (items.size() == 0) {
            return;
        }

        var boxSize = 10;
        var textGap = 5;
        var lineSpacing = 18;

        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            var cVal = item[:color] as Number;
            var label = item[:label] as String;

            var textDims = dc.getTextDimensions(label, Graphics.FONT_XTINY);
            var textW = textDims[0];
            var itemW = boxSize + textGap + textW;

            var itemX = (width / 2) - (itemW / 2);
            var itemY = startY + (i * lineSpacing);

            dc.setColor(cVal, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(itemX, itemY - (boxSize / 2), boxSize, boxSize);

            var textX = itemX + boxSize + textGap;
            dc.drawText(textX, itemY, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Transitions to combat state
    public function onFightClicked(bar as RadialBar) as Void {
        _manager.switchToFightState();
    }
}
