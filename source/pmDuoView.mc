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
	
		//var keynum = Lang.format("$1$", [evt.getKey()]);
		//Sys.println(keynum);
		
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
        //setLayout(Rez.Layouts.MainLayout(dc));

		refreshtimer = new Timer.Timer();
		refreshtimer.start( method(:timercallback), 500, true );

    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		dc.clear();
		var stepNum = Lang.format("$1$", [App.getApp().getSessionStep()]);
        dc.drawText(0, 0, Gfx.FONT_MEDIUM, stepNum, Gfx.TEXT_JUSTIFY_LEFT);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }

}