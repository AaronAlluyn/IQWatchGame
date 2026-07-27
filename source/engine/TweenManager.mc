import Toybox.Lang;
import Toybox.Math;

// Centralized animation and juicing engine.
// Manages procedural screen shake, track shake, targeted health diamond vibration, and parabolic coin pop curves.
class TweenManager {
    public var screenShakeTimer as Float = 0.0f;
    public var screenShakeIntensity as Number = 0;

    public var trackShakeTimer as Float = 0.0f;
    public var trackShakeIntensity as Number = 0;

    public var healthShakeTimer as Float = 0.0f;
    public var healthShakeIntensity as Number = 0;

    public var coinJumpTimer as Float = 0.0f;
    public var coinJumpAmount as Number = 0;
    private const COIN_JUMP_DURATION = 0.20f; // Fast 0.20s Mario-style coin pop curve

    function initialize() {
        reset();
    }

    public function reset() as Void {
        screenShakeTimer = 0.0f;
        trackShakeTimer = 0.0f;
        healthShakeTimer = 0.0f;
        coinJumpTimer = 0.0f;
    }

    // Triggers full view screen shake (used for player damage taken and boss phase enrage)
    public function triggerScreenShake(duration as Float, intensity as Number) as Void {
        screenShakeTimer = duration;
        screenShakeIntensity = intensity;
    }

    // Triggers track-only shake (used for bar hits and block feedback)
    public function triggerTrackShake(duration as Float, intensity as Number) as Void {
        trackShakeTimer = duration;
        trackShakeIntensity = intensity;
    }

    // Triggers targeted health diamond vibration
    public function triggerHealthShake(duration as Float, intensity as Number) as Void {
        healthShakeTimer = duration;
        healthShakeIntensity = intensity;
    }

    // Triggers snappy Mario-style coin pop jump
    public function triggerCoinJump(amount as Number) as Void {
        coinJumpTimer = COIN_JUMP_DURATION;
        coinJumpAmount = amount;
    }

    public function update(deltaTime as Float) as Void {
        if (screenShakeTimer > 0.0f) {
            screenShakeTimer -= deltaTime;
            if (screenShakeTimer < 0.0f) { screenShakeTimer = 0.0f; }
        }
        if (trackShakeTimer > 0.0f) {
            trackShakeTimer -= deltaTime;
            if (trackShakeTimer < 0.0f) { trackShakeTimer = 0.0f; }
        }
        if (healthShakeTimer > 0.0f) {
            healthShakeTimer -= deltaTime;
            if (healthShakeTimer < 0.0f) { healthShakeTimer = 0.0f; }
        }
        if (coinJumpTimer > 0.0f) {
            coinJumpTimer -= deltaTime;
            if (coinJumpTimer < 0.0f) { coinJumpTimer = 0.0f; }
        }
    }

    public function getScreenShakeOffsetX() as Number {
        if (screenShakeTimer > 0.0f && screenShakeIntensity > 0) {
            return (Math.rand() % (screenShakeIntensity * 2 + 1)) - screenShakeIntensity;
        }
        return 0;
    }

    public function getScreenShakeOffsetY() as Number {
        if (screenShakeTimer > 0.0f && screenShakeIntensity > 0) {
            return (Math.rand() % (screenShakeIntensity * 2 + 1)) - screenShakeIntensity;
        }
        return 0;
    }

    public function getTrackShakeOffsetX() as Number {
        if (trackShakeTimer > 0.0f && trackShakeIntensity > 0) {
            return (Math.rand() % (trackShakeIntensity * 2 + 1)) - trackShakeIntensity;
        }
        return 0;
    }

    public function getTrackShakeOffsetY() as Number {
        if (trackShakeTimer > 0.0f && trackShakeIntensity > 0) {
            return (Math.rand() % (trackShakeIntensity * 2 + 1)) - trackShakeIntensity;
        }
        return 0;
    }

    public function getHealthShakeOffsetX() as Number {
        if (healthShakeTimer > 0.0f && healthShakeIntensity > 0) {
            return (Math.rand() % (healthShakeIntensity * 2 + 1)) - healthShakeIntensity;
        }
        return 0;
    }

    public function getHealthShakeOffsetY() as Number {
        if (healthShakeTimer > 0.0f && healthShakeIntensity > 0) {
            return (Math.rand() % (healthShakeIntensity * 2 + 1)) - healthShakeIntensity;
        }
        return 0;
    }

    // Smooth parabolic arc for Mario coin jump: y = -4 * h * t * (1 - t)
    public function getCoinJumpOffsetY() as Number {
        if (coinJumpTimer > 0.0f) {
            var t = 1.0f - (coinJumpTimer / COIN_JUMP_DURATION);
            var height = 14.0f;
            var jumpY = -4.0f * height * t * (1.0f - t);
            return jumpY.toNumber();
        }
        return 0;
    }
}
