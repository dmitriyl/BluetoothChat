//
//  AppCoordinator.m
//  BluetoothChat
//
//  Created by Dmitriy L. on 3/21/16.
//  Copyright © 2016. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppCoordinator.h"

@implementation AppCoordinator {
    UINavigationController *navigation;
}

-(id)initWith:(UIWindow*)window {
    navigation = [[UINavigationController alloc] init];
    window.rootViewController = navigation;
    return self;
}

- (void)start {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    navigation.navigationBarHidden = YES;
    [navigation setViewControllers:@[vc] animated:NO];
}

@end
