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
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "QHNavSliderMenu.h"
#import "BGMInfoViewController.h"
#import "BGMSitesCollectionViewController.h"

@class AFHTTPSessionManager;

@interface BGMDetailViewController () <UIScrollViewDelegate,QHNavSliderMenuDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgmImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleCN;
@property (weak, nonatomic) IBOutlet UILabel *titleJP;
@property (weak, nonatomic) IBOutlet UILabel *timeJP;
@property (weak, nonatomic) IBOutlet UILabel *timeCN;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewSubView;
@property (weak, nonatomic) IBOutlet UILabel *timeStart;

@property (weak, nonatomic) IBOutlet UIButton *imageDeleteButton;

@property (strong, nonatomic) UIView *statusBar;

@property (strong, nonatomic) QHNavSliderMenu *navSliderMenu;
@property (strong, nonatomic) NSMutableDictionary  *listVCQueue;
@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (nonatomic, copy) void (^setViewHeight)(CGFloat h);
@property (weak, nonatomic) IBOutlet UILabel *line1;
@property (weak, nonatomic) IBOutlet UILabel *line2;

@property (weak, nonatomic) BGMSitesCollectionViewController *scvc;

@end

@implementation BGMDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *itme = [[UIBarButtonItem alloc] initWithTitle:self.bangumi.titleCN
                                                             style:UIBarButtonItemStyleDone
                                                            target:nil
                                                            action:nil];
    itme.tintColor = [UIColor clearColor];
    self.navigationItem.rightBarButtonItem = itme;
    
    
    self.titleCN.text = self.bangumi.titleCN;
    self.titleJP.text = self.bangumi.titleJP;
    
    NSString *timeJP = [self getTimeFromWeekday:self.bangumi.weekDayJP
                                        andTime:self.bangumi.timeJP];
    self.timeJP.text = [NSString stringWithFormat:@"日本放送：%@", timeJP];
    
    NSString *timeCN = [self getTimeFromWeekday:self.bangumi.weekDayCN
                                        andTime:self.bangumi.timeCN];
    self.timeCN.text = [NSString stringWithFormat:@"大陆放送：%@", timeCN];
    
    self.timeStart.text =[NSString stringWithFormat:@"放送日期：%@",self.bangumi.showDate];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.scrollView.delegate = self;
    self.scrollView.tag = 1;
    
    _statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 800, 64)];
    _statusBar.backgroundColor = [UIColor colorWithRed:41/255 green:187/255 blue:156/255 alpha:0];
    [self.view addSubview:_statusBar];
    
    
    //debug
    self.imageDeleteButton.hidden = YES;
    
    [self initSlideMenuAndContent];
    
    _line2.layer.zPosition = 10;
    self.line1.hidden = YES;
    
}

