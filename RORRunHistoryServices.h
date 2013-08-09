//
//  RORRunHistoryServices.h
//  RevolUtioN
//
//  Created by leon on 13-7-22.
//  Copyright (c) 2013年 Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RORAppDelegate.h"
#import "RORHttpResponse.h"
#import "RORMissionClientHandler.h"
#import "User_Running.h"
#import "User_Running_History.h"
#import "RORRunHistoryClientHandler.h"

@interface RORRunHistoryServices : NSObject

+ (void)uploadRunningHistories;

+ (void)syncRunningHistories;

@end