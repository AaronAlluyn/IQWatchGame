import Toybox.Lang;
import Toybox.Graphics;

// Mid-dungeon choice card allowing players to select Shop, Minigame, or Skip.
class DungeonChoiceState extends State {

    private var _manager as GameStateManager;

    // Initializes dungeon choice state dependencies
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;
    }

    // Configures option bars for Shop at 180 degrees, Minigame at 0 degrees, and Skip at 270 degrees
    public function enter() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        _radialSystem.spawnLeftOptionBar("SHOP", Graphics.COLOR_GREEN, method(:onShopClicked));
        _radialSystem.spawnRightOptionBar("MINIGAME", Graphics.COLOR_BLUE, method(:onMinigameClicked));
        _radialSystem.spawnBottomOptionBar("SKIP", Graphics.COLOR_DK_GRAY, method(:onSkipClicked));
    }

    // Renders dark navy background
    public function drawBackground(dc as Dc) as Void {
        dc.setColor(0x0a0a1f, 0x0a0a1f);
        dc.clear();
    }

    // Uncluttered HUD rendering
    public function drawHUD(dc as Dc) as Void {
    }

    // Switches to Shop state
    public function onShopClicked(bar as RadialBar) as Void {
        _manager.switchToShopState();
    }

    // Launches a random minigame from the pool
    public function onMinigameClicked(bar as RadialBar) as Void {
        _manager.launchRandomMinigame();
    }

    // Skips step and advances dungeon
    public function onSkipClicked(bar as RadialBar) as Void {
        _manager.onEncounterCleared();
    }
}