-(void)viewDidLayoutSubviews {
    CGFloat scHeight = self.contentScrollView.frame.size.height + 300 + self.bgmImageView.height;
    NSLog(@"%lf",self.contentScrollView.frame.size.height);
    CGSize contentSize = CGSizeMake(screenWidth, scHeight);
    self.scrollView.contentSize = contentSize;
    NSLog(@"content height: %f", contentSize.height);
    
 //   NSInteger row = (int)((self.contentScrollView.contentOffset.x+screenWidth/2.f)/screenWidth);
 //   id vc = self.listVCQueue[@(row)];
 //   [vc setHeightAuto];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nagetiveBar"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    
    NSString *bid = self.bangumi.bid;
    if (!self.bgmImageView.image) {
        UIImage *originImage = [[BGMImageStore sharedStore] imageForKey:bid];
        if (originImage) {
            UIImage *clipedImage = [self clipImage:originImage WithRect:self.bgmImageView.frame];
            self.bgmImageView.image = clipedImage;
        } else if (self.bangumi.isLoadingImage || self.bangumi.isLoadingInfo){
            [self.bangumi addObserver:self
                              forKeyPath:@"isLoadingImage"
                                 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                 context:nil];
        } else {
            self.bangumi.isLoadingInfo = YES;
            self.bangumi.isLoadingImage = YES;
            [self downloadInfoWithImage:NO];
        }
    }
    
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)downloadInfoWithImage:(BOOL)isDownloadImage {
    NSInteger bgmId =  self.bangumi.bgmId;
    NSString *urlString = [NSString stringWithFormat:@"http://api.bgm.tv/subject/%ld?responseGroup=large", bgmId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString
      parameters:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSLog(@"get json success");
                 self.bangumi.bgmDic = responseObject;
                 self.bangumi.isLoadingInfo = NO;
                 if (isDownloadImage) {
                     NSString *imageUrlString = self.bangumi.bgmDic[@"images"][@"large"];
                     NSLog(@"%@",imageUrlString);
                     NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
                     [self downloadImageWithURL:imageUrl];
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];

}

-(void)getImage:(UIImage*)image {
    self.bangumi.isLoadingImage = NO;
    UIImage *bgmImage = [self clipImage:image WithRect:self.bgmImageView.frame];
    [[BGMImageStore sharedStore] setImage:image forKey:self.bangumi.bid];
    self.bgmImageView.image = bgmImage;
}

- (void)downloadImageWithURL:(NSURL *)imageUrl {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    NSLog(@"Start Downlad Image");
    [self.bgmImageView setImageWithURLRequest:request
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image){
                                          NSLog(@"Download Image Success");
                                          self.bangumi.isLoadingImage = NO;
                                          [[BGMImageStore sharedStore] setImage:image
                                                                         forKey:self.bangumi.bid];
                                          UIImage *clipedImage = [self clipImage:image WithRect:self.bgmImageView.frame];
                                          self.bgmImageView.image = clipedImage;

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
    NSArray *siteNameArray = [BGMDataStore sharedStore].siteNameArray;
    for (NSString *siteName in siteNameArray) {
        if ([urlString containsString:siteName]) {
            return siteName;
        }
    }
    
    return @"other";
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGFloat imageHeight = self.bgmImageView.frame.size.height - 64;
        NSValue *val = change[NSKeyValueChangeNewKey];
        CGSize offset = [val CGSizeValue];
        CGFloat alpha = offset.height / imageHeight < 1? offset.height /imageHeight: 1;
        self.statusBar.backgroundColor = [UIColor colorWithRed:41.0/255
                                                         green:187.0/255
                                                          blue:156.0/255
                                                         alpha:alpha];
        if (offset.height > imageHeight + 34) {
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        } else {
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
        }
        
    }
    
    if ([keyPath isEqual:@"isLoadingImage"]) {
        if(change[NSKeyValueChangeNewKey] == false) {
            UIImage *originImage = [[BGMImageStore sharedStore] imageForKey:self.bangumi.bid];
            if (originImage) {
                UIImage *clipedImage = [self clipImage:originImage WithRect:self.bgmImageView.frame];
                self.bgmImageView.image = clipedImage;
            } else {
                [self downloadInfoWithImage:YES];
            }
                [self.bangumi removeObserver:self forKeyPath:@"isLoadingImage"];
        }
    }
}

- (IBAction)imageDelete:(id)sender {
    self.bgmImageView.image = nil;
    [[BGMImageStore sharedStore] deleteImageForKey:self.bangumi.bid];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        CGPoint point = scrollView.contentOffset;
    
        if (point.y < 0.f) {
            point.y = 0.f;
        }
    
        scrollView.contentOffset = point;
    } else if (scrollView.tag == 2){
        //用scrollView的滑动大小与屏幕宽度取整数 得到滑动的页数
        NSInteger row = (int)((scrollView.contentOffset.x+screenWidth/2.f)/screenWidth);
        [self.navSliderMenu selectAtRow:row andDelegate:NO];
        //根据页数添加相应的视图
        [self addListVCWithIndex:(int)(scrollView.contentOffset.x/screenWidth)];
        [self addListVCWithIndex:(int)(scrollView.contentOffset.x/screenWidth)+1];
        
        
        
    }
}
/*
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.tag == 2) {
        NSInteger row = (int)((scrollView.contentOffset.x+screenWidth/2.f)/screenWidth);
        id vc = self.listVCQueue[@(row)];
        [vc setHeightAuto];
    }
}
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 2) {
        NSInteger row = (int)((scrollView.contentOffset.x+screenWidth/2.f)/screenWidth);
        id vc = self.listVCQueue[@(row)];
        [vc setHeightAuto];
    }

}


- (void) initSlideMenuAndContent {
    QHNavSliderMenuStyleModel *model = [QHNavSliderMenuStyleModel new];
    model.menuTitles = @[@"番组信息", @"放送站点"];
    model.menuWidth = screenWidth / 2;
    model.autoSuitLineViewWithdForBtnTitle = YES;
    model.hideViewBottomLineView = NO;
    UIFont *font = [UIFont systemFontOfSize:13];
    model.titleLableFont = font;
    _navSliderMenu = [[QHNavSliderMenu alloc] initWithFrame:CGRectMake(0, self.timeStart.bottom + 20, screenWidth, 50)
                                              andStyleModel:model
                                                andDelegate:self
                                                   showType:QHNavSliderMenuTypeTitleOnly];
    _navSliderMenu.backgroundColor = [UIColor whiteColor];
    [self.scrollViewSubView addSubview:_navSliderMenu];
    [self drawLineWithPoints:CGPointMake(0, _navSliderMenu.bottom)
                         and:CGPointMake(screenWidth, _navSliderMenu.bottom)];
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _navSliderMenu.bottom, screenWidth, 100)];
    _contentScrollView.contentSize = (CGSize){screenWidth*2, 100};
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate      = self;
    _contentScrollView.scrollsToTop  = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.tag = 2;
    [self.scrollViewSubView addSubview:_contentScrollView];
    
    __weak UIScrollView *sv = self.scrollView;
    __weak UIView *sub = self.scrollViewSubView;
    __weak UIScrollView *sv2 = self.contentScrollView;
    __weak BGMDetailViewController *sf = self;
    
    _setViewHeight = ^(CGFloat h){
        NSLog(@"sub height: %f", h);
        __strong UIScrollView *ssv = sv;
        __strong UIView *ssub = sub;
        __strong UIScrollView *ssv2 = sv2;
        __strong BGMDetailViewController *ssf = sf;
        CGFloat oldH = sv.frame.size.height;
        CGFloat newH = h + 250 + self.bgmImageView.height;
        CGFloat dif = oldH > newH? (oldH - newH) / oldH: (newH - oldH) /newH;
        ssub.frame = CGRectMake(0, 0, screenWidth, newH);
        NSLog(@"set success!");
        //CGRect frame = weakNc.view.frame;
        [UIView beginAnimations:@"Move" context:nil];
        CGFloat time = 0.5;
        [UIView setAnimationDuration:time];
        [UIView setAnimationDelegate:ssf];
        ssv.contentSize = ssub.frame.size;
        [UIView commitAnimations];
        
        ssv2.frame = CGRectMake(ssv2.origin.x, ssv2.origin.y, screenWidth, h + 20);
        ssv2.contentSize = CGSizeMake(screenWidth * 2, h + 20);
        [ssf printFrame:ssv2.frame];
        NSLog(@"contentSize: %f, %f", ssv2.contentSize.width, ssv2.contentSize.height);
        if (self.scvc) {
            self.scvc.collectionView.height = h;
        }
        
    };
    
    [self addListVCWithIndex:0];
     
}

- (void)navSliderMenuDidSelectAtRow:(NSInteger)row {
    //让scrollview滚到相应的位置
    [self.contentScrollView setContentOffset:CGPointMake(row*screenWidth, self.contentScrollView.contentOffset.y)  animated:NO];
    id vc = self.listVCQueue[@(row)];
    /*
    if (!row) {
    [self transitionFromViewController:self.childViewControllers[1 - row]
                      toViewController:self.childViewControllers[row]
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
    }
     */
    [vc setHeightAuto];
    
}

