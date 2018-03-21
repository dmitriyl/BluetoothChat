//
//  ImageCell.m
//  BluetoothChat
//
//  Created by Dmitriy L. on 7/12/16.
//  Copyright © 2016. All rights reserved.
//

#import "ImageCell.h"
#import "Transcript.h"

@implementation ImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)cutomInit:(Transcript*)object
{
    self.ivLeft.layer.cornerRadius = 5.0;
    self.ivLeft.layer.masksToBounds = YES;
    self.ivLeft.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.ivLeft.layer.borderWidth = 0.5;
    
    self.ivRight.layer.cornerRadius = 5.0;
    self.ivRight.layer.masksToBounds = YES;
    self.ivRight.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.ivRight.layer.borderWidth = 0.5;
    
    UIImage *image = [UIImage imageWithContentsOfFile:object.imageUrl.path];
    
    self.ivRight.hidden = YES;
    self.ivLeft.hidden = YES;
    self.ivRight.image = nil;
    self.ivLeft.image = nil;
    
    if (TRANSCRIPT_DIRECTION_SEND == object.direction)
    {
        self.ivRight.hidden = NO;
        self.ivRight.image = image;
    }
    else if (TRANSCRIPT_DIRECTION_RECEIVE == object.direction)
    {
        self.ivLeft.hidden = NO;
        self.ivLeft.image = image;
    }
}

@end
