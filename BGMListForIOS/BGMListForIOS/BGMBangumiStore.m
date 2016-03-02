//
//  BGMBangumiStore.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/25.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMBangumiStore.h"

@interface BGMBangumiStore ()

@property (nonatomic, strong) NSMutableDictionary *priviateSeason;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSString *baseURLString;
@property (nonatomic) NSString *archiveAppendingString;
@property (nonatomic) NSDictionary *archiveDictionary;

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

        [self fetchFeed];
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[BGMBangumiStore sharedStore]" userInfo:nil];
}

- (BOOL)setSeason:(NSString *)season {
    self.nowSeason = self.priviateSeason[season];
    
    if (self.nowSeason) {
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)allSeason {
    return self.priviateSeason;
}

- (void)fetchFeed {
    NSString *archiveURLstring = [self.baseURLString stringByAppendingString:self.archiveAppendingString];
    NSURL *url = [NSURL URLWithString:archiveURLstring];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req
                                                     completionHandler:
                                      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                          self.archiveDictionary =
                                          [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:nil];
                                          NSString *path = self.archiveDictionary[@"data"][self.timeDic[@"year"]][self.timeDic[@"month"]][@"path"];
                                          NSString *thisSeasonURLsrting = [self.baseURLString stringByAppendingString:path];
                                          NSURL *thisSeasonURL = [NSURL URLWithString:thisSeasonURLsrting];
                                          
                                          BGMSeason *thisSeason = [[BGMSeason alloc] initWithURL:thisSeasonURL andBlock:self.reloadBlock];
                                          NSMutableDictionary *bgmSeasonDic = [[NSMutableDictionary alloc] init];
                                          bgmSeasonDic[self.timeDic[@"month"]] = thisSeason;
                                          self.priviateSeason[self.timeDic[@"year"]] = bgmSeasonDic;
                                          self.nowSeason = thisSeason;
                                      }];
    [dataTask resume];

    
}

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




@end
