//
//  BGMInfoViewController.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGMBangumi;

@interface BGMInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIButton *bgmButton;
@property (weak, nonatomic) IBOutlet UIButton *officialButton;

@property (weak, nonatomic) BGMBangumi *bangumi;
@property (nonatomic) int index;
@property (nonatomic, copy) void (^setViewHeight)(CGFloat h);

- (void)setHeightAuto;


@end
