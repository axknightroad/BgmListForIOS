//
//  AppDelegate.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "AppDelegate.h"
#import "BGMBangumiStore.h"
#import "BGMTableViewController.h"
#import "BGMLeftMenuViewController.h"
#import "BGMDataStore.h"
#import "BGMNavigationController.h"
#import "BGMViewController.h"
#import "RESideMenu.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  
    
    NSInteger today = [[BGMBangumiStore sharedStore].timeDic[@"weekday"] integerValue];
    
    BGMTableViewController *tvc = [[BGMTableViewController alloc] initWithStyle:UITableViewStylePlain andWeekday:today];
    
    
    BGMNavigationController *navController = [[BGMNavigationController alloc] initWithRootViewController:tvc];
    
    BGMLeftMenuViewController *lvc = [[BGMLeftMenuViewController alloc] init];
    
    

    
    
    
    __weak BGMNavigationController *weakNc = navController;
//    __weak BGMLeftMenuViewController *weakLvc = lvc;
    
    tvc.moveFrameTo = ^(CGFloat x){
        
        CGRect frame = weakNc.view.frame;
        [UIView beginAnimations:@"Move" context:nil];
        CGFloat time = x > 50? 0.2 * x / 100: 0.2 * (100 - x) / 100;
        [UIView setAnimationDuration:time];
        [UIView setAnimationDelegate:self];
        frame.origin.x = x;
        weakNc.view.frame = frame;
        [UIView commitAnimations];
    };
    
    __weak BGMTableViewController *weakTvc = tvc;
    lvc.changWeekdayBlock = ^(NSInteger weekday){
        weakTvc.weekday = weekday;
        weakTvc.navigationItem.leftBarButtonItem.title = [BGMDataStore sharedStore].weekdayStrings[weekday];
        [weakTvc.tableView reloadData];
        weakTvc.leftMendOpened = NO;
        /*
        CGRect frame = weakNc.view.frame;
        [UIView beginAnimations:@"Move" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        frame.origin.x = 0;
        weakNc.view.frame = frame;
        [UIView commitAnimations];
         */
    };
    
    /* 原来的rootViewController
    BGMViewController *rvc = [[BGMViewController alloc] init];
    self.window.rootViewController = rvc;
    
    [rvc addChildViewController:lvc];
    [rvc.view addSubview:lvc.view];
    [rvc addChildViewController:navController];
    [rvc.view addSubview:tvc.view];
    [rvc.view addSubview:navController.view];
    */
    
    RESideMenu *rootSideMenuViewController =
    [[RESideMenu alloc] initWithContentViewController:navController
                               leftMenuViewController:lvc
                              rightMenuViewController:nil];
    
    self.window.rootViewController = rootSideMenuViewController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
