
#import "AppDelegate.h"

#define appDelegate ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define DisplayVersionNumber [NSString stringWithFormat:@"%@.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],\
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]
#define PublishTime [[[NSBundle mainBundle] infoDictionary] objectForKey:@"PublishTime"]
#define AlertTitle [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define IsPad [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad

//color
#define KWhiteColor [UIColor whiteColor]
#define KClearColor [UIColor clearColor]
#define KBlackColor [UIColor blackColor]
#define KGrayColor [UIColor grayColor]
#define KPurpleColor [UIColor purpleColor]
#define KBlueColor [UIColor blueColor]

#define Color0(r,g,b) [UIColor colorWithRed:r green:g blue:b alpha:1.0]
#define Color(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define ColorA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/1.0]
#define Font(s) [UIFont systemFontOfSize:s]
#define FontBold(s) [UIFont boldSystemFontOfSize:s]
//#define txtLength(t,s,l) [GPUtilities getTxtLength:t font:s limit:l]
//#define txtLength2(t,f,l) [GPUtilities getTxtLength:t withFont:f limit:l]

#define KScreenRect [[UIScreen mainScreen] bounds]
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define FileExsit(name) [[NSFileManager defaultManager] fileExistsAtPath:name]

#define BeUpIP6 [appDelegate isUpIphone7]

#define LOG     NSLog
#define LOGA(f) NSLog(@"%@",f)
#define LOGS(f) NSLog(@"%s",f)
#define LOGN(f) NSLog(@"%d",f)
#define LOGF(f) NSLog(@"%f",f)
#define LogClass NSLog(@"in -- class: %@",self.class)
#define LOGFUN NSLog(@"%s | %d",__FUNCTION__,__LINE__)
#define LOGFUN3 NSLog(@"%s | %d | %s",__FILE__,__LINE__,__FUNCTION__)
#define LogRect(rect) NSLog(@"rect x:%f y:%f w:%f h:%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height)
#define LogSign NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

#define LTXT(s) NSLocalizedString(@"" #s "",@"")
#define IMG(s) [UIImage imageNamed:@"" #s ".png"]
#define IMG2(s) [UIImage imageNamed:s]
#define Str(s) (s==nil ? @"" : s)
#define StrNull(f) (f==nil || ![f isKindOfClass:[NSString class]] || ([f isKindOfClass:[NSString class]] && [f isEqualToString:@""]))
#define StrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define ValidClass(f,cls) (f!=nil && [f isKindOfClass:[cls class]])

#define SF(f) [NSString stringWithFormat:@"%@",f]
#define SFI(f) [NSString stringWithFormat:@"%d",f]
#define SFF(f) [NSString stringWithFormat:@"%f",f]
#define Replace(s,a,b) [s stringByReplacingOccurrencesOfString:a withString:b]

#define DataStr(str) [str dataUsingEncoding:NSUTF8StringEncoding]
#define StrData(data) [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]

















