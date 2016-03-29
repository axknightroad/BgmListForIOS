//
//  BGMTableViewCell.h
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/24.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGMTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bgmImageView;
@property (weak, nonatomic) IBOutlet UILabel *bgmName;
@property (weak, nonatomic) IBOutlet UILabel *blueLable;
@property (weak, nonatomic) UIImage *bgmImage;

- (void)clipAndSet;

@end
