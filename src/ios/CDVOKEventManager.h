//
//  Created by Vincent Row on 15-1-7.
//  Copyright (c) 2015年 EV2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <Cordova/CDVPlugin.h>

@interface CDVOKEventManager : CDVPlugin {}

@property (nonatomic, strong) EKEventStore *eventStore;

- (void)createEventWithCal:(CDVInvokedUrlCommand*)command;
- (void)deleteEventWithId:(CDVInvokedUrlCommand*)command;
- (void)updateEventWithId:(CDVInvokedUrlCommand*)command;
- (void)requestAccess:(CDVInvokedUrlCommand*)command;
- (void)createCalendar:(CDVInvokedUrlCommand*)command;

@end
