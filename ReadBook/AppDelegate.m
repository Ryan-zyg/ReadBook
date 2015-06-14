//
//  AppDelegate.m
//  ReadBook
//
//  Created by z z on 12-6-28.
//  Copyright (c) 2012年 z. All rights reserved.
//

#import "AppDelegate.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize iosPlatform;

-(void) dealloc
{
//    [_window release];
//    [_viewController release];
//    [super dealloc];
}

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.iosPlatform=[self get_platform];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if(IsPad)
    {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    }
    else
    {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void) applicationWillResignActive:(UIApplication*)application
{
    [self.viewController saveBookMark];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
//    [self.viewController saveBookMark];
}

-(void) applicationWillTerminate:(UIApplication*)application
{
//    [self.viewController saveBookMark];
}

-(NSString*) get_platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine=malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *res=[NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if([res isEqualToString:@"i386"])
        res=@"iphone-emulator";
    
    NSLog(@"platform : %@",res);
    return res;
}

-(BOOL) isUpIphone7
{
	if([iosPlatform hasPrefix:@"iPhone"])
	{
		NSString* sub=[iosPlatform substringFromIndex:@"iPhone".length];
		NSString* iphoneVersion=[sub stringByReplacingOccurrencesOfString:@"," withString:@"."];
		float version=[iphoneVersion floatValue];
		if(version>=7.0)
			return YES;
	}
	
	return NO;
}

@end
