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
        _siteNameArray = @[@"acfun", @"bilibili", @"tucao", @"sohu", @"youku",
                           @"qq", @"iqiyi", @"letv", @"pptv", @"tudou", @"movie"];
        
        _siteChineseNameDic = @{
                         @"acfun": @"A站",
                         @"bilibili": @"B站",
                         @"tucao": @"C站",
                         @"sohu": @"搜狐",
                         @"youku": @"优酷",
                         @"qq": @"腾讯",
                         @"iqiyi": @"爱奇艺",
                         @"letv": @"乐视",
                         @"pptv": @"PPTV",
                         @"tudou": @"土豆",
                         @"movie": @"迅雷",
                         @"other": @"其他"
                         };
        
    }
    
    return self;
}


@end
