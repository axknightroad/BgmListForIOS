//
//  BGMBangumi.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGMBangumi : NSObject

@property (nonatomic, copy) NSString *bid;
@property (nonatomic, copy) NSString *titleCN;
@property (nonatomic, copy) NSString *titleJP;
@property (nonatomic, copy) NSString *titleEN;
@property (nonatomic, copy) NSString *officalSite;
@property (nonatomic) NSInteger weekDayJP;
@property (nonatomic) NSInteger weekDayCN;
@property (nonatomic, copy) NSString *timeJP;
@property (nonatomic, copy) NSString *timeCN;
@property (nonatomic, copy) NSArray *onAirSite;
@property (nonatomic) BOOL newBgm;
@property (nonatomic) NSInteger bgmId;
@property (nonatomic, copy) NSString *showDate;


- (instancetype)initWithDic:(NSDictionary *)dic andBid:(NSString *)bid;

@end
