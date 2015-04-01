using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.ActivityRecording as Rec;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

class pmDuoInputDelegate extends Ui.InputDelegate {

	function onKey(evt) {
	
		var keynum = Lang.format("$1$", [evt.getKey()]);
		Sys.println(keynum);
		
		if( evt.getKey() == Ui.KEY_ENTER ) {
			App.getApp().startSession();
		}
	
	}
}

class pmDuoView extends Ui.View {

	var refreshtimer;
	
    function timercallback()
    {
        Ui.requestUpdate();
    }

    //! Load your resources here
    function onLayout(dc) {
		refreshtimer = new Timer.Timer();
		refreshtimer.start( method(:timercallback), 500, true );
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
		dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
		dc.clear();
		
		// Draw seperators
		dc.drawLine(  0,  50, dc.getWidth(),  50 );
		dc.drawLine(  0,  68, dc.getWidth(),  68 );
		dc.drawLine(  0,  74, dc.getWidth(),  74 );
		dc.drawLine(  0, 108, dc.getWidth(), 108 );
		
		
		// Draw GPS Status
		var gpsinfo = Pos.getInfo();
		if( gpsinfo.accuracy == Pos.QUALITY_GOOD ) {
			dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
		} else if( gpsinfo.accuracy == Pos.QUALITY_USABLE ) {
			dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_BLACK);
		} else {
			dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
		}
		dc.fillRectangle(0, 69, dc.getWidth(), 5);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		// dc.drawText( dc.getWidth() / 2, 64, Gfx.FONT_XTINY, "GPS", Gfx.TEXT_JUSTIFY_CENTER );
		
		// Draw event segments
		var poly;
		
		setChevronColour( dc, App.getApp().getSessionStep(), 1 );
		poly = [ [0, 51], [70, 51], [78, 59], [70, 67], [0, 67] ];
		dc.fillPolygon(poly);
		
		setChevronColour( dc, App.getApp().getSessionStep(), 2 );
		poly = [ [72, 51], [124, 51], [132, 59], [124, 67], [72, 67], [80, 59] ];
		dc.fillPolygon(poly);
		
		setChevronColour( dc, App.getApp().getSessionStep(), 3 );
		poly = [ [126, 51], [205, 51], [205, 67], [126, 67], [134, 59] ];
		dc.fillPolygon(poly);
		
		var stepNum = Lang.format("$1$, $2$", [App.getApp().getSessionStep(), dc.getHeight()]); // [App.getApp().getSessionStep()]);
        dc.drawText(10, 100, Gfx.FONT_LARGE, stepNum, Gfx.TEXT_JUSTIFY_LEFT);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }

	function setChevronColour(dc, step, chevron) {
		if( step > chevron ) {
			dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
		} else if( step == chevron ) {
			dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_BLACK);
		} else {
			dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
		}
	}
}