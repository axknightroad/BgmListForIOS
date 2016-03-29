//
//  BGMSeason.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGMBangumi.h"

@interface BGMSeason : NSObject

@property (nonatomic, strong) NSMutableArray *bgmOfWeekDay;
@property (nonatomic, copy) void (^reloadBlock)(void);

@property (nonatomic, copy) NSString *timeTitle;

- (instancetype)initWithURL:(NSString *)url andBlock:(void(^)(void))block;

@end
