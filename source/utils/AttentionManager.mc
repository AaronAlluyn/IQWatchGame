import Toybox.Attention;
import Toybox.Lang;

// Utility module providing safe haptic vibration feedback for smartwatch hardware.
(:AttentionManager)
module AttentionManager {

    public function vibrateHit() as Void {
        if (Attention has :vibrate) {
            try {
                var pattern = [
                    new Attention.VibeProfile(50, 60) // Short 60ms light pulse
                ];
                Attention.vibrate(pattern);
            } catch (ex) {}
        }
    }

    public function vibrateBlock() as Void {
        if (Attention has :vibrate) {
            try {
                var pattern = [
                    new Attention.VibeProfile(75, 80) // Medium 80ms block pulse
                ];
                Attention.vibrate(pattern);
            } catch (ex) {}
        }
    }

    public function vibrateDamage() as Void {
        if (Attention has :vibrate) {
            try {
                var pattern = [
                    new Attention.VibeProfile(100, 150) // Strong 150ms heavy damage pulse
                ];
                Attention.vibrate(pattern);
            } catch (ex) {}
        }
    }

    public function vibrateVictory() as Void {
        if (Attention has :vibrate) {
            try {
                var pattern = [
                    new Attention.VibeProfile(80, 80),
                    new Attention.VibeProfile(0, 50),
                    new Attention.VibeProfile(100, 120) // Double pulse victory chirp
                ];
                Attention.vibrate(pattern);
            } catch (ex) {}
        }
    }
}
