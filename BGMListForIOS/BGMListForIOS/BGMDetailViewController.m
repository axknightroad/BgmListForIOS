//
//  BGMDetailViewController.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/27.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMDetailViewController.h"
#import "BGMImageStore.h"
#import "BGMDataStore.h"

@interface BGMDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bgmImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleCN;
@property (weak, nonatomic) IBOutlet UILabel *titleJP;
@property (weak, nonatomic) IBOutlet UILabel *timeJP;
@property (weak, nonatomic) IBOutlet UILabel *timeCN;
@property (weak, nonatomic) IBOutlet UISegmentedControl *onAirSites;

@end

@implementation BGMDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.titleCN.text = self.bangumi.titleCN;
    self.titleJP.text = self.bangumi.titleJP;
    
    NSString *timeJP = [self getTimeFromWeekday:self.bangumi.weekDayJP
                                        andTime:self.bangumi.timeJP];
    self.timeJP.text = [NSString stringWithFormat:@"日本放送：%@", timeJP];
    
    NSString *timeCN = [self getTimeFromWeekday:self.bangumi.weekDayCN
                                        andTime:self.bangumi.timeCN];
    self.timeCN.text = [NSString stringWithFormat:@"大陆放送：%@", timeCN];
    
    [self.onAirSites removeAllSegments];
    for (int i = 0; i < self.bangumi.onAirSite.count; i++) {
        NSString *urlString = self.bangumi.onAirSite[i];
        NSString *siteName = [self getSiteNameFromURLString:urlString];
        [self.onAirSites insertSegmentWithTitle:siteName
                                        atIndex:i
                                       animated:NO];
    }
    [self.onAirSites addTarget:self
                        action:@selector(siteSelected:)
              forControlEvents:UIControlEventValueChanged];
    self.onAirSites.momentary = NO;
    
    self.onAirSites.tintColor = [UIColor clearColor];
    NSInteger fontSize = MIN(20 - self.bangumi.onAirSite.count, 17);
    
    NSDictionary* textAttributes = @{
                                     NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                     NSForegroundColorAttributeName: [UIColor blackColor]
                                     };
    [self.onAirSites setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
    [self.onAirSites setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    NSString *bid = self.bangumi.bid;
    UIImage *imageToDisplay = [[BGMImageStore sharedStore] imageForKey:bid];
    
    if (imageToDisplay) {
        self.bgmImageView.image = imageToDisplay;
    } else {
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage) object:nil];
        [operationQueue addOperation:op];
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

- (void)downloadImage {
    NSURLSessionConfiguration *config =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:nil];
    NSInteger bgmId =  self.bangumi.bgmId;
    NSString *urlString = [NSString stringWithFormat:@"http://api.bgm.tv/subject/%ld?responseGroup=large", bgmId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req
                                                completionHandler:
                                      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                          //NSString *json =[[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
                                          //NSLog(@"%@", json);
                                          NSDictionary *bgmDictionary =
                                          [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:nil];
                                          //NSLog(@"%@", bgmDictionary);
                                          NSString *imageUrlString = bgmDictionary[@"images"][@"large"];
                                          NSLog(@"%@",imageUrlString);
                                          NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
                                          NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageUrl];
                                          UIImage *image =
                                            [[UIImage alloc] initWithData:imageData];
                                          UIImage *bgmImage = [self clipImage:image];
                                          
                                          [[BGMImageStore sharedStore] setImage:bgmImage forKey:self.bangumi.bid];
                                          self.bgmImageView.image = bgmImage;
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.bgmImageView setNeedsDisplay];
                                          });
                                      }];
    [dataTask resume];
    

}

- (UIImage *)clipImage:(UIImage *)image {
    CGSize originImageSize = image.size;
    CGRect newRect = self.bgmImageView.frame;
    newRect.origin = CGPointMake(0, 0);
    float ratio = MAX(newRect.size.height / originImageSize.height, newRect.size.width / originImageSize.width);
    
    UIGraphicsBeginImageContext(newRect.size);
    
    CGRect projectRect;
    projectRect.size.width = ratio * originImageSize.width;
    projectRect.size.height = ratio * originImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (NSString *)getTimeFromWeekday:(NSInteger)weekday andTime:(NSString *)time {

    NSMutableString *timeFormat = [[NSMutableString alloc] initWithString:time];
    if ([time isEqualToString:@""]) {
        [timeFormat stringByAppendingString:@"（待定）"];
    } else {
        [timeFormat insertString:@":" atIndex:2];
    }
    
    return [NSString stringWithFormat:@"%@ %@",
                [BGMDataStore sharedStore].weekdayStrings[weekday], timeFormat];
    
}

- (NSString *)getSiteNameFromURLString:(NSString *)urlString {
    NSDictionary *siteDic = @{
                              @"acfun": @"A站",
                              @"bilibili": @"B站",
                              @"tucao": @"C站",
                              @"sohu": @"搜狐",
                              @"youku": @"优酷",
                              @"qq": @"腾讯",
                              @"iqiyi": @"爱奇艺",
                              @"letv": @"乐视",
                              @"pptv": @"PPTV",
                              @"tudou": @"土豆",
                              @"movie": @"迅雷"
                              };
    for (NSString *key in siteDic) {
        if ([urlString containsString:key]) {
            return siteDic[key];
        }
    }
    
    return @"其他";
}

- (void)siteSelected:(UISegmentedControl *)seg{
    NSUInteger index = seg.selectedSegmentIndex;
    NSString *urlString = self.bangumi.onAirSite[index];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

@end
