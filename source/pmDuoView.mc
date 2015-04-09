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
	var blinkOn = 0;
	
    function timercallback()
    {
    	blinkOn = 1 - blinkOn;
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
    	var curapp = App.getApp();
    
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
		dc.clear();
		
		dc.drawBitmap(2, 2, curapp.getSessionIcon());
		
		// Draw seperators
		dc.drawLine(  0,  34, dc.getWidth(),  34 );
		dc.drawLine(  0,  39, dc.getWidth(),  39 );
		dc.drawLine(  0,  52, dc.getWidth(),  52 );
		dc.drawLine(  0,  84, dc.getWidth(),  84 );
		dc.drawLine(  0, 116, dc.getWidth(), 116 );
		
		
		// Draw GPS Status
		var gpsinfo = Pos.getInfo();
		var gpsIsOkay = ( gpsinfo.accuracy == Pos.QUALITY_GOOD || gpsinfo.accuracy == Pos.QUALITY_USABLE );
		
		if( gpsinfo.accuracy == Pos.QUALITY_GOOD ) {
			dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
		} else if( gpsinfo.accuracy == Pos.QUALITY_USABLE ) {
			dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
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
        dc.drawText(dc.getWidth() - 2, 2, Gfx.FONT_MEDIUM, curapp.getEventTime(), Gfx.TEXT_JUSTIFY_RIGHT);
        
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);

		if( curapp.isSessionActive() ) {
			
			dc.drawText(2, 57, Gfx.FONT_SMALL, "Discipline:", Gfx.TEXT_JUSTIFY_LEFT);
	        dc.drawText(dc.getWidth() - 2, 54, Gfx.FONT_MEDIUM, curapp.getSessionTime(), Gfx.TEXT_JUSTIFY_RIGHT);

			var cursession = Act.getActivityInfo();
			if( cursession == null ) {
		        dc.drawText(dc.getWidth() / 2, 86, Gfx.FONT_MEDIUM, "No Activity", Gfx.TEXT_JUSTIFY_CENTER);
		        dc.drawText(dc.getWidth() / 2, 118, Gfx.FONT_MEDIUM, "Info Available", Gfx.TEXT_JUSTIFY_CENTER);
			} else {
				dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
				dc.drawText(2, 89, Gfx.FONT_SMALL, "Pace:", Gfx.TEXT_JUSTIFY_LEFT);
		        dc.drawText(dc.getWidth() - 2, 86, Gfx.FONT_MEDIUM, convertSpeedToPace(cursession.currentSpeed), Gfx.TEXT_JUSTIFY_RIGHT);
	
				dc.drawText(2, 121, Gfx.FONT_SMALL, "Distance:", Gfx.TEXT_JUSTIFY_LEFT);
		        dc.drawText(dc.getWidth() - 2, 118, Gfx.FONT_MEDIUM, convertDistance(cursession.elapsedDistance), Gfx.TEXT_JUSTIFY_RIGHT);
	        }
		} else if( curapp.getSessionStep() == 4 ) {
			dc.drawText(2, 57, Gfx.FONT_SMALL, "Cycle:", Gfx.TEXT_JUSTIFY_LEFT);
	        dc.drawText(dc.getWidth() - 2, 54, Gfx.FONT_MEDIUM, curapp.getEventStepTime(1), Gfx.TEXT_JUSTIFY_RIGHT);
			dc.drawText(2, 89, Gfx.FONT_SMALL, "Transition:", Gfx.TEXT_JUSTIFY_LEFT);
	        dc.drawText(dc.getWidth() - 2, 86, Gfx.FONT_MEDIUM, curapp.getEventStepTime(2), Gfx.TEXT_JUSTIFY_RIGHT);
			dc.drawText(2, 121, Gfx.FONT_SMALL, "Run:", Gfx.TEXT_JUSTIFY_LEFT);
	        dc.drawText(dc.getWidth() - 2, 118, Gfx.FONT_MEDIUM, curapp.getEventStepTime(3), Gfx.TEXT_JUSTIFY_RIGHT);
		}
		
		if( !gpsIsOkay ) {
			// Draw "Wait for GPS"
			var boxh = (dc.getFontHeight(Gfx.FONT_MEDIUM) * 2) + 6;
			
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.fillRectangle(dc.getWidth() / 6, (dc.getHeight() / 2) - (boxh / 2), (dc.getWidth() / 6) * 4, boxh);
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
			dc.drawRectangle(dc.getWidth() / 6, (dc.getHeight() / 2) - (boxh / 2), (dc.getWidth() / 6) * 4, boxh);

			if( blinkOn == 0 ) {
		        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2) - dc.getFontHeight(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, "Please Wait", Gfx.TEXT_JUSTIFY_CENTER);
		        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2), Gfx.FONT_MEDIUM, "For GPS", Gfx.TEXT_JUSTIFY_CENTER);
	        }
		}

    }
    
    function convertSpeedToPace(speed) {
    	var result_min;
    	var result_sec;
    	var result_per;
    	
		result_min = 0;
		result_sec = 0;
		result_per = "/km";

		if( speed != null && speed > 0 ) {
	    	var settings = Sys.getDeviceSettings();
	    	var secpermetre = 1.0d / speed;	// speed = m/s

	    	if( settings.paceUnits == Sys.UNIT_METRIC ) {
	    		result_sec = secpermetre * 1000.0d;
	    		result_per = "/km";
	    	} else {
	    		result_sec = secpermetre * 1609.34d;
	    		result_per = "/mi";
	    	}
			result_min = result_sec / 60;
			result_min = result_min.format("%d").toNumber();
			result_sec = result_sec - ( result_min * 60 );	// Remove the exact minutes, should leave remainder seconds
		}
		
    	return Lang.format("$1$:$2$$3$", [result_min, result_sec.format("%02d"), result_per]);
    }
    
    function convertDistance(metres) {
    	var result;
    	
    	if( metres == null ) {
    		result = 0;
    	} else {
	    	var settings = Sys.getDeviceSettings();
	    	if( settings.distanceUnits == Sys.UNIT_METRIC ) {
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