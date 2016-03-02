//
//  BGMImageStore.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/28.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMImageStore.h"

@interface BGMImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation BGMImageStore

+ (instancetype)sharedStore {
    static BGMImageStore *sharedStore = nil;
    /*
     if (!sharedStore) {
     sharedStore = [[self alloc] initPrivate];
     }
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [BGMImageStore sharedStore]" userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    self.dictionary[key] = image;
    
    NSString *imagePath  = [self imagePathForKey:key];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key {
    //return self.dictionary[key];
    
    UIImage *result = self.dictionary[key];
    
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        if (result) {
            self.dictionary[key] = result;
        } else {
            NSLog(@"Error: unable to find %@", [self imagePathForKey:key]);
        }
    }
    
    return result;
}

- (void)deleteImageForKey:(NSString *)key {
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    
    
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (NSString *)imagePathForKey:(NSString *)key {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache:(NSNotification *)note {
    NSLog(@"flushing %d images out of cache", [self.dictionary count]);
    [self.dictionary removeAllObjects];
}


@end
