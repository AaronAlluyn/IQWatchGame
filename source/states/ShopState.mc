import Toybox.Lang;
import Toybox.Graphics;

// Multi-item replenishing shop state for purchasing HP heals and max HP upgrades.
class ShopState extends State {

    private var _manager as GameStateManager;

    private var _poolNames as Array<String>;
    private var _poolCosts as Array<Number>;
    private var _poolTypes as Array<Symbol>;
    private var _poolValues as Array<Number>;

    private var _activeIndices as Array<Number>;
    private var _nextPoolIndex as Number = 3;

    // Initializes shop inventory item pool
    function initialize(radialSystem as RadialSystem, runContext as RunContext, dungeonManager as DungeonManager, tweenManager as TweenManager, manager as GameStateManager) {
        State.initialize(radialSystem, runContext, dungeonManager, tweenManager);
        _manager = manager;

        _poolNames = ["HEAL 2HP", "+2 MAX HP", "HEAL 2HP", "+2 MAX HP", "HEAL 4HP", "+2 MAX HP"];
        _poolCosts = [5, 10, 5, 10, 8, 12];
        _poolTypes = [:HEAL, :MAX_HP, :HEAL, :MAX_HP, :HEAL, :MAX_HP];
        _poolValues = [2, 2, 2, 2, 4, 2];

        _activeIndices = [0, 1, 2];
    }

    // Resets pool pointer and populates initial 3 shop slots
    public function enter() as Void {
        _nextPoolIndex = 3;
        _activeIndices[0] = 0;
        _activeIndices[1] = 1;
        _activeIndices[2] = 2;

        refreshShopBars();
    }

    // Refills active shop radial bars at 180 deg, 0 deg, 90 deg, and 270 deg
    private function refreshShopBars() as Void {
        _radialSystem.clearBars();
        _radialSystem.setSpinSpeed(60.0f);

        // Slot 0: Left bar (180 degrees)
        if (_activeIndices[0] >= 0 && _activeIndices[0] < _poolNames.size()) {
            var idx = _activeIndices[0];
            _radialSystem.spawnBarWithCost(
                150.0f, 210.0f, 0.0f, 0.0f,
                Graphics.COLOR_GREEN, 0,
                method(:onSlot0Bought), null,
                :NORMAL, 1.0f, _poolNames[idx], _poolCosts[idx]
            );
        }

        // Slot 1: Right bar (0 degrees)
        if (_activeIndices[1] >= 0 && _activeIndices[1] < _poolNames.size()) {
            var idx = _activeIndices[1];
            _radialSystem.spawnBarWithCost(
                330.0f, 30.0f, 0.0f, 0.0f,
                Graphics.COLOR_RED, 1,
                method(:onSlot1Bought), null,
                :NORMAL, 1.0f, _poolNames[idx], _poolCosts[idx]
            );
        }

        // Slot 2: Top bar (90 degrees)
        if (_activeIndices[2] >= 0 && _activeIndices[2] < _poolNames.size()) {
            var idx = _activeIndices[2];
            _radialSystem.spawnBarWithCost(
                60.0f, 120.0f, 0.0f, 0.0f,
                Graphics.COLOR_GREEN, 2,
                method(:onSlot2Bought), null,
                :NORMAL, 1.0f, _poolNames[idx], _poolCosts[idx]
            );
        }

        // Leave bar: Bottom bar (270 degrees)
        _radialSystem.spawnBottomOptionBar("LEAVE", Graphics.COLOR_BLUE, method(:onLeaveClicked));
    }

    // Processes item purchase and replenishes stock from pool
    private function processPurchase(slotIndex as Number) as Void {
        var poolIndex = _activeIndices[slotIndex];
        if (poolIndex < 0 || poolIndex >= _poolNames.size()) {
            return;
        }

        var cost = _poolCosts[poolIndex];
        if (_runContext != null && _runContext.spendCoins(cost)) {
            var itemType = _poolTypes[poolIndex];
            var val = _poolValues[poolIndex];

            if (itemType == :HEAL) {
                _runContext.heal(val);
            } else if (itemType == :MAX_HP) {
                _runContext.addMaxHP(val);
            }

            if (_nextPoolIndex < _poolNames.size()) {
                _activeIndices[slotIndex] = _nextPoolIndex;
                _nextPoolIndex++;
            } else {
                _activeIndices[slotIndex] = -1;
            }

            refreshShopBars();
        }
    }

    public function onSlot0Bought(bar as RadialBar) as Void {
        processPurchase(0);
    }

    public function onSlot1Bought(bar as RadialBar) as Void {
        processPurchase(1);
    }

    public function onSlot2Bought(bar as RadialBar) as Void {
        processPurchase(2);
    }

    public function onLeaveClicked(bar as RadialBar) as Void {
        _manager.onEncounterCleared();
    }

    // Renders dark teal background
    public function drawBackground(dc as Dc) as Void {
        dc.setColor(0x001A1A, 0x001A1A);
        dc.clear();
    }

    // Renders shop title header and coin counter
    public function drawHUD(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 0.22).toNumber(), Graphics.FONT_MEDIUM, "SHOP", Graphics.TEXT_JUSTIFY_CENTER);

        if (_runContext != null) {
            UIUtils.drawCoinCounter(dc, width, height, _runContext.coins, 0);
        }
    }
}