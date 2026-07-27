import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Data entity representing an arc target on the radial track.
// Uses centerAngle + width polar representation to handle 360/0 degree wrap-around seamlessly.
class RadialBar {
    public var centerAngle as Float;
    public var width as Float;
    public var shrinkRate as Float;
    public var rotationSpeed as Float;
    public var color as Number;
    public var isActive as Boolean;
    public var pendingHit as Boolean;
    public var pendingMiss as Boolean;
    public var payload as Object or Null;
    public var label as String or Null;
    public var cost as Number = 0;

    public var behaviorType as Symbol;
    public var behaviorValue as Float;

    public var shakeTimer as Float = 0.0f;
    public var shakeIntensity as Number = 0;

    public var isHitAnim as Boolean = false;
    public var hitAnimTimer as Float = 0.0f;

    private var _onHitMethod as Method or Null;
    private var _onMissMethod as Method or Null;

    function initialize() {
        isActive = false;
        pendingHit = false;
        pendingMiss = false;
        centerAngle = 0.0f;
        width = 0.0f;
        shrinkRate = 0.0f;
        rotationSpeed = 0.0f;
        color = Graphics.COLOR_TRANSPARENT;
        payload = null;
        label = null;
        cost = 0;
        behaviorType = :NORMAL;
        behaviorValue = 1.0f;
        shakeTimer = 0.0f;
        shakeIntensity = 0;
        isHitAnim = false;
        hitAnimTimer = 0.0f;
        _onHitMethod = null;
        _onMissMethod = null;
    }

    // Triggers local per-bar shake vibration
    public function triggerBarShake(duration as Float, intensity as Number) as Void {
        shakeTimer = duration;
        shakeIntensity = intensity;
    }

    // Defers bar deactivation for 0.12s while playing hit animation and tangential shake
    public function triggerHitAnim() as Void {
        isHitAnim = true;
        hitAnimTimer = 0.12f;
        shakeTimer = 0.12f;
        shakeIntensity = 6;
    }

    // Calculates tangential X displacement along circular arc tangent (-sin(theta), -cos(theta))
    public function getShakeOffsetX() as Number {
        if (shakeTimer > 0.0f && shakeIntensity > 0) {
            var rad = centerAngle * Math.PI / 180.0;
            var aTangent = (Math.rand() % (shakeIntensity * 2 + 1)) - shakeIntensity;
            var aRadial = (Math.rand() % 3) - 1;

            var dx = aTangent * (-Math.sin(rad)) + aRadial * Math.cos(rad);
            return dx.toNumber();
        }
        return 0;
    }

    // Calculates tangential Y displacement along circular arc tangent (-sin(theta), -cos(theta))
    public function getShakeOffsetY() as Number {
        if (shakeTimer > 0.0f && shakeIntensity > 0) {
            var rad = centerAngle * Math.PI / 180.0;
            var aTangent = (Math.rand() % (shakeIntensity * 2 + 1)) - shakeIntensity;
            var aRadial = (Math.rand() % 3) - 1;

            var dy = aTangent * (-Math.cos(rad)) - aRadial * Math.sin(rad);
            return dy.toNumber();
        }
        return 0;
    }

    // Sets up bar parameters when recycled from the object pool
    public function setup(start as Float, end as Float, shrink as Float, rotation as Float, c as Number, p as Object or Null, onHit as Method or Null, onMiss as Method or Null, bType as Symbol or Null, bVal as Float, textLabel as String or Null, barCost as Number) as Void {
        start = normalizeAngle(start);
        end = normalizeAngle(end);

        if (start <= end) {
            width = end - start;
            centerAngle = start + (width / 2.0f);
        } else {
            width = (360.0f - start) + end;
            centerAngle = start + (width / 2.0f);
        }

        centerAngle = normalizeAngle(centerAngle);
        shrinkRate = shrink;
        rotationSpeed = rotation;
        color = c;
        payload = p;
        label = textLabel;
        cost = barCost;
        _onHitMethod = onHit;
        _onMissMethod = onMiss;
        behaviorType = (bType != null) ? bType : :NORMAL;
        behaviorValue = bVal;
        shakeTimer = 0.0f;
        shakeIntensity = 0;
        isHitAnim = false;
        hitAnimTimer = 0.0f;
        pendingHit = false;
        pendingMiss = false;
        isActive = true;
    }

    // Updates shrinkage, rotation, and hit animation timers
    public function update(deltaTime as Float) as Void {
        if (!isActive) {
            return;
        }

        if (shakeTimer > 0.0f) {
            shakeTimer -= deltaTime;
            if (shakeTimer < 0.0f) {
                shakeTimer = 0.0f;
            }
        }

        if (isHitAnim) {
            hitAnimTimer -= deltaTime;
            if (hitAnimTimer <= 0.0f) {
                hitAnimTimer = 0.0f;
                isHitAnim = false;
                isActive = false;
                pendingHit = true;
            }
            return;
        }

        if (rotationSpeed != 0.0f) {
            centerAngle += rotationSpeed * deltaTime;
            centerAngle = normalizeAngle(centerAngle);
        }

        if (behaviorType == :GROWING_BOMB) {
            width += shrinkRate * deltaTime;
            if (width >= 120.0f) {
                width = 120.0f;
                isActive = false;
                pendingMiss = true;
            }
        } else if (shrinkRate > 0.0f && behaviorType != :STICKY_ZONE) {
            width -= shrinkRate * deltaTime;
            if (width <= 0.0f) {
                width = 0.0f;
                isActive = false;
                pendingMiss = true;
            }
        }
    }

    public function normalizeAngle(angle as Float) as Float {
        while (angle >= 360.0f) { angle -= 360.0f; }
        while (angle < 0.0f) { angle += 360.0f; }
        return angle;
    }

    public function getStartAngle() as Float {
        return normalizeAngle(centerAngle - (width / 2.0f));
    }

    public function getEndAngle() as Float {
        return normalizeAngle(centerAngle + (width / 2.0f));
    }

    public function isWrapAround() as Boolean {
        var start = getStartAngle();
        var end = getEndAngle();
        return (start > end) || (width >= 360.0f);
    }

    public function onHit() as Void {
        if (_onHitMethod != null) {
            _onHitMethod.invoke(self);
        }
    }

    public function onMiss() as Void {
        if (_onMissMethod != null) {
            _onMissMethod.invoke(self);
        }
    }
}