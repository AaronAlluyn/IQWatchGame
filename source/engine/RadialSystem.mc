import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;

// Core geometry, collision detection, and rendering engine for the 360-degree radial track.
// Manages needle rotation physics, resolution normalization, and an object pool of RadialBar entities.
class RadialSystem {
    private const _poolSize = 15;
    private var _bars as Array<RadialBar>;
    private var _indicatorAngle as Float = 0.0f;
    private var _spinMagnitude as Float = 90.0f;
    private var _spinDirection as Number = 1;
    private var _freezeTimer as Float = 0.0f;
    private var _lastRadius as Number = 100;

    function initialize() {
        _bars = new Array<RadialBar>[_poolSize];
        for (var i = 0; i < _poolSize; i++) {
            _bars[i] = new RadialBar();
        }
        _lastRadius = 100;
    }

    // Returns current polar needle angle in degrees [0, 360)
    public function getIndicatorAngle() as Float {
        return _indicatorAngle;
    }

    // Deactivates all bars in the object pool without heap re-allocations
    public function clearBars() as Void {
        _freezeTimer = 0.0f;
        for (var i = 0; i < _poolSize; i++) {
            _bars[i].isActive = false;
            _bars[i].pendingHit = false;
            _bars[i].pendingMiss = false;
            _bars[i].isHitAnim = false;
        }
    }

    public function spawnBar(start as Float, end as Float, shrink as Float, rotation as Float, color as Number, payload as Object or Null, onHit as Method or Null, onMiss as Method or Null, bType as Symbol or Null, bVal as Float, labelText as String or Null) as Void {
        spawnBarWithCost(start, end, shrink, rotation, color, payload, onHit, onMiss, bType, bVal, labelText, 0);
    }

    // Recycles first inactive RadialBar from object pool and overwrites properties
    public function spawnBarWithCost(start as Float, end as Float, shrink as Float, rotation as Float, color as Number, payload as Object or Null, onHit as Method or Null, onMiss as Method or Null, bType as Symbol or Null, bVal as Float, labelText as String or Null, cost as Number) as Void {
        for (var i = 0; i < _poolSize; i++) {
            if (!_bars[i].isActive) {
                _bars[i].setup(start, end, shrink, rotation, color, payload, onHit, onMiss, bType, bVal, labelText, cost);
                return;
            }
        }
    }

    // Convenience navigation bar helpers at cardinal polar angles (180 deg, 0 deg, 270 deg, 90 deg)
    public function spawnLeftOptionBar(labelText as String, color as Number, onHit as Method or Null) as Void {
        spawnBar(150.0f, 210.0f, 0.0f, 0.0f, color, null, onHit, null, :NORMAL, 1.0f, labelText);
    }

    public function spawnRightOptionBar(labelText as String, color as Number, onHit as Method or Null) as Void {
        spawnBar(330.0f, 30.0f, 0.0f, 0.0f, color, null, onHit, null, :NORMAL, 1.0f, labelText);
    }

    public function spawnBottomOptionBar(labelText as String, color as Number, onHit as Method or Null) as Void {
        spawnBar(240.0f, 300.0f, 0.0f, 0.0f, color, null, onHit, null, :NORMAL, 1.0f, labelText);
    }

    public function spawnTopOptionBar(labelText as String, color as Number, onHit as Method or Null) as Void {
        spawnBar(60.0f, 120.0f, 0.0f, 0.0f, color, null, onHit, null, :NORMAL, 1.0f, labelText);
    }

    public function getOccupiedSpace() as Float {
        var totalWidth = 0.0f;
        for (var i = 0; i < _poolSize; i++) {
            var bar = _bars[i];
            if (bar.isActive) {
                totalWidth += bar.width;
            }
        }
        return totalWidth;
    }

    private function isAngleInArc(angle as Float, start as Float, end as Float) as Boolean {
        if (start <= end) {
            return angle >= start && angle <= end;
        } else {
            return angle >= start || angle <= end;
        }
    }

    private function doesBarOverlap(start1 as Float, end1 as Float, start2 as Float, end2 as Float) as Boolean {
        return (isAngleInArc(start1, start2, end2) || isAngleInArc(end1, start2, end2) || isAngleInArc(start2, start1, end1) || isAngleInArc(end2, start1, end1));
    }

    public function isSpaceFree(start as Float, end as Float) as Boolean {
        for (var i = 0; i < _poolSize; i++) {
            var bar = _bars[i];
            if (bar.isActive && doesBarOverlap(start, end, bar.getStartAngle(), bar.getEndAngle())) {
                return false;
            }
        }
        return true;
    }

    public function getBarCount() as Number {
        return _poolSize;
    }

