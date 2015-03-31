using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.ActivityRecording as Rec;
using Toybox.Position as Pos;

class pmDuoInputDelegate extends Ui.InputDelegate {
	function onKey(evt) {
	
		if( evt == Ui.KEY_POWER ) {
			// Backlight...
		} else {
			// Any other button
			if( pmDuoApp.isSessionActive() ) {
				pmDuoView.stopStep();
			} else {
				pmDuoView.startStep();
			}
		}
	
	}
}

class pmDuoView extends Ui.View {



    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }

}