import Toybox.Lang;
import Toybox.WatchUi;

class IQWatchGameDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new IQWatchGameMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}