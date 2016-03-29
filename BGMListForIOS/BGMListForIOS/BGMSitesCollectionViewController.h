//
//  BGMSitesCollectionViewController.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGMBangumi;

@interface BGMSitesCollectionViewController : UICollectionViewController

@property (weak, nonatomic) BGMBangumi *bangumi;
@property (nonatomic) int index;

@property (nonatomic, copy) void (^setViewHeight)(CGFloat h);

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout andBgm:(BGMBangumi*)bgm;
- (void)setHeightAuto;

@end
