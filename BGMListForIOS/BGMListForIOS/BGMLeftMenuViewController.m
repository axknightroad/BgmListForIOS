//
//  BGMLeftMenuViewController.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/26.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMLeftMenuViewController.h"
#import "BGMBangumiStore.h"

@interface BGMLeftMenuViewController ()

@end

@implementation BGMLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *buttons = @[self.sundayButton, self.mondayButton, self.tuesdayButton,
                         self.wednesdayButton, self.thursdayButton, self.fridayButton,
                         self.saturdayButton, self.everydayButton];
    NSInteger weekday = [[BGMBangumiStore sharedStore].timeDic[@"weekday"] integerValue];
    
    self.selectButton = buttons[weekday];
    self.selectButton.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changWeekday:(id)sender {
    UIButton *selectButton = (UIButton *)sender;
    NSInteger weekday =  selectButton.tag;
    self.selectButton.selected = NO;
    selectButton.selected = YES;
    self.selectButton = selectButton;
    self.changWeekdayBlock(weekday);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
