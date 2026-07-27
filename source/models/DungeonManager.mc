import Toybox.Lang;

class DungeonManager {

    private var _currentFloor as Number = 1;
    private var _currentStep as Number = 1; // 1: Enc 1, 2: Enc 2, 3: Choice (Shop/Minigame), 4: Boss

    private var _floorEncounterPool as Array<Symbol>;

    function initialize() {
        _floorEncounterPool = [:SLIME_ENCOUNTER, :KNIGHT_ENCOUNTER, :NINJA_ENCOUNTER];
        resetDungeon();
    }

    public function resetDungeon() as Void {
        _currentFloor = 1;
        _currentStep = 1;
    }

    public function setFloorAndStep(floor as Number, step as Number) as Void {
        _currentFloor = floor;
        _currentStep = step;
    }

    public function getCurrentFloor() as Number {
        return _currentFloor;
    }

    public function getCurrentStep() as Number {
        return _currentStep;
    }

    public function isShopStep() as Boolean {
        return false;
    }

    public function isChoiceStep() as Boolean {
        return (_currentStep == 3);
    }

    public function isBossStep() as Boolean {
        return (_currentStep == 4);
    }

    public function getCurrentEncounterKey() as Symbol {
        if (_currentStep == 4) {
            return :SLIME_BOSS_ENCOUNTER;
        }

        if (_floorEncounterPool.size() > 0) {
            var index = (_currentFloor + _currentStep - 2) % _floorEncounterPool.size();
            return _floorEncounterPool[index];
        }

        return :SLIME_ENCOUNTER;
    }

    public function advanceStep() as Boolean {
        _currentStep += 1;
        if (_currentStep > 4) {
            _currentStep = 1;
            _currentFloor += 1;
            return true; // Floor cleared
        }
        return false;
    }

    public function getFloorSpeedMultiplier() as Float {
        return 1.0f + ((_currentFloor - 1) * 0.08f);
    }

    public function getFloorHealthBonus() as Number {
        return (_currentFloor - 1) * 2;
    }
}
