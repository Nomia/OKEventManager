//
//  Created by Vincent Row on 15-1-7.
//  Copyright (c) 2015年 EV2. All rights reserved.
//

#import "CDVOKEventManager.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>

@implementation CDVOKEventManager

@synthesize eventStore;

//create event
- (void)createEventWithCal:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;
    
    //properties of event e.g startDate, endDate, title, location
//    NSString *propertiesJSON = [command.arguments objectAtIndex:1];
    
    if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
    
    //calendar id
    NSString *calendarIdentifier = [command.arguments objectAtIndex:0];
    
    //configuration of event
    NSMutableDictionary *options = [command.arguments objectAtIndex:1];
    
    
    EKCalendar *calendar = nil;

    //get calendar for this specified id
    if (calendarIdentifier) {
        calendar = [self.eventStore calendarWithIdentifier:calendarIdentifier];
    }

    if(!calendar){
        NSLog(@"calendar for id %@ doesn't exist",calendarIdentifier);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"nonexists"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        // assign basic information to the event; location is optional
//        event.calendar = calendar;
        
        if(![calendar allowsContentModifications]){
            NSLog(@"The selected calendar does not allow modifications");
        }
        
        [event setCalendar:calendar];
        
        NSString *title = [options objectForKey:@"title"];
        if(title) event.title = title;
        else  event.title = @"";
        
        NSString *notes = [options objectForKey:@"notes"];
        if(notes) event.notes = notes;
        
        NSInteger startInt = [[options objectForKey:@"startInt"] integerValue];

        // set the start date to the current date/time and the event duration to two hours
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startInt];
        event.startDate = startDate;
        event.endDate = [startDate dateByAddingTimeInterval:3600 * 2];
        
        BOOL allDay = [[options objectForKey:@"allDay"] boolValue];
        
        if(allDay){
            event.allDay = YES;
        }
        
        NSInteger alarmInt = [[options objectForKey:@"alarmInt"] integerValue];
        
        //give it a default alarm value
        if(!alarmInt) alarmInt = 60;
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:alarmInt];
        [event addAlarm:alarm];
        
        NSError *error = nil;
        // save event to the callendar
        BOOL result = [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
        if (result) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            NSLog(@"Error saving event: %@", error);
            // unable to save event to the calendar
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

//delete event
- (void)deleteEventWithId:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;

    //event id
    NSString *eventIdentifier = [command.arguments objectAtIndex:0];

    if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [self.eventStore eventWithIdentifier:eventIdentifier];

    NSError *error;
    if(![self.eventStore removeEvent:event span:EKSpanThisEvent error:&error]){
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
    CDVPluginResult *pluginResult = nil;
    //event id
    NSString *eventIdentifier = [command.arguments objectAtIndex:0];
    
    //configuration of event
    NSMutableDictionary *options = [command.arguments objectAtIndex:1];

    //properties of event e.g startDate, endDate, title, location
//    NSString *propertiesJSON = [command.arguments objectAtIndex:1];

    if(eventIdentifier){
        if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
        EKEvent *event = [self.eventStore eventWithIdentifier:eventIdentifier];

        if(event){
            NSError *error = nil;

            //update properties
            NSString *title = [options objectForKey:@"title"];
            if(title) event.title = title;
            else  event.title = @"";
            
            NSString *notes = [options objectForKey:@"notes"];
            if(notes) event.notes = notes;
            
            NSInteger startInt = [[options objectForKey:@"startInt"] integerValue];
            NSInteger endInt = [[options objectForKey:@"endInt"] integerValue];
            
            if(startInt){
                // set the start date to the current date/time and the event duration to two hours
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startInt];
                event.startDate = startDate;
            }
            
            if(endInt){
                // set the start date to the current date/time and the event duration to two hours
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endInt];
                event.endDate = endDate;
            }
            
            BOOL allDay = [[options objectForKey:@"allDay"] boolValue];
            
            if(allDay){
                event.allDay = YES;
            }
            
            NSInteger alarmInt = [[options objectForKey:@"alarmInt"] integerValue];
            
            //give it a default alarm value
            if(!alarmInt) alarmInt = 60;
            EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:alarmInt];
            [event addAlarm:alarm];


            if(![self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error]){
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
    
    if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
        CDVPluginResult *pluginResult = nil;
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

- (NSString *)createCalendarWithTitle:(NSString *)title{
    if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
    EKCalendar *calendar = nil;
    
        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
        
        //assign a title to the calendar
        [calendar setTitle:title];
        
        //assign a color to the calendar #00CCCC
        CGColorRef primary = [[UIColor colorWithRed:0.0 green:0.768627 blue:0.768627 alpha:1] CGColor];
        [calendar setCGColor: primary];
        
        EKSource *localSource = nil;
        
        //source
        for (EKSource *source in eventStore.sources){
            if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]){
                localSource = source;
                break;
            }
        }
        if( localSource == nil){
            for(EKSource *s in eventStore.sources){
                if(s.sourceType == EKSourceTypeLocal){
                    localSource = s;
                    break;
                }
            }
        }
        
        calendar.source = localSource;
        
        NSString *calendarIdentifier = [calendar calendarIdentifier];
        NSError *error = nil;
        BOOL saved = [self.eventStore saveCalendar:calendar commit:YES error:&error];
        
        if(saved){
            return calendarIdentifier;
        }else{
            return @"error happend, the message";
        }
    
    return @"nothing";
}

- (EKCalendar *)getCalendarWithTitle:(NSString *)title{
    if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
    EKCalendar *calendar = nil;
    
    //firstly, loop through all calendars to find a calendar with the same title
    NSArray *existCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@",title];
    NSArray *filtered = [existCalendars filteredArrayUsingPredicate:predicate];
    
    if([filtered count]) {
        calendar = [filtered firstObject];
    }
    
    return calendar;
}

//create calendar
- (void)createCalendar:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;
    NSString *title = [command.arguments objectAtIndex:0];
    
    EKCalendar *calendar = nil;
    
    calendar = [self getCalendarWithTitle:title];
    
    if(calendar){
        NSLog(@"calendar exist with id %@",[calendar calendarIdentifier]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[calendar calendarIdentifier]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        if(!self.eventStore) self.eventStore = [[EKEventStore alloc] init];
        
        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
        
        //assign a title to the calendar
        [calendar setTitle:title];
        
        //assign a color to the calendar #00CCCC
        CGColorRef primary = [[UIColor colorWithRed:0.0 green:0.768627 blue:0.768627 alpha:1] CGColor];
        [calendar setCGColor: primary];
        
        EKSource *localSource = nil;
        
        //source
        for (EKSource *source in eventStore.sources){
            if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]){
                localSource = source;
                break;
            }
        }
        if( localSource == nil){
            for(EKSource *s in eventStore.sources){
                if(s.sourceType == EKSourceTypeLocal){
                    localSource = s;
                    break;
                }
            }
        }
        
        
        calendar.source = localSource;
        
        NSString *calendarIdentifier = [calendar calendarIdentifier];
        NSError *error = nil;
        BOOL saved = [self.eventStore saveCalendar:calendar commit:YES error:&error];
        
        if(saved){
            //create calendar successfully, notify client
            NSLog(@"calendar created with id %@",calendarIdentifier);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:calendarIdentifier];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            //failed to create calendar
            NSLog(@"create calendar failed %@",error);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

@end
