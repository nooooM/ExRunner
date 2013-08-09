//
//  RORUserServices.m
//  RevolUtioN
//
//  Created by leon on 13-7-14.
//  Copyright (c) 2013年 Beyond. All rights reserved.
//

#import "RORUserServices.h"

@implementation RORUserServices

+ (User *)fetchUserById:(NSNumber *) userId{
    
    NSString *table=@"User";
    NSString *query = @"userId = %@";
    NSArray *params = [NSArray arrayWithObjects:userId, nil];
    NSArray *fetchObject = [RORUtils fetchFromDelegate:table withParams:params withPredicate:query];
    if (fetchObject == nil || [fetchObject count] == 0) {
        return nil;
    }
    return  (User *) [fetchObject objectAtIndex:0];
}

+(User_Attributes *)fetchUserAttrsByUserId:(NSNumber *) userId{
    NSString *table=@"User_Attributes";
    NSString *query = @"userId = %@";
    NSArray *params = [NSArray arrayWithObjects:userId, nil];
    NSArray *fetchObject = [RORUtils fetchFromDelegate:table withParams:params withPredicate:query];
    if (fetchObject == nil || [fetchObject count] == 0) {
        return nil;
    }
    return   (User_Attributes *) [fetchObject objectAtIndex:0];
}

+(Friend *)fetchUserFriend:(NSNumber *) userId withFriendId:(NSNumber *) friendId{
    NSString *table=@"Friend";
    NSString *query = @"userId = %@ and friendId = %@";
    NSArray *params = [NSArray arrayWithObjects:userId,friendId, nil];
    NSArray *fetchObject = [RORUtils fetchFromDelegate:table withParams:params withPredicate:query];
    if (fetchObject == nil || [fetchObject count] == 0) {
        return nil;
    }
    return   (Friend *) [fetchObject objectAtIndex:0];
}

+(void)syncUserInfo:(NSNumber *)userId withUserDic:(NSDictionary *) userInfoDic{
    NSError *error;
    RORAppDelegate *delegate = (RORAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    User *user = [self fetchUserById:userId];
    User_Attributes *userAttr = [self fetchUserAttrsByUserId:userId];
    
    if(user == nil)
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user initWithDictionary:userInfoDic];
    
    if(userAttr == nil)
        userAttr = [NSEntityDescription insertNewObjectForEntityForName:@"User_Attributes" inManagedObjectContext:context];
    [userAttr initWithDictionary:userInfoDic];
    
    if (![context save:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
}


+(void)syncUserInfo:(NSNumber *)userId{
    NSError *error;
    RORAppDelegate *delegate = (RORAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    RORHttpResponse *httpResponse =[RORUserClientHandler getUserInfoById:userId];
    
    if ([httpResponse responseStatus] == 200){
        NSDictionary *userInfoDic = [NSJSONSerialization JSONObjectWithData:[httpResponse responseData] options:NSJSONReadingMutableLeaves error:&error];
        
        User *user = [self fetchUserById:userId];
        User_Attributes *userAttr = [self fetchUserAttrsByUserId:userId];
        
        if(user == nil)
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        [user initWithDictionary:userInfoDic];
        
        if(userAttr == nil)
            userAttr = [NSEntityDescription insertNewObjectForEntityForName:@"User_Attributes" inManagedObjectContext:context];
        [userAttr initWithDictionary:userInfoDic];
        
        if (![context save:&error]) {
            NSLog(@"%@",[error localizedDescription]);
        }
        [RORUtils saveLastUpdateTime:@"systemTime"];
    }else {
        NSLog(@"sync with host error: can't get user's info. Status Code: %d", [httpResponse responseStatus]);
    }
}

+ (void)syncFriends:(NSNumber *) userId {
    NSError *error = nil;
    RORAppDelegate *delegate = (RORAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSString *lastUpdateTime = [RORUtils getLastUpdateTime:@"FriendUpdateTime"];
    RORHttpResponse *httpResponse =[RORUserClientHandler getUserFriends:userId withLastUpdateTime:lastUpdateTime];
    
    if ([httpResponse responseStatus] == 200){
        NSArray *friendList = [NSJSONSerialization JSONObjectWithData:[httpResponse responseData] options:NSJSONReadingMutableLeaves error:&error];
        for (NSDictionary *friendDict in friendList){
            NSNumber *userIdNum = [friendDict valueForKey:@"userId"];
            NSNumber *friendIdNum = [friendDict valueForKey:@"friendId"];
            Friend *friendEntity = [self fetchUserFriend:userIdNum withFriendId:friendIdNum];
            if(friendEntity == nil)
                friendEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
            [friendEntity initWithDictionary:friendDict];
        }
        
        if (![context save:&error]) {
            NSLog(@"%@",[error localizedDescription]);
        }
        
        [RORUtils saveLastUpdateTime:@"FriendUpdateTime"];
    } else {
        NSLog(@"sync with host error: can't get user's friends list. Status Code: %d", [httpResponse responseStatus]);
    }
}

+(void)clearUserData{
    NSArray *tables = [NSArray arrayWithObjects:@"User",@"User_Attributes",@"Friend",@"User_Last_Location",@"User_Running_History",@"User_Running", nil];
    [RORUtils clearTableData:tables];
}

@end