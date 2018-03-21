//
//  ImageCell.h
//  BluetoothChat
//
//  Created by Dmitriy L. on 7/12/16.
//  Copyright © 2016. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Transcript;

@interface ImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivLeft;
@property (weak, nonatomic) IBOutlet UIImageView *ivRight;
@property (weak, nonatomic) Transcript *transcript;

- (void)cutomInit:(Transcript*)object;

@end