    public function getBar(index as Number) as RadialBar {
        return _bars[index];
    }

    public function setSpinSpeed(speed as Float) as Void {
        _spinMagnitude = speed;
    }

    public function reverseSpinDirection() as Void {
        _spinDirection *= -1;
    }

    public function freezeIndicator(duration as Float) as Void {
        _freezeTimer = duration;
    }

    // Updates needle rotation, resolution normalization, and active bar lifetimes
    public function update(deltaTime as Float, frameCount as Long) as Void {
        if (_freezeTimer > 0) {
            _freezeTimer -= deltaTime;
        } else {
            var speedMultiplier = 1.0f;
            for (var i = 0; i < _poolSize; i++) {
                var bar = _bars[i];
                if (bar.isActive && bar.behaviorType == :STICKY_ZONE) {
                    var s = bar.getStartAngle();
                    var e = bar.getEndAngle();
                    if (isAngleInArc(_indicatorAngle, s, e)) {
                        speedMultiplier *= bar.behaviorValue;
                    }
                }
            }

            // Resolution Normalization: Scale angular velocity by 100.0 / radius
            var resolutionScale = 100.0f / (_lastRadius > 0 ? _lastRadius.toFloat() : 100.0f);
            var currentSpinSpeed = _spinMagnitude * _spinDirection * speedMultiplier * resolutionScale;
            _indicatorAngle += currentSpinSpeed * deltaTime;
            if (_indicatorAngle >= 360.0f) {
                _indicatorAngle -= 360.0f;
            } else if (_indicatorAngle < 0.0f) {
                _indicatorAngle += 360.0f;
            }
        }

        for (var i = 0; i < _poolSize; i++) {
            var bar = _bars[i];
            if (bar.isActive) {
                bar.update(deltaTime);
            }
        }

        for (var i = 0; i < _poolSize; i++) {
            var bar = _bars[i];
            if (bar.pendingMiss) {
                bar.pendingMiss = false;
                bar.onMiss();
            }
        }

        for (var i = 0; i < _poolSize; i++) {
            var bar = _bars[i];
            if (bar.pendingHit) {
                bar.pendingHit = false;
                bar.onHit();
            }
        }
    }

    // Checks polar bounds collision between indicator needle and active target bars
    public function handleInput(frameCount as Long) as Boolean {
        var hit = false;
        for (var i = 0; i < _bars.size(); i++) {
            var bar = _bars[i];
            if (bar.isActive && !bar.pendingHit && !bar.isHitAnim) {
                var start = bar.getStartAngle();
                var end = bar.getEndAngle();
                var isHit = false;

                if (bar.isWrapAround()) {
                    isHit = (_indicatorAngle >= start || _indicatorAngle <= end);
                } else {
                    isHit = (_indicatorAngle >= start && _indicatorAngle <= end);
                }

                if (isHit) {
                    bar.triggerHitAnim();
                    hit = true;
                }
            }
        }
        return hit;
    }

    public function draw(dc as Dc) as Void {
        drawOffset(dc, 0, 0);
    }

    // Main render pipeline: 1. Track Arc -> 2. Active Bars -> 3. Radial Labels -> 4. Indicator Needle
    public function drawOffset(dc as Dc, offsetX as Number, offsetY as Number) as Void {
        var cx = (dc.getWidth() / 2) + offsetX;
        var cy = (dc.getHeight() / 2) + offsetY;
        var radius = (dc.getWidth() < dc.getHeight() ? dc.getWidth() / 2 : dc.getHeight() / 2) - 20;
        _lastRadius = radius;

        // 1. Draw static circular track
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 0, 360);

