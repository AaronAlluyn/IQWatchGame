import Toybox.Lang;
import Toybox.Graphics;

// Abstract base class defining the contract and lifecycle methods for all game states.
class State {
    protected var _radialSystem as RadialSystem;
    protected var _runContext as RunContext or Null;
    protected var _dungeonManager as DungeonManager or Null;
    protected var _tweenManager as TweenManager or Null;

    // Initializes base references to core systems
    function initialize(radialSystem as RadialSystem, runContext as RunContext or Null, dungeonManager as DungeonManager or Null, tweenManager as TweenManager or Null) {
        _radialSystem = radialSystem;
        _runContext = runContext;
        _dungeonManager = dungeonManager;
        _tweenManager = tweenManager;
    }

    // Called when the state becomes active
    public function enter() as Void {}

    // Called on each frame update pass to advance timers and state physics
    public function update(deltaTime as Float) as Void {}

    // Renders state-specific background elements
    public function drawBackground(dc as Dc) as Void {}

    // Renders state-specific foreground elements and user interface text
    public function drawHUD(dc as Dc) as Void {}

    // Handles player input when no active radial bar is tapped
    public function onEmptySpaceHit() as Void {}

    // Refills radial bars based on state logic
    public function refillBars(frameCount as Long) as Void {}
}
