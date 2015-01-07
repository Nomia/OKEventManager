//
//  Created by Vincent Row on 15-1-7.
//  Copyright (c) 2015年 EV2. All rights reserved.
//

#import "CDVOKEventManager.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>

@implementation OKEventManager

//create event
- (void)createEventWithCal:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;

    //calendar id
    NSString *calendarIdentifier = [command.arguments objectAtIndex:0];
    
    //properties of event e.g startDate, endDate, title, location
    NSString *propertiesJSON = [command.arguments objectAtIndex:1];

    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKCalendar *calendar = nil;

    //get calendar for this specified id
    if (calendarIdentifier) {
        calendar = [eventStore calendarWithIdentifier:calendarIdentifier];
    }

    if(!calendar){
        NSLog(@"calendar for id %@ doesn't exist",calendarIdentifier);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"nonexists"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        // assign basic information to the event; location is optional
        event.calendar = calendar;
        // event.location = location;
        // event.title = title;

        // set the start date to the current date/time and the event duration to two hours
        NSDate *startDate = eventDate;
        event.startDate = startDate;

        event.endDate = [startDate dateByAddingTimeInterval:3600 * 2];
        
        NSError *error = nil;
        // save event to the callendar
        BOOL result = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
        if (result) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            // NSLog(@"Error saving event: %@", error);
            // unable to save event to the calendar
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

//delete event
- (void)deleteEventWithId:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;

    //event id
    NSString *eventIdentifier = [command.arguments objectAtIndex:0];

    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:eventIdentifier];

    NSError *error;
    if(![eventStore removeEvent:event span: error:&error]){
        //failed to delete event
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

//update certain event
- (void)updateEventWithId:(CDVInvokedUrlCommand*)command{
    //event id
    NSString *eventIdentifier = [command.arguments objectAtIndex:0];

    //properties of event e.g startDate, endDate, title, location
    NSString *propertiesJSON = [command.arguments objectAtIndex:1];

    if(eventIdentifier){
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event = [eventStore eventWithIdentifier:eventIdentifier];

        if(event){
            NSError *error = nil;

            //update properties


            if(![eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err]){
                NSLog(@"update event failed");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }else{
                NSLog(@"update event successfully");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

//request permission to access ical
- (void)requestAccess:(CDVInvokedUrlCommand*)command {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if(granted){
            NSLog(@"User has granted permission!");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }else{
            NSLog(@"User has not granted permission!");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }
     }];
}

//create calendar
- (void)createCalendar:(CDVInvokedUrlCommand*)command {
    NSString *title = [command.arguments objectAtIndex:0];
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKCalendar *calendar = nil;
    
    calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
    
    //assign a title to the calendar
    [calendar setTitle:title];

    //assign a color to the calendar #00CCCC
    CGColorRef *primary = [UIColor colorWithRed:0.0 green:0.768627 blue:0.768627 alpha:1] CGColor];
    [calendar setCGColor: primary];
    
    //source
    for(EKSource *s in eventStore.sources){
        if(s.sourceType == EKSourceTypeLocal){
            calendar.source = s;
            break;
        }
    }
    
    NSString *calendarIdentifier = [calendar calendarIdentifier];
    NSError *error = nil;
    BOOL saved = [eventStore saveCalendar:calendar commit:YES error:&error];
    
    if(saved){
        //create calendar successfully, notify client
        NSLog(@"calendar created with id %@",calendarIdentifier);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:calendarIdentifier];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        //failed to create calendar
        NSLog(@"create calendar failed");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR [error localizedDescription]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
