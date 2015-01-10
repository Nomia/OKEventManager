Integrate phonegap app with EventKit(IOS only)
=============

    cordova.plugins.okEventManager.createCalendar(title,success,failure);
    
    cordova.plugins.okEventManager.createEventWithCal(calendarIdentifier,{title:"my event",notes:"my notes",startInt:Date.now()/1000,endInt:Date.now()/1000 + 60},success,failure);
    
    cordova.plugins.okEventManager.updateEventWithId(eventIdentifier,{...},success,failure);
    
    cordova.plugins.okEventManager.deleteEventWithId(eventIdentifier,success,failure);
    
    cordova.plugins.okEventManager.requestAccess(success,failure);

use this plugin at ease and at your own risk :>
