import Toybox.Lang;
import Toybox.Graphics;

// Main menu state providing new game initialization, mid-run continuation, and lifetime records options.
class MenuState extends State {

    private var _manager as GameStateManager;

    // Initializes menu state dependencies
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    // Configures main menu option bars for New Game at 180 degrees, Continue at 0 degrees, and Stats at 90 degrees
    public function enter() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        _radialSystem.spawnLeftOptionBar("NEW GAME", Graphics.COLOR_GREEN, method(:onNewGameClicked));

        var continueColor = Graphics.COLOR_BLUE;
        if (_runContext != null && !_runContext.hasActiveSavedRun()) {
            continueColor = Graphics.COLOR_DK_GRAY;
        }
        _radialSystem.spawnRightOptionBar("CONTINUE", continueColor, method(:onContinueClicked));

        // Stats option bar positioned at 90 degrees (Top)
        _radialSystem.spawnTopOptionBar("STATS", Graphics.COLOR_PURPLE, method(:onStatsClicked));
    }

    // Renders dark solid background
    public function drawBackground(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    // Renders game title at 0.22 screen height and interaction prompt at 0.78 screen height
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.22).toNumber(), Graphics.FONT_MEDIUM, "RADIAL ROGUE", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.78).toNumber(), Graphics.FONT_XTINY, "Tap Bar to Select", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Resets run context and starts a fresh dungeon run
    public function onNewGameClicked(bar as RadialBar) as Void {
        if (_runContext != null) {
            _runContext.resetRun();
            _runContext.clearActiveRun();
        }
        if (_dungeonManager != null) {
            _dungeonManager.resetDungeon();
        }
        _manager.switchToEncounterIntroState();
    }

    // Resumes active saved run if present; falls back to new game
    public function onContinueClicked(bar as RadialBar) as Void {
        if (_runContext != null && _runContext.hasActiveSavedRun()) {
            var loaded = _runContext.loadActiveRun(_dungeonManager);
            if (loaded) {
                if (_dungeonManager != null && _dungeonManager.isChoiceStep()) {
                    _manager.switchToDungeonChoiceState();
                } else if (_dungeonManager != null && _dungeonManager.isShopStep()) {
                    _manager.switchToShopState();
                } else {
                    _manager.switchToEncounterIntroState();
                }
                return;
            }
        }

        onNewGameClicked(bar);
    }

    // Transitions to permanent records and statistics card
    public function onStatsClicked(bar as RadialBar) as Void {
        _manager.switchToStatsState();
    }
}
