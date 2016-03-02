//
//  BGMItem.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMBangumi.h"

@implementation BGMBangumi

- (instancetype)initWithDic:(NSDictionary *)dic andBid:(NSString *)bid{
    self = [super init];
    if (self) {
        _bid = bid;
        _titleCN = dic[@"titleCN"];
        _titleJP = dic[@"titleJP"];
        _titleEN = dic[@"titleEN"];
        _officalSite = dic[@"officalSite"];
        _weekDayJP = [(NSNumber *)dic[@"weekDayJP"] integerValue];
        _weekDayCN = [(NSNumber *)dic[@"weekDayCN"] integerValue];
        _timeJP = dic[@"timeJP"];
        _timeCN = dic[@"timeCN"];
        _onAirSite = dic[@"onAirSite"];
        _newBgm = [dic[@"newBgm"]isEqualToNumber:@1]? YES: NO;
        _bgmId = [(NSNumber *)dic[@"bgmId"] integerValue];
        _showDate = dic[@"showDate"];
    }
    
    return self;
}

@end
