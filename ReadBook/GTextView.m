
#import "GTextView.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#import "ViewController.h"

@implementation GTextView

@synthesize canMenu,canClick;

-(id) init
{
    if((self=[super init]))
    {
        self.canMenu=YES;
        self.canClick=YES;
    }
    return self;
}

//-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
//{
//    return canMenu;
//}

-(BOOL) canBecomeFirstResponder
{
    return canClick;
}

@end
