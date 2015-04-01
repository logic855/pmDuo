using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Pos;
using Toybox.ActivityRecording as Rec;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

class pmDuoApp extends App.AppBase {

	var session = null;
	
	var step = 0;
	var eventstart = 0;
	var sessionstart = 0;
	var sessionname;
	var sessionicon;

    //! onStart() is called on application start up
    function onStart() {
    	// Get the GPS ready
    	Pos.enableLocationEvents( Pos.LOCATION_CONTINUOUS, method(:onPosition));
    	sessionicon = Ui.loadResource(Rez.Drawables.StartIcon);
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    	// Make sure we finish the session
    	stopSession();
    	// Shut down GPS
    	Pos.enableLocationEvents( Pos.LOCATION_DISABLE, method(:onPosition));
    }

    //! Return the initial view of your application here
    function getInitialView() {
        // return [ new pmDuoView(), new pmDuoDelegate(), new pmDuoInputDelegate() ];
		return [ new pmDuoView(), new pmDuoInputDelegate() ];
    }
    
    function onPosition(info) {
    }
    
    function isSessionActive() {
    	if( session != null ) {
    		return session.isRecording();
    	}
    	return false;
    }
    
    function startSession() {
    
		if( session != null ) {
			stopSession();
		}
		
		// Set New Step
		step++;
		
		// No "switch" statement available?
    	if( step == 1 ) {
    		eventstart = Sys.getTimer();
    		sessionname = "Duo:Cycle";
			session = Rec.createSession( { :name=>sessionname, :sport=>Rec.SPORT_CYCLING } );
			sessionicon = Ui.loadResource(Rez.Drawables.CycleIcon);
		} else if( step == 2 ) {
			sessionname = "Duo:Trans";
   			session = Rec.createSession( { :name=>sessionname, :sport=>Rec.SPORT_TRANSITION } );
   			sessionicon = Ui.loadResource(Rez.Drawables.TransIcon);
		} else if( step == 3 ) {
			sessionname = "Duo:Run";
   			session = Rec.createSession( { :name=>sessionname, :sport=>Rec.SPORT_RUNNING } );
   			sessionicon = Ui.loadResource(Rez.Drawables.RunIcon);
		} else {
   			sessionicon = Ui.loadResource(Rez.Drawables.FinishIcon);
    	}
    	sessionstart = Sys.getTimer();
    	
    	// Finished?
    	if( session != null )
    	{
			var keynum = Lang.format("Starting $1$ ($2$)", [sessionname, step]);
			Sys.println(keynum);

    		session.start();
    	}
    }
    
    function stopSession() {
    	if( session != null && session.isRecording() ) {
    		session.stop();
    		session.save();
    	}
    	session = null;
    }
    
    function cancelSession() {
    	if( session != null && session.isRecording() ) {
    		session.stop();
    	}
    	session = null;
    }
    
    function getSessionStep() {
    	return step;
    }

    function getSession() {
    	return session;
    }
    
    function getSessionIcon() {
    	return sessionicon;
    }
    
    function restartSession() {
    	cancelSession();
    	if( step > 0 ) {
    		step--;
    	}
    }
    
    function restartEvent() {
    	cancelSession();
   		step = 0;
    }
    
    function getEventTime() {
    	return msToTime(Sys.getTimer() - eventstart);
    }
    
    function getSessionTime() {
    	return msToTime(Sys.getTimer() - sessionstart);
    }
    
    function msToTime(ms) {
    	if( step == 0 ) {
    		return "Ready";
    	}
    	if( step == 4 ) {
    		return "Finished";
    	}
    	var seconds = ms / 1000;
    	var minutes = ms / 60000;
    	var hours = ms / 3600000;
    	
    	return Lang.format("$1$:$2$.$3$", [hours, minutes.format("%02d"), seconds.format("%02d")]); 
    }

}

class pmDuoDelegate extends Ui.BehaviorDelegate {

    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new pmDuoMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }

}