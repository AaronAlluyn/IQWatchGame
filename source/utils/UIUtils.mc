import Toybox.Lang;
import Toybox.Graphics;

// Centralized rendering utility module for UI vector graphics, outlined typography, and HUD icons.
(:UIUtils)
module UIUtils {

    var _leftDiamondPoints as Array<[Numeric, Numeric]> = [ [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric] ];
    var _rightDiamondPoints as Array<[Numeric, Numeric]> = [ [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric], [0, 0] as [Numeric, Numeric] ];

    // Renders text with a four-way black outline shadow for readability on MIP displays
    function drawOutlinedText(dc as Dc, x as Number, y as Number, font as Graphics.FontDefinition, text as String, textColor as Number, justify as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 1, y, font, text, justify);
        dc.drawText(x - 1, y, font, text, justify);
        dc.drawText(x, y + 1, font, text, justify);
        dc.drawText(x, y - 1, font, text, justify);

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justify);
    }

    // Renders dual-polygon diamond symbol using pre-allocated coordinate buffers
    function drawDiamond(dc as Dc, cx as Number, cy as Number, size as Number, leftColor as Number, rightColor as Number) as Void {
        var s = size;
        
        _leftDiamondPoints[0][0] = cx;     _leftDiamondPoints[0][1] = cy - s;
        _leftDiamondPoints[1][0] = cx - s; _leftDiamondPoints[1][1] = cy;
        _leftDiamondPoints[2][0] = cx;     _leftDiamondPoints[2][1] = cy + s;

        _rightDiamondPoints[0][0] = cx;     _rightDiamondPoints[0][1] = cy - s;
        _rightDiamondPoints[1][0] = cx + s; _rightDiamondPoints[1][1] = cy;
        _rightDiamondPoints[2][0] = cx;     _rightDiamondPoints[2][1] = cy + s;

        dc.setColor(leftColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(_leftDiamondPoints);

        dc.setColor(rightColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(_rightDiamondPoints);
    }

    // Renders standard coin counter HUD element with diamond iconography
    function drawCoinCounter(dc as Dc, width as Number, height as Number, coins as Number, jumpOffsetY as Number) as Void {
        var coinX = (width / 2) - 15;
        var baseY = (height * 0.68).toNumber();
        var coinY = baseY + jumpOffsetY;

        drawDiamond(dc, coinX, coinY, 5, Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(coinX + 10, coinY, Graphics.FONT_TINY, "" + coins, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
