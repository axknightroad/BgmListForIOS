//
//  BGMTableViewCell.m
//  BGMListForIOS
//
//  Created by Axel Han on 16/3/24.
//  Copyright © 2016年 Axel Han. All rights reserved.
//

#import "BGMTableViewCell.h"

@implementation BGMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)clipAndSet {
    self.bgmImageView.image = [self clipImage:self.bgmImage WithRect:self.bgmImageView.frame];
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




@end
