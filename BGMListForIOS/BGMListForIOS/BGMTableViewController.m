//
//  BGMTableViewController.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMTableViewController.h"
#import "BGMBangumi.h"
#import "BGMDetailViewController.h"
#import "BGMDataStore.h"

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
        self.navigationItem.title = @"番组计划";
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
        
        UIPanGestureRecognizer *pgr =
            [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(pan:)];
        pgr.delegate = self;
        //pgr.cancelsTouchesInView = NO;
        [self.tableView addGestureRecognizer:pgr];
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView removeFromSuperview];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    BGMBangumi *bgm = [BGMBangumiStore sharedStore].nowSeason.bgmOfWeekDay[self.weekday][indexPath.row];
    cell.textLabel.text = bgm.titleCN;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BGMDetailViewController *dvc = [[BGMDetailViewController alloc] init];
    NSArray *bgmList = [BGMBangumiStore sharedStore].nowSeason.bgmOfWeekDay[self.weekday];
    BGMBangumi *selectBgm = bgmList[indexPath.row];
    
    dvc.bangumi = selectBgm;
    [self.navigationController pushViewController:dvc animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)leftMenu {
    if (!self.leftMendOpened) {
        self.moveFrameTo(100);
        self.leftMendOpened = YES;
    } else {
        self.moveFrameTo(0);
        self.leftMendOpened = NO;
    }

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


@end
