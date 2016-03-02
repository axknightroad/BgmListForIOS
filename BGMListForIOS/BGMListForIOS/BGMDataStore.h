//
//  BGMDataStore.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/1.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BGMTableViewController;

@interface BGMDataStore : NSObject

@property (nonatomic, weak) BGMTableViewController *nowTvc;
@property (nonatomic, copy) NSArray *weekdayStrings;

+ (instancetype)sharedStore;

@end
