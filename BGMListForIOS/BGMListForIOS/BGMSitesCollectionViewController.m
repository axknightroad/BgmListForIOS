//
//  BGMSitesCollectionViewController.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMSitesCollectionViewController.h"
#import "BGMBangumi.h"
#import "BGMCollectionViewCell.h"
#import "BGMDataStore.h"

@interface BGMSitesCollectionViewController ()

@property CGFloat height;

@end

@implementation BGMSitesCollectionViewController

static NSString * const reuseIdentifier = @"BGMCollectionViewCell";


- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout andBgm:(BGMBangumi*)bgm{
    self = [self initWithCollectionViewLayout:layout];
    
    if (self) {
        _bangumi = bgm;
        _height = 0;
        UICollectionView *cv = [[UICollectionView alloc] initWithFrame:self.collectionView.frame
                                                  collectionViewLayout:layout];
        cv.translatesAutoresizingMaskIntoConstraints = NO;
        UINib *nib = [UINib nibWithNibName:@"BGMCollectionViewCell" bundle:nil];
        [cv registerNib:nib forCellWithReuseIdentifier:@"BGMCollectionViewCell"];
        cv.backgroundColor = [UIColor clearColor];
        self.collectionView = cv;
        NSUInteger siteCount = self.bangumi.onAirSite.count;
        NSUInteger lineNums = (siteCount + 1) / 2;
        NSUInteger height = 170 * lineNums + 10;
        _height = height;
        /*
        if (_height) {
            CGRect frame = self.collectionView.frame;
            frame.size.height = _height;
            self.collectionView.frame = frame;
        }
         */
        NSLog(@"setCV");
        
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.collectionView.backgroundColor = [UIColor clearColor];
    
    //UINib *nib = [UINib nibWithNibName:@"BGMCollectionViewCell" bundle:nil];
    //[self.collectionView registerNib:nib forCellWithReuseIdentifier:@"BGMCollectionViewCell"];
    
    /*
    NSUInteger siteCount = self.bangumi.onAirSite.count;
    NSUInteger lineNums = (siteCount + 1) / 2;
    NSUInteger height = 150 * lineNums + (lineNums + 1) * 10;
    _height = height + 20;
    CGRect frame = self.collectionView.frame;
    frame.size.height = _height;
    self.collectionView.frame = frame;
    NSLog(@"siteCount: %ld, lineNums: %ld, height: %f",siteCount, lineNums, _height);
     */
    /*
    NSString *heightConstraint = [NSString stringWithFormat:@"V:[collectionView(==%ld)]",height];
    NSDictionary *nameMap = @{@"collectionView": self.collectionView};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:heightConstraint
                                                                   options:0
                                                                   metrics:nil
                                                                     views:nameMap];
     
    [self.collectionView addConstraints:constraints];
    */
    
    // Do any additional setup after loading the view.
}


-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"did appear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSLog(@"layout");
}

- (void)setHeightAuto {
    if(_height) {
        self.setViewHeight(self.height);
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

#pragma mark <UICollectionViewDataSource>

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.bangumi.onAirSite.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BGMCollectionViewCell *myCell=[collectionView dequeueReusableCellWithReuseIdentifier:
                                   @"BGMCollectionViewCell" forIndexPath:indexPath];
    //[myCell setBackgroundColor:[UIColor blackColor]];
    NSString *siteName = [self getSiteNameFromURLString:self.bangumi.onAirSite[indexPath.row]];
    NSString *siteChineseName = [BGMDataStore sharedStore].siteChineseNameDic[siteName];
    myCell.siteName.text = siteChineseName;
    myCell.siteImageView.image = [UIImage imageNamed:siteName];
    return  myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = self.bangumi.onAirSite[indexPath.row];
    NSString *siteName = [self getSiteNameFromURLString:urlString];
    if ([siteName isEqualToString:@"tucao"]) {
        //NSLog(@"before: %@",urlString);
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"after: %@",urlString);
    }
    NSString *siteURL = [siteName stringByAppendingString:@"://"];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL  URLWithString:siteURL]]){
        NSLog(@"install--");
        if ([siteName isEqualToString:@"bilibili"]) {
            siteURL = [siteURL stringByAppendingString:@"?url="];
            NSString *bgmURL = [siteURL stringByAppendingString:urlString];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:bgmURL]];
        }
        
    }else{
        NSLog(@"Not install");
        NSLog(@"%@",urlString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

#pragma mark <UICollectionViewDelegate>


- (NSString *)getSiteNameFromURLString:(NSString *)urlString {
    NSArray *siteNameArray = [BGMDataStore sharedStore].siteNameArray;
    for (NSString *siteName in siteNameArray) {
        if ([urlString containsString:siteName]) {
            return siteName;
        }
    }
    
    return @"other";
}




/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
