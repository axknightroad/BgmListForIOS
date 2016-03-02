//
//  BGMLeftMenuViewController.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/26.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGMLeftMenuViewController : UIViewController

@property (nonatomic, copy) void (^changWeekdayBlock)(NSInteger);

@property (weak, nonatomic) IBOutlet UIButton *mondayButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet UIButton *everydayButton;
@property (weak, nonatomic) UIButton *selectButton;

@end
