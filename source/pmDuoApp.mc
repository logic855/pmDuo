using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Pos;
using Toybox.ActivityRecording as Rec;

class pmDuoApp extends App.AppBase {

	var session = null;
	var step = 0;


    //! onStart() is called on application start up
    function onStart() {
    	// Get the GPS ready
    	Pos.enableLocationEvents( Pos.LOCATION_CONTINUOUS, method(:onPosition));
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
        return [ new pmDuoView(), new pmDuoDelegate(), new pmDuoInputDelegate() ];
    }
    
    function onPosition(info) {
    }
    
    function isSessionActive() {
    	if( session != null ) {
    		return session.isRecording();
    	}
    	return false;
    }
    
    function startSession(withName, withSport) {
		if( session != null ) {
			stopSession();
		}
    	
    	// No "switch" statement available?
    	if( step == 0 ) {
			session = Rec.createSession( { :name=>"Duo:Cycle", :sport=>Rec.SPORT_CYCLING } );
		} else if( step == 1 ) {
   			session = Rec.createSession( { :name=>"Duo:Trans", :sport=>Rec.SPORT_TRANSITION } );
		} else if( step == 2 ) {
   			session = Rec.createSession( { :name=>"Duo:Run", :sport=>Rec.SPORT_RUNNING } );
		} else {
   			session = Rec.createSession( { :name=>"Duo:Error", :sport=>Rec.SPORT_GENERIC } );
    	}
    	session.start();
    	Ui.requestUpdate();
    }
    
    function stopSession() {
    	if( session != null && session.isRecording() ) {
    		session.stop();
    		session.save();
    	}
    	step++;
    	session = null;
    	Ui.requestUpdate();
    }
    
    function getSessionStep() {
    	return step;
    }

    function getSession() {
    	return session;
    }

}

class pmDuoDelegate extends Ui.BehaviorDelegate {

    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new pmDuoMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }

}