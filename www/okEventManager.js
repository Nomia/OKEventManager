var cordova = require('cordova');

OKEventManager = function(){}

OKEventManager.prototype.createCalendar = function(title,options,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "createCalendar", [title,options]);
};

OKEventManager.prototype.createEventWithCal = function(calId,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "createEventWithCal", [calId]);
};

OKEventManager.prototype.updateEventWithId = function(eventId,options,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "updateEventWithId", [eventId,options]);
};

OKEventManager.prototype.deleteEventWithId = function(eventId,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "deleteEventWithId", [eventId]);
};

OKEventManager.prototype.requestAccess = function(onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "requestAccess");
};

// Register the plugin
var okEventManager = new OKEventManager();
module.exports = okEventManager;