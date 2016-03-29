//
//  BGMSeason.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMSeason.h"
#import "BGMDataStore.h"
#import "BGMTableViewController.h"
#import "AFNetworking.h"

@class AFHTTPSessionManager;

@implementation BGMSeason

- (instancetype)initWithURL:(NSString *)url andBlock:(void (^)(void))block
{
    self = [super init];
    if (self) {
        _bgmOfWeekDay = [[NSMutableArray alloc] init];
        _reloadBlock = block;
        for (int i = 0; i < 8; i++) {
            // 0为周日，1为周一...，6为周六，7为全部；
            NSMutableArray *weekday = [[NSMutableArray alloc] init];
            [_bgmOfWeekDay addObject:weekday];
        }
        /*
        NSURLSessionConfiguration *config =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                              delegate:nil
                                                         delegateQueue:nil];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req
                                                    completionHandler:
                                          ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                              NSDictionary *allBgm =
                                              [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                                              for (NSString *key in allBgm) {
                                                  BGMBangumi *bgm = [[BGMBangumi alloc] initWithDic:allBgm[key] andBid:key];
                                                  [_bgmOfWeekDay[7] addObject:bgm];
                                                  [_bgmOfWeekDay[bgm.weekDayCN] addObject:bgm];
                                              }
                                              
                                              while (![BGMDataStore sharedStore].nowTvc) {
                                              }
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [[BGMDataStore sharedStore].nowTvc.tableView reloadData];
                                              });
                                          }];
        [dataTask resume];
         */
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:url
          parameters:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSDictionary *allBgm = responseObject;
                 for (NSString *key in allBgm) {
                     BGMBangumi *bgm = [[BGMBangumi alloc] initWithDic:allBgm[key] andBid:key];
                     [_bgmOfWeekDay[7] addObject:bgm];
                     [_bgmOfWeekDay[bgm.weekDayCN] addObject:bgm];
                 }
                 
                 while (![BGMDataStore sharedStore].nowTvc) {
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[BGMDataStore sharedStore].nowTvc.tableView reloadData];
                 });

             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error:%@", error);
             }
         ];
        
        
    }
    return self;
}

@end