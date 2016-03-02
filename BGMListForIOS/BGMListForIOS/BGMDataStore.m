//
//  BGMDataStore.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/1.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMDataStore.h"

@implementation BGMDataStore

+ (instancetype)sharedStore {
    static BGMDataStore *sharedStore = nil;
    /*
     if (!sharedStore) {
     sharedStore = [[self alloc] initPrivate];
     }
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [BGMImageStore sharedStore]" userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    
    if (self) {
        _weekdayStrings = @[@"周日", @"周一", @"周二", @"周三",
                            @"周四", @"周五", @"周六", @"所有"];
        
    }
    
    return self;
}


@end
