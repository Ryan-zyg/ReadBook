//
//  AppDelegate.h
//  ReadBook
//
//  Created by z z on 12-6-28.
//  Copyright (c) 2012年 z. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) NSString* iosPlatform;

-(BOOL) isUpIphone7;

@end
