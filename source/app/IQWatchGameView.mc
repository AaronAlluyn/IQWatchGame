import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.System;

class IQWatchGameView extends WatchUi.View {

    private var _timer as Timer.Timer or Null = null;
    private var _gameStateManager as GameStateManager or Null = null;
    private var _lastTime as Long = 0l;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _gameStateManager = new GameStateManager();
        _lastTime = System.getTimer().toLong();

        _timer = new Timer.Timer();
        _timer.start(method(:onTimerTick), 33, true); // ~30 FPS loop
    }

    public function handleInput() as Void {
        if (_gameStateManager != null) {
            _gameStateManager.handleInput();
        }
    }

    public function saveActiveRun() as Void {
        if (_gameStateManager != null) {
            _gameStateManager.saveActiveRun();
        }
    }

    function onHide() as Void {
        saveActiveRun();

        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        _gameStateManager = null;
    }

    function onTimerTick() as Void {
        var currentTime = System.getTimer().toLong();
        var deltaTime = (currentTime - _lastTime) / 1000.0f;
        _lastTime = currentTime;

        if (deltaTime <= 0.0f || deltaTime > 0.1f) {
            deltaTime = 0.033f;
        }

        if (_gameStateManager != null) {
            _gameStateManager.update(deltaTime);
        }

        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        if (_gameStateManager != null) {
            _gameStateManager.draw(dc);
        }
    }
}