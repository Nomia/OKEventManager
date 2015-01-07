var cordova = require('cordova');

OKEventManager = function(){}

OKEventManager.prototype.createCalendar = function(title,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "createCalendar", [title]);
};

OKEventManager.prototype.createEventWithCal = function(calId,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "createEventWithCal", [calId]);
};

OKEventManager.prototype.updateEventWithId = function(eventId,onsuccess,onerror){
	cordova.exec(onsuccess, onerror, "OKEventManager", "updateEventWithId", [eventId]);
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