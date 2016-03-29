//
//  BGMTableViewController.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMTableViewController.h"
#import "BGMBangumi.h"
#import "BGMBangumiStore.h"
#import "BGMDetailViewController.h"
#import "BGMDataStore.h"
#import "BGMTableViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "BGMImageStore.h"
#import "BGMHistoryViewController.h"
#import "BGMNavigationController.h"

#import "RESideMenu.h"

#define kMaxX 100
#define kYVelocityThreshold 100
#define kXVelocityThreshold 100


@interface BGMTableViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) CGPoint translation;
@property (nonatomic) BOOL startMove;


@end

@implementation BGMTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style andWeekday:(NSInteger)weekday {
    self = [super initWithStyle:style];

    
    if (self) {
        [BGMDataStore sharedStore].nowTvc = self;
        _weekday = weekday;
        
        _translation = CGPointMake(0.0, 0.0);
        _startMove = NO;
        _leftMendOpened = NO;
        
        NSString *weekdayString = [NSString stringWithFormat:@"%@",[BGMDataStore sharedStore].weekdayStrings[weekday]];
        UIBarButtonItem *changeDayButton =
            [[UIBarButtonItem alloc] initWithTitle:weekdayString                                           style:UIBarButtonItemStyleDone
                                            target:self
                                            action:@selector(leftMenu)];
        self.navigationItem.leftBarButtonItem = changeDayButton;
        
        UIBarButtonItem *historyButton =
        [[UIBarButtonItem alloc] initWithTitle:@"历史番组"                                           style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(openHistoryMenu)];

        self.navigationItem.rightBarButtonItem = historyButton;
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.tableView removeFromSuperview];
    _timeTitle = [NSString stringWithFormat:@"%@年%@月番组",
                  [BGMBangumiStore sharedStore].timeDic[@"year"],
                  [BGMBangumiStore sharedStore].timeDic[@"month"]];
    self.tableView.rowHeight = 150;
    UINib *nib = [UINib nibWithNibName:@"BGMTableViewCell" bundle:nil];
    
    [self.tableView registerNib:nib forCellReuseIdentifier:@"BGMTableViewCell"];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *backitem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    
    self.navigationItem.backBarButtonItem = backitem;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [[BGMBangumiStore sharedStore].nowSeason.bgmOfWeekDay[self.weekday] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMTableViewCell"
                                                             forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"BGMTableViewCell";
    cell.bgmImageView.image = nil;
    BGMBangumi *bgm = [BGMBangumiStore sharedStore].nowSeason.bgmOfWeekDay[self.weekday][indexPath.row];
    cell.bgmName.text = bgm.titleCN;
    NSInteger bgmId = bgm.bgmId;
    cell.bgmImageView.tag = bgmId;
    NSString *urlString = [NSString stringWithFormat:@"http://api.bgm.tv/subject/%ld?responseGroup=large", bgmId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    UIImage *bgmImage = [[BGMImageStore sharedStore] imageForKey:bgm.bid];
    if (!bgmImage) {
        bgm.isLoadingImage = YES;
        cell.bgmImageView.image = nil;
        [manager GET:urlString
          parameters:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 if ([responseObject isKindOfClass:[NSDictionary class]]) {
                     NSLog(@"get json success");
                     bgm.bgmDic = responseObject;
                     NSString *imageUrlString = bgm.bgmDic[@"images"][@"large"];
                     NSLog(@"%@",imageUrlString);
                     NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
                     [self downloadImageWithURL:imageUrl ForCell:cell andBgm:bgm];
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error: %@", error);
             }];
    } else {
        UIImage *clipedImage = [self clipImage:bgmImage WithRect:cell.contentView.frame];
        NSLog(@"cell Height: %f",cell.frame.origin.y);
        NSLog(@"content Height: %f", cell.frame.origin.y);
        NSLog(@"bgmImageView Height: %f", cell.bgmImageView.frame.origin.y);
        cell.bgmImageView.image = clipedImage;
        [cell.imageView setNeedsDisplay];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BGMDetailViewController *dvc = [[BGMDetailViewController alloc] init];
    NSArray *bgmList = [BGMBangumiStore sharedStore].nowSeason.bgmOfWeekDay[self.weekday];
    BGMBangumi *selectBgm = bgmList[indexPath.row];
    
    dvc.bangumi = selectBgm;
    if(self.leftMendOpened) {
        [self leftMenu];
    }
    [self.navigationController pushViewController:dvc animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _timeTitle = [BGMBangumiStore sharedStore].nowSeason.timeTitle;
    self.navigationItem.title = self.timeTitle;
    [self.tableView reloadData];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:41.0/255 green:187.0/255 blue:156.0/255 alpha:1];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    
}

- (void)leftMenu {
    if (!self.leftMendOpened) {
        //self.moveFrameTo(100);
        [self.sideMenuViewController presentLeftMenuViewController];
        
        //self.leftMendOpened = YES;
    }
    /*
    else {
        //self.moveFrameTo(0);
        [self.sideMenuViewController hideMenuViewController];
        self.leftMendOpened = NO;
    }
     */

}

- (void)pan:(UIGestureRecognizer *)gr {
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)gr;
    CGPoint p = [pgr locationInView:self.view];
    CGPoint t = [pgr translationInView:self.view];
    
    if (gr.state == UIGestureRecognizerStateBegan && (self.leftMendOpened || p.x <= 100)) {
        self.startMove = YES;
    }
    
    
    NSLog(@"pan");
    NSLog(@"p: %lf, %lf", p.x, p.y);
    NSLog(@"t: %lf, %lf", t.x, t.y);
    CGPoint velocity = [pgr velocityInView:self.view];
    NSLog(@"velocity is %lf", velocity.y);
    
    if (self.startMove) {
        if (t.x >= 0 && t.x <= 100) {
            self.moveFrameTo(t.x);
        } else if (t.x >= - 100 && t.x < 0) {
            self.moveFrameTo(100 + t.x);
        }
    }
    
    if (gr.state == UIGestureRecognizerStateEnded) {
        NSLog(@"end");
        if (self.startMove) {
            self.startMove = NO;
            if (t.x < 50) {
                self.moveFrameTo(0);
                self.leftMendOpened = NO;
            } else {
                self.moveFrameTo(100);
                self.leftMendOpened = YES;
            }
        }
    }
    
    //[pgr setTranslation:CGPointZero inView:self.view];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    velocity.y = velocity.y > 0? velocity.y: -velocity.y;
    velocity.x = velocity.x > 0? velocity.x: -velocity.x;
    return velocity.y <= kYVelocityThreshold && velocity.x >= kXVelocityThreshold;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)downloadImageWithURL:(NSURL *)imageUrl ForCell:(BGMTableViewCell *)cell andBgm:(BGMBangumi *)bgm{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    NSLog(@"Start Downlad Image");
    [cell.bgmImageView setImageWithURLRequest:request
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image){
                                          NSLog(@"Download Image Success");
                                          
                                          [[BGMImageStore sharedStore] setImage:image
                                                                         forKey:bgm.bid];

                                          UIImage *clipedImage = [self clipImage:image WithRect:cell.contentView.frame];
                                          cell.bgmImageView.image = clipedImage;
                                          [cell.bgmImageView setNeedsDisplay];
                                          bgm.isLoadingImage = NO;
                                          
                                      }
                                      failure:nil];
    
}

- (UIImage *)clipImage:(UIImage *)image WithRect:(CGRect)rect{
    CGSize originImageSize = image.size;
    CGRect newRect = rect;
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

- (void)openHistoryMenu {
    BGMHistoryViewController *hvc = [[BGMHistoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    BGMNavigationController *bnc = [[BGMNavigationController alloc] initWithRootViewController:hvc];
    
    [self presentViewController:bnc
                       animated:YES
                     completion:nil];
}


@end
