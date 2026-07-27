import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class IQWatchGameApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here.
    // The return type must be an Array of a View and an InputDelegate.
    public function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ]  {
        var view = new IQWatchGameView();
        return [view, new IQWatchGameDelegate(view)];
    }
}