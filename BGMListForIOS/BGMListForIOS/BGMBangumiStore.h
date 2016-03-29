//
//  BGMBangumiStore.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGMSeason.h"

@class BGMTableViewController;

@interface BGMBangumiStore : NSObject

@property (nonatomic, readonly) NSDictionary *allSeason;
@property (nonatomic, strong) BGMSeason *nowSeason;
@property (nonatomic, copy) void (^reloadBlock)(void);
@property (nonatomic, copy) NSDictionary *timeDic;
@property (nonatomic, weak) BGMTableViewController *tvc;
@property (nonatomic, readonly) NSArray *historySeasons;


+ (instancetype)sharedStore;
- (BOOL)setSeasonWithYear:(NSString *)year andMonth:(NSString *)month;


@end
