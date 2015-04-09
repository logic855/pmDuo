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
	
	var currentspeed;
	var currentdistance;
	
	var times_total = 0;
	var times_cycle = 0;
	var times_trans = 0;
	var times_run = 0;

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
    	//currentspeed = info.position.currentSpeed;
    	//currentdistance = info.position.elapsedDistance;
    }
    
    function getSessionSpeed() {
    	return currentspeed;
    }
    
    function getSessionDistance() {
    	return currentdistance;
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
    		
	    	var curtime = Sys.getTimer() - sessionstart;
	    	if( step == 1 ) {
	    		times_cycle = curtime;
	    	} else if( step == 2 ) {
	    		times_trans = curtime;
	    	} else if( step == 3 ) {
	    		times_run = curtime;
	    	}
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
    	if( step == 0 ) {
    		times_total = 0; 
    	} else if( step < 4 ) {
    		times_total = Sys.getTimer() - eventstart;
    	}
    	return msToTime(times_total);
    }
    
    function getSessionTime() {
    	var curtime = Sys.getTimer() - sessionstart;
    	return msToTime(curtime);
    }
    
    function getEventStepTime(step) {
    	if( step == 1 ) {
    		return msToTime(times_cycle);
    	} else if( step == 2 ) {
    		return msToTime(times_trans);
    	} else if( step == 3 ) {
    		return msToTime(times_run);
    	}
    	return "";
    }
    
    function msToTime(ms) {
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