//
//  BGMBangumiStore.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMBangumiStore.h"
#import "BGMDataStore.h"
#import "AFNetworking.h"

@class AFHTTPSessionManager;

@interface BGMBangumiStore ()

@property (nonatomic, strong) NSMutableDictionary *priviateSeason;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSString *baseURLString;
@property (nonatomic) NSString *archiveAppendingString;
@property (nonatomic, copy) NSMutableArray *priviateHistory;
@property (nonatomic, copy) NSDictionary *archiveDictionary;


@end

@implementation BGMBangumiStore

+ (instancetype)sharedStore {
    static BGMBangumiStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPriviate];
    });
    
    
    return sharedStore;
}

- (instancetype)initPriviate
{
    self = [super init];
    if (self) {
        _priviateSeason = [[NSMutableDictionary alloc] init];
        NSURLSessionConfiguration *config =
            [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
        _timeDic = [self getYearAndMonthAndWeekday];
        _baseURLString = @"http://bgmlist.com/";
        _archiveAppendingString = @"json/archive.json";
        _priviateHistory = [[NSMutableArray alloc] init];

        [self fetchFeed];
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[BGMBangumiStore sharedStore]" userInfo:nil];
}

- (BOOL)setSeasonWithYear:(NSString *)year andMonth:(NSString *)month; {
    if (!self.priviateSeason[year] || !self.priviateSeason[year][month]) {
        [self fetchFeedWithYear:year andMonth:month];
    }
    
    self.nowSeason = self.priviateSeason[year][month];
    
    return YES;
}

- (NSDictionary *)allSeason {
    return self.priviateSeason;
}

- (void)fetchFeed {

    NSString *archiveURLstring = [self.baseURLString stringByAppendingString:self.archiveAppendingString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:archiveURLstring
      parameters:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSLog(@"Success load JSON data");
                 self.archiveDictionary = responseObject;
                 
                 for (NSString *year in self.archiveDictionary[@"data"]) {
                     NSMutableArray *thisYeay = [[NSMutableArray alloc] init];
                     [thisYeay addObject:year];
                     for (NSString *month in self.archiveDictionary[@"data"][year]) {
                         [thisYeay addObject:month];
                     }
                     [thisYeay sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                         NSInteger m1 = [obj1 integerValue];
                         NSInteger m2 = [obj2 integerValue];
                         if (m1 > 1000) {
                             return NSOrderedAscending;
                         } else if(m2 > 1000) {
                             return NSOrderedDescending;
                         } else {
                             if (m1 > m2) {
                                 return NSOrderedDescending;
                             } else if (m1 == m2) {
                                 return NSOrderedSame;
                             } else {
                                 return NSOrderedAscending;
                             }
                         }
                     }];
                     [self.priviateHistory addObject:thisYeay];
                 }
                 
                 [self.priviateHistory sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                     NSArray *y1 = obj1;
                     NSArray *y2 = obj2;
                     NSInteger y1m = [y1[0] integerValue];
                     NSInteger y2m = [y2[0] integerValue];
                     if (y1m > y2m) {
                         return NSOrderedDescending;
                     } else if (y1m == y2m) {
                         return NSOrderedSame;
                     } else {
                         return NSOrderedAscending;
                     }
                 }];
                 
                 NSString *path = self.archiveDictionary[@"data"][self.timeDic[@"year"]][self.timeDic[@"month"]][@"path"];
                 NSString *thisSeasonURLsrting = [self.baseURLString stringByAppendingString:path];
                 
                 BGMSeason *thisSeason = [[BGMSeason alloc] initWithURL:thisSeasonURLsrting
                                                               andBlock:self.reloadBlock];
                 thisSeason.timeTitle = [NSString stringWithFormat:@"%@年%@月番组",
                                         self.timeDic[@"year"],
                                         self.timeDic[@"month"]];
                 UITableViewController *nowTvc =  [BGMDataStore sharedStore].nowTvc;
                 nowTvc.navigationItem.title = thisSeason.timeTitle;
                 
                 NSMutableDictionary *bgmSeasonDic = [[NSMutableDictionary alloc] init];
                 bgmSeasonDic[self.timeDic[@"month"]] = thisSeason;
                 self.priviateSeason[self.timeDic[@"year"]] = bgmSeasonDic;
                 self.nowSeason = thisSeason;

             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error: %@", error);
         }
     ];

    
}

- (void)fetchFeedWithYear:(NSString *)year andMonth:(NSString *)month {
    NSString *path = self.archiveDictionary[@"data"][year][month][@"path"];
    NSString *thisSeasonURLsrting = [self.baseURLString stringByAppendingString:path];
    
    BGMSeason *thisSeason = [[BGMSeason alloc] initWithURL:thisSeasonURLsrting
                                                  andBlock:self.reloadBlock];
    thisSeason.timeTitle = [NSString stringWithFormat:@"%@年%@月番组",
                            year,
                            month];
    
    NSMutableDictionary *bgmYearDic = self.priviateSeason[year];
    if (!bgmYearDic) {
        bgmYearDic = [[NSMutableDictionary alloc] init];
        self.priviateSeason[year] = bgmYearDic;

    }
    bgmYearDic[month] = thisSeason;
    self.nowSeason = thisSeason;

    
};

- (NSDictionary *)getYearAndMonthAndWeekday {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSInteger weekday = [components weekday] - 1;
    NSMutableDictionary *yearDic = [[NSMutableDictionary alloc] init];
    yearDic[@"year"] = [NSString stringWithFormat:@"%ld", year];
    yearDic[@"weekday"] = [NSNumber numberWithInteger:weekday];
    NSLog(@"%@", yearDic[@"year"]);
    switch (month) {
        case 1:
        case 2:
        case 3:
            yearDic[@"month"] = @"1";
            break;
        case 4:
        case 5:
        case 6:
            yearDic[@"month"] = @"4";
            break;
        case 7:
        case 8:
        case 9:
            yearDic[@"month"] = @"7";
        case 10:
        case 11:
        case 12:
            yearDic[@"month"] = @"10";
            break;
        default:
            break;
    }
    
    return yearDic;
}

- (NSArray *)historySeasons {
    return (NSArray *)self.priviateHistory;
}


@end
