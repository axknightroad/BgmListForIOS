//
//  BGMImageStore.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/2/28.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGMImageStore : NSObject

+ (instancetype)sharedStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;
- (NSString *)imagePathForKey:(NSString *)key;

@end
