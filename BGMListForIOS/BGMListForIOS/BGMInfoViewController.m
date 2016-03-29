//
//  BGMInfoViewController.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMInfoViewController.h"
#import "BGMBangumi.h"
#import "AFNetworking.h"

@interface BGMInfoViewController ()

@property (nonatomic) CGFloat height;

@end

@implementation BGMInfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.summaryLabel.numberOfLines = 0;
    _height = 150;
    if (!self.bangumi.bgmDic) {
        [self downloadInfo];
    } else {
        NSString *summary = self.bangumi.bgmDic[@"summary"];
        self.summaryLabel.text = summary;
        CGRect frame = self.summaryLabel.frame;
        CGSize size = [summary boundingRectWithSize:CGSizeMake(frame.size.width - 40, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                            context:nil].size;
        frame.size = size;
        self.summaryLabel.frame = frame;
        _height = size.height + 100;
        [self setHeightAuto];
        NSLog(@"%@", self.bangumi.bgmDic);
        
        // CGSize contentSize = CGSizeMake(self.scrollView.frame.size.width, self.height1);
        // self.scrollView.contentSize = contentSize;
    }
}


- (void)downloadInfo {
    NSInteger bgmId =  self.bangumi.bgmId;
    NSString *urlString = [NSString stringWithFormat:@"http://api.bgm.tv/subject/%ld?responseGroup=large", bgmId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString
      parameters:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSLog(@"get json success");
                 self.bangumi.bgmDic = responseObject;
                 NSString *summary = self.bangumi.bgmDic[@"summary"];
                 self.summaryLabel.text = summary;
                 CGRect frame = self.summaryLabel.frame;
                 CGSize size = [summary boundingRectWithSize:CGSizeMake(frame.size.width - 40, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
                 frame.size = size;
                 _height = size.height + 100;
                 [self setHeightAuto];
                 self.summaryLabel.frame = frame;
                 //NSLog(@"%@", self.bangumi.bgmDic);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setHeightAuto {
    if(_height) {
        self.setViewHeight(_height);
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)goToBgmPage:(id)sender {
    NSString *url = [NSString stringWithFormat:@"http://bangumi.tv/subject/%ld", self.bangumi.bgmId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
- (IBAction)goToOfficialSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.bangumi.officalSite]];
}

@end
