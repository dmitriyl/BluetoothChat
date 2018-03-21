//
//  InfoCell.h
//  BluetoothChat
//
//  Created by Dmitriy L. on 7/7/16.
//  Copyright © 2016. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Transcript;

@interface InfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbText;
@property (weak, nonatomic) Transcript *transcript;

- (void)setMessage:(Transcript*)object;

@end
