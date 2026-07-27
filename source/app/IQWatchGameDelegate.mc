import Toybox.Lang;
import Toybox.WatchUi;

class IQWatchGameDelegate extends WatchUi.BehaviorDelegate {
    private var _view as IQWatchGameView;

    function initialize(view as IQWatchGameView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Handle the single tap/button press
    function onSelect() as Boolean {
        _view.handleInput();
        return true;
    }
}