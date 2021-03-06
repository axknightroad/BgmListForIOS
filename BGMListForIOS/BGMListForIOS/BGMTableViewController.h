//
//  BGMTableViewController.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+RESideMenu.h"

@interface BGMTableViewController : UITableViewController

@property (nonatomic) NSInteger weekday;
@property (nonatomic, copy) void (^moveFrameTo)(CGFloat x);
@property (nonatomic) BOOL leftMendOpened;

@property (nonatomic, copy) NSString *timeTitle;

- (instancetype)initWithStyle:(UITableViewStyle)style andWeekday:(NSInteger)weekday;

@end
