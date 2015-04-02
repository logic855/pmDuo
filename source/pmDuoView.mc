using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Activity as Act;
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
		refreshtimer.start( method(:timercallback), 1000, true );
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
		dc.clear();
		
		dc.drawBitmap(2, 2, App.getApp().getSessionIcon());
		
		// Draw seperators
		dc.drawLine(  0,  34, dc.getWidth(),  34 );
		dc.drawLine(  0,  39, dc.getWidth(),  39 );
		dc.drawLine(  0,  52, dc.getWidth(),  52 );
		dc.drawLine(  0,  84, dc.getWidth(),  84 );
		dc.drawLine(  0, 116, dc.getWidth(), 116 );
		
		
		// Draw GPS Status
		var gpsinfo = Pos.getInfo();
		if( gpsinfo.accuracy == Pos.QUALITY_GOOD ) {
			dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
		} else if( gpsinfo.accuracy == Pos.QUALITY_USABLE ) {
			dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_BLACK);
		} else {
			dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
		}
		dc.fillRectangle(0, 35, dc.getWidth(), 3);
		
		// Draw event segments
		var poly;
		var segwidth = dc.getWidth() / 5;
		setChevronColour( dc, App.getApp().getSessionStep(), 1 );
		poly = [ [0, 40], [(segwidth * 2) - 4, 40], [(segwidth * 2) + 2, 46], [(segwidth * 2) - 4, 52], [0, 52] ];
		dc.fillPolygon(poly);
		setChevronColour( dc, App.getApp().getSessionStep(), 2 );
		poly = [ [(segwidth * 2) - 2, 40], [(segwidth * 3) - 4, 40], [(segwidth * 3) + 2, 46], [(segwidth * 3) - 4, 52], [(segwidth * 2) - 2, 52], [(segwidth * 2) + 4, 46] ];
		dc.fillPolygon(poly);
		setChevronColour( dc, App.getApp().getSessionStep(), 3 );
		poly = [ [(segwidth * 3) - 2, 40], [dc.getWidth(), 40], [dc.getWidth(), 52], [(segwidth * 3) - 2, 52], [(segwidth * 3) + 4, 46] ];
		dc.fillPolygon(poly);
		
		// Draw Data
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		
		dc.drawText(40, 2, Gfx.FONT_MEDIUM, "Event:", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth() - 2, 2, Gfx.FONT_MEDIUM, App.getApp().getEventTime(), Gfx.TEXT_JUSTIFY_RIGHT);

		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawText(2, 57, Gfx.FONT_SMALL, "Discipline:", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth() - 2, 54, Gfx.FONT_MEDIUM, App.getApp().getSessionTime(), Gfx.TEXT_JUSTIFY_RIGHT);

		var activity = Act.getActivityInfo();
		var acttxt = "";
		if( activity != null ) {
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
			dc.drawText(2, 89, Gfx.FONT_SMALL, "Pace:", Gfx.TEXT_JUSTIFY_LEFT);
	        dc.drawText(dc.getWidth() - 2, 86, Gfx.FONT_MEDIUM, convertSpeedToPace(activity.currentSpeed), Gfx.TEXT_JUSTIFY_RIGHT);

			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
			dc.drawText(2, 121, Gfx.FONT_SMALL, "Distance:", Gfx.TEXT_JUSTIFY_LEFT);
	        dc.drawText(dc.getWidth() - 2, 118, Gfx.FONT_MEDIUM, convertDistance(activity.elapsedDistance), Gfx.TEXT_JUSTIFY_RIGHT);
		} 

    }
    
    function convertSpeedToPace(speed) {
    	var result;
    	
		if( speed == null ) {
			result = 0;
		} else {
			// Speed = m/s; DeviceSettings.paceUnits == UNIT_METRIC or UNIT_STATUTE
			result = speed;
		}
		
    	return Lang.format("$1$", [result.format("%.2f")]);
    }
    
    function convertDistance(metres) {
    	var result;
    	
    	if( metres == null ) {
    		result = 0;
    	} else {
	    	
	    	if( Sys.getDeviceSettings().distanceUnits == UNIT_METRIC ) {
	    		result = metres / 1000.0;
	    	} else {
	    		result = metres / 1609.34;
	    	}
	    	
	    }
    	
    	return Lang.format("$1$", [result.format("%.2f")]);
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