        // 2. Draw active bars with tangential shake offsets
        for (var i = 0; i < _bars.size(); i++) {
            var bar = _bars[i];
            if (!bar.isActive || bar.width <= 0.0f) {
                continue;
            }

            var barDx = bar.getShakeOffsetX();
            var barDy = bar.getShakeOffsetY();
            var barCx = cx + barDx;
            var barCy = cy + barDy;

            var drawColor = bar.color;
            if (bar.isHitAnim) {
                drawColor = getDarkColor(bar.color);
            }

            dc.setColor(drawColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(12);

            var start = bar.getStartAngle();
            var end = bar.getEndAngle();
            var width = bar.width;

            if (width >= 360.0f) {
                dc.drawArc(barCx, barCy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 0, 360);
            } else if (bar.isWrapAround()) {
                var startInt = Math.round(start).toNumber();
                var endInt = Math.round(end).toNumber();

                if (startInt < 360) {
                    dc.drawArc(barCx, barCy, radius, Graphics.ARC_COUNTER_CLOCKWISE, startInt, 360);
                }
                if (endInt > 0) {
                    dc.drawArc(barCx, barCy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 0, endInt);
                }
            } else {
                var startInt = Math.round(start).toNumber();
                var endInt = Math.round(end).toNumber();

                if (endInt > startInt) {
                    dc.drawArc(barCx, barCy, radius, Graphics.ARC_COUNTER_CLOCKWISE, startInt, endInt);
                }
            }
        }

        // 3. Draw radial text labels
        for (var i = 0; i < _bars.size(); i++) {
            var bar = _bars[i];
            if (bar.isActive && bar.label != null && bar.width > 0.0f) {
                var angle = bar.centerAngle;
                var rad = angle * Math.PI / 180.0;
                var labelRadius = radius - 10;
                var lx = (cx + bar.getShakeOffsetX() + labelRadius * Math.cos(rad)).toNumber();
                var ly = (cy + bar.getShakeOffsetY() - labelRadius * Math.sin(rad)).toNumber();

                var quadrant = :RIGHT;
                if (angle >= 45.0f && angle <= 135.0f) {
                    quadrant = :TOP;
                } else if (angle >= 225.0f && angle <= 315.0f) {
                    quadrant = :BOTTOM;
                } else if (angle > 135.0f && angle < 225.0f) {
                    quadrant = :LEFT;
                }

                var textColor = getDarkColor(bar.color);

                if (bar.cost > 0) {
                    var line1Y = ly - 7;
                    var line2Y = ly + 7;

                    if (quadrant == :LEFT) {
                        UIUtils.drawOutlinedText(dc, lx, line1Y, Graphics.FONT_XTINY, bar.label, textColor, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

                        UIUtils.drawDiamond(dc, lx + 6, line2Y, 4, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);
                        UIUtils.drawOutlinedText(dc, lx + 14, line2Y, Graphics.FONT_XTINY, "" + bar.cost, Graphics.COLOR_YELLOW, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                    } else if (quadrant == :RIGHT) {
                        UIUtils.drawOutlinedText(dc, lx, line1Y, Graphics.FONT_XTINY, bar.label, textColor, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

                        UIUtils.drawOutlinedText(dc, lx - 2, line2Y, Graphics.FONT_XTINY, "" + bar.cost, Graphics.COLOR_YELLOW, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
                        UIUtils.drawDiamond(dc, lx - 24, line2Y, 4, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);
                    } else {
                        UIUtils.drawOutlinedText(dc, lx, line1Y, Graphics.FONT_XTINY, bar.label, textColor, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

                        UIUtils.drawDiamond(dc, lx - 8, line2Y, 4, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);
                        UIUtils.drawOutlinedText(dc, lx + 2, line2Y, Graphics.FONT_XTINY, "" + bar.cost, Graphics.COLOR_YELLOW, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                    }
                } else {
                    var justify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
                    if (quadrant == :LEFT) {
                        justify = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
                    } else if (quadrant == :RIGHT) {
                        justify = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;
                    }

                    UIUtils.drawOutlinedText(dc, lx, ly, Graphics.FONT_XTINY, bar.label, textColor, justify);
                }
            }
        }

        // 4. Draw rotating indicator needle
        var rad = _indicatorAngle * Math.PI / 180.0;
        var cosRad = Math.cos(rad);
        var sinRad = Math.sin(rad);

        var innerRadius = radius - 8;
        var outerRadius = radius + 8;
        var x1 = cx + innerRadius * cosRad;
        var y1 = cy - innerRadius * sinRad;
        var x2 = cx + outerRadius * cosRad;
        var y2 = cy - outerRadius * sinRad;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(x1, y1, x2, y2);
    }

    // Returns a darkened tone of the bar color to ensure label text contrast
    private function getDarkColor(c as Number) as Number {
        if (c == Graphics.COLOR_WHITE) {
            return Graphics.COLOR_DK_GRAY;
        } else if (c == Graphics.COLOR_GREEN) {
            return Graphics.COLOR_DK_GREEN;
        } else if (c == Graphics.COLOR_BLUE) {
            return Graphics.COLOR_DK_BLUE;
        } else if (c == Graphics.COLOR_RED) {
            return Graphics.COLOR_DK_RED;
        } else if (c == Graphics.COLOR_ORANGE) {
            return Graphics.COLOR_DK_RED;
        } else if (c == Graphics.COLOR_PURPLE) {
            return Graphics.COLOR_PURPLE;
        } else if (c == Graphics.COLOR_YELLOW) {
            return Graphics.COLOR_ORANGE;
        }
        return Graphics.COLOR_DK_GRAY;
    }
}