//
//  InfoCell.m
//  BluetoothChat
//
//  Created by Dmitriy L. on 7/7/16.
//  Copyright © 2016. All rights reserved.
//

#import "InfoCell.h"
#import "Transcript.h"

@implementation InfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMessage:(Transcript*)object
{
    self.lbText.text = object.message;
    
    if (TRANSCRIPT_DIRECTION_SEND == object.direction)
    {
        //self.lbText.backgroundColor = [UIColor redColor];
        self.lbText.textAlignment = NSTextAlignmentRight;
    }
    else if (TRANSCRIPT_DIRECTION_RECEIVE == object.direction)
    {
        //self.lbText.backgroundColor = [UIColor blueColor];
        self.lbText.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        //self.lbText.backgroundColor = [UIColor yellowColor];
        self.lbText.textAlignment = NSTextAlignmentCenter;
    }
}

@end
