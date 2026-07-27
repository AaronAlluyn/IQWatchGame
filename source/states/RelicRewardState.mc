import Toybox.Lang;
import Toybox.Graphics;

// Boss defeat relic selection card offering Vampire Tooth, Golden Horseshoe, Parry Shield, or Skip options.
class RelicRewardState extends State {

    private var _manager as GameStateManager;

    // Initializes relic reward state
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    // Configures relic option bars at 180 deg, 0 deg, 90 deg, and 270 deg
    public function enter() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        _radialSystem.spawnLeftOptionBar("VAMP TOOTH", Graphics.COLOR_RED, method(:onVampireToothClicked));
        _radialSystem.spawnRightOptionBar("GOLD SHOE", Graphics.COLOR_YELLOW, method(:onGoldenHorseshoeClicked));
        _radialSystem.spawnTopOptionBar("PARRY SHIELD", Graphics.COLOR_BLUE, method(:onParryShieldClicked));
        _radialSystem.spawnBottomOptionBar("SKIP", Graphics.COLOR_DK_GRAY, method(:onSkipClicked));
    }

    // Renders dark crimson victory background
    public function drawBackground(dc as Dc) as Void {
        dc.setColor(0x20000a, 0x20000a);
        dc.clear();
    }

    // Renders equipped relic subtext at 0.78 screen height without header clutter
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        var currentRelicStr = "None";
        if (_runContext != null && _runContext.activeRelic != null) {
            if (_runContext.activeRelic == :VAMPIRE_TOOTH) {
                currentRelicStr = "Vampire Tooth";
            } else if (_runContext.activeRelic == :GOLDEN_HORSESHOE) {
                currentRelicStr = "Golden Horseshoe";
            } else if (_runContext.activeRelic == :PARRY_SHIELD) {
                currentRelicStr = "Parry Shield";
            }
        }

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (height * 0.78).toNumber(), Graphics.FONT_XTINY, "Equipped: " + currentRelicStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Equips Vampire Tooth relic and advances encounter
    public function onVampireToothClicked(bar as RadialBar) as Void {
        if (_runContext != null) {
            _runContext.activeRelic = :VAMPIRE_TOOTH;
        }
        _manager.onEncounterCleared();
    }

    // Equips Golden Horseshoe relic and advances encounter
    public function onGoldenHorseshoeClicked(bar as RadialBar) as Void {
        if (_runContext != null) {
            _runContext.activeRelic = :GOLDEN_HORSESHOE;
        }
        _manager.onEncounterCleared();
    }

    // Equips Parry Shield relic and advances encounter
    public function onParryShieldClicked(bar as RadialBar) as Void {
        if (_runContext != null) {
            _runContext.activeRelic = :PARRY_SHIELD;
        }
        _manager.onEncounterCleared();
    }

    // Skips relic selection and advances encounter
    public function onSkipClicked(bar as RadialBar) as Void {
        _manager.onEncounterCleared();
    }
}
