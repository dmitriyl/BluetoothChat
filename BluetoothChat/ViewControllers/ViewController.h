//
//  ViewController.h
//  BluetoothChat
//
//  Created by Dmitriy L. on 7/6/16.
//  Copyright © 2016. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tfMessage;
@property (weak, nonatomic) IBOutlet UIButton *btSend;

@end