- (void)addListVCWithIndex:(NSInteger)index {
    if (!_listVCQueue) {
        _listVCQueue=[[NSMutableDictionary alloc] init];
    }
    if (index < 0 || index >= 2) {
        return;
    }
    //根据页数添加相对应的视图 并存入数组
    
    if (![_listVCQueue objectForKey:@(index)]) {
        if (!index) {
            BGMInfoViewController *contentViewController = [[BGMInfoViewController alloc] init];
            contentViewController.bangumi = self.bangumi;
            contentViewController.setViewHeight = self.setViewHeight;
            contentViewController.index = (int)index;
            [self addChildViewController:contentViewController];
            contentViewController.view.left = index * screenWidth;
            contentViewController.view.top  = 0;
            [self.contentScrollView addSubview:contentViewController.view];
            [_listVCQueue setObject:contentViewController forKey:@(index)];
        } else {
            // 创建流水布局
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            
            // 设置每个格子的尺寸
            layout.itemSize = CGSizeMake(120, 150);
            
            // 设置整个collectionView的内边距
            CGFloat paddingY = 10;
            CGFloat paddingX = 20;
            layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
            
            // 设置每一行之间的间距
            layout.minimumLineSpacing = paddingY;

            BGMSitesCollectionViewController *contentViewController =
                [[BGMSitesCollectionViewController alloc] initWithCollectionViewLayout:layout
                                                                                andBgm:self.bangumi];
            contentViewController.setViewHeight = self.setViewHeight;
            contentViewController.index = (int)index;
            contentViewController.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addChildViewController:contentViewController];
            contentViewController.view.left = index * screenWidth;
            contentViewController.view.top  = 0;
            [_contentScrollView addSubview:contentViewController.view];
            [_listVCQueue setObject:contentViewController forKey:@(index)];
            self.scvc = contentViewController;
        }
    }
    
}

- (void)printFrame:(CGRect)frame {
    NSLog(@"x: %f, y: %f, width: %f, height: %f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (void)drawLineWithPoints:(CGPoint)aPoint and:(CGPoint)bPoint {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context,1,1,1,1.0);//画笔线的颜色
    
    CGContextSetLineWidth(context, 1.0);
    CGPoint points[2] = {aPoint, bPoint};
    
    //CGContextAddLines(CGContextRef c, const CGPoint points[],size_t count)
    //points[]坐标数组，和count大小
    CGContextAddLines(context, points, 2);//添加线
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
}

@end
