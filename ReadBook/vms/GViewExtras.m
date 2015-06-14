
#import "GViewExtras.h"

@implementation NSDictionary(DeepMutableCopy)
-(NSMutableDictionary*) mutableDeepCopy
{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    NSArray *keys = [self allKeys];
    
    for (id key in keys)
    {
        id oneValue = [self valueForKey:key];
        id oneCopy = nil;
        
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)])
            oneCopy = [oneValue mutableDeepCopy];
        else if ([oneValue respondsToSelector:@selector(mutableCopy)])// && [oneValue respondsToSelector:@selector(mutableCopyWithZone)])
            oneCopy = [oneValue mutableCopy];
        
        if (oneCopy == nil)
            oneCopy = [oneValue copy];
        
        [ret setValue:oneCopy forKey:key];
    }
    return ret;
}
@end

@implementation UIView(Extras)
-(CGSize) size
{
    return self.frame.size;
}
-(void) setSize:(CGSize)aSize
{
    CGRect newframe=self.frame;
    newframe.size=aSize;
    self.frame=newframe;
}
-(CGPoint) origin
{
    return self.frame.origin;
}
-(void) setOrigin:(CGPoint)aPoint
{
    CGRect newframe=self.frame;
    newframe.origin=aPoint;
    self.frame=newframe;
}
-(CGPoint) bottomLeft
{
    CGFloat x=self.frame.origin.x;
    CGFloat y=self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}
-(CGPoint) bottomRight
{
    CGFloat x=self.frame.origin.x + self.frame.size.width;
    CGFloat y=self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}
-(CGPoint) topRight
{
    CGFloat x=self.frame.origin.x + self.frame.size.width;
    CGFloat y=self.frame.origin.y;
    return CGPointMake(x, y);
}
-(CGFloat) height
{
    return self.frame.size.height;
}
-(void) setHeight:(CGFloat)aHeight
{
    CGRect newframe=self.frame;
    newframe.size.height=aHeight;
    self.frame=newframe;
}
-(CGFloat) width
{
    return self.frame.size.width;
}
-(void) setWidth:(CGFloat)aWidth
{
    CGRect newframe=self.frame;
    newframe.size.width=aWidth;
    self.frame=newframe;
}
-(CGFloat) top
{
    return self.frame.origin.y;
}
-(void) setTop:(CGFloat)aTop
{
    CGRect newframe=self.frame;
    newframe.origin.y=aTop;
    self.frame=newframe;
}
-(CGFloat) left
{
    return self.frame.origin.x;
}
-(void) setLeft:(CGFloat)aLeft
{
    CGRect newframe=self.frame;
    newframe.origin.x=aLeft;
    self.frame=newframe;
}
-(CGFloat) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(void) setBottom:(CGFloat)aBottom
{
    CGRect newframe=self.frame;
    newframe.origin.y=aBottom - self.frame.size.height;
    self.frame=newframe;
}
-(CGFloat) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(void) setRight:(CGFloat)aRight
{
    CGFloat delath= aRight -(self.frame.origin.y + self.frame.size.width);
    CGRect newframe=self.frame;
    newframe.origin.x += delath;
    self.frame=newframe; 
}
-(void) moveBy:(CGPoint)delta
{
}
-(void) scaleBy:(CGFloat)scaleFactor
{
}
-(void) fitInSize:(CGSize)aSize
{
}
-(void) removeAllSubViews
{
    for(UIView* view in self.subviews)
    {
        [view removeFromSuperview];
    }
}
-(void) removeAllSubViews:(Class)cla
{
    for(UIView* view in self.subviews)
    {
        if([view isKindOfClass:cla])
            [view removeFromSuperview];
    }
}
-(void) moveToParentCenter
{
    [self moveToParentCenterX];
    [self moveToParentCenterY];
}
-(void) moveToParentCenterX
{
    UIView* view=self.superview;
    if(view==nil)
        return;
    
    self.left=(view.width-self.width)/2;
}
-(void) moveToParentCenterY
{
    UIView* view=self.superview;
    if(view==nil)
        return;
    
    self.top=(view.height-self.height)/2;
}

-(UIButton*) buildTxtBtn:(CGRect)rect target:(id)target action:(SEL)action txt:(NSString*)txt
{
    self.userInteractionEnabled=YES;
    
	UIButton* btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame=rect;
    [btn setTitle:txt forState:UIControlStateNormal];
    
	[btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:btn];
	return btn;
}
-(UIButton*) buildBlankBtn:(CGRect)rect target:(id)target action:(SEL)action
{
//    if([self isKindOfClass:[UIImageView class]])
    self.userInteractionEnabled=YES;
    
	UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame=rect;
	btn.backgroundColor=KClearColor;
    
	[btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:btn];
	return btn;
}
-(UIButton*) buildBlankBtn:(id)target action:(SEL)action
{
//    if([self isKindOfClass:[UIImageView class]])
        self.userInteractionEnabled=YES;
    
    CGRect rect=self.frame;
    rect.origin.x=0;
    rect.origin.y=0;
    
    return [self buildBlankBtn:rect target:target action:action];
}
-(UILabel*) buildLabel:(NSString*)str position:(CGPoint)pt font:(UIFont*)font color:(UIColor*)color
{
	//	int h=[font fontHeight];
    CGSize temp={900000, 80};
    CGSize txtSize=[str sizeWithFont:font constrainedToSize:temp];
	CGRect rect=CGRectMake(pt.x, pt.y, txtSize.width, txtSize.height);
	
	UILabel* lab=[[UILabel alloc] initWithFrame:rect];
	lab.text=str;
	lab.font=font;
	lab.textColor=color;
	lab.backgroundColor=KClearColor;
    
	[self addSubview:lab];
//	[lab release];
	return lab;
}
-(UILabel*) buildTopLeftLabel:(NSString*)str frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color
{
    CGSize temp={frame.size.width,900000};
    CGSize txtSize=[str sizeWithFont:font constrainedToSize:temp];
	CGRect rect=CGRectMake(frame.origin.x, frame.origin.y, txtSize.width, txtSize.height);
	
	UILabel* lab=[[UILabel alloc] initWithFrame:rect];
    lab.numberOfLines=0;
	lab.text=str;
	lab.font=font;
	lab.textColor=color;
	lab.backgroundColor=KClearColor;
    
	[self addSubview:lab];
//	[lab release];
	return lab;
}
-(UILabel*) buildTopLeftLabel:(NSString*)str frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color linelimit:(int)limit
{
    CGSize temp={frame.size.width,900000};
    CGSize txtSize=[str sizeWithFont:font constrainedToSize:temp];
	CGRect rect=CGRectMake(frame.origin.x, frame.origin.y, txtSize.width, txtSize.height);
    
    temp=CGSizeMake(9999999,50);
    NSString* trimstr=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // why no effect !! ??
    trimstr=[trimstr stringByReplacingOccurrencesOfString:@" " withString:@""];
    trimstr=[trimstr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    trimstr=[trimstr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    trimstr=[trimstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    CGSize txtSize2=[trimstr sizeWithFont:font constrainedToSize:temp];
    if(txtSize.height > limit*txtSize2.height)
        rect.size.height=limit*txtSize2.height;
	
	UILabel* lab=[[UILabel alloc] initWithFrame:rect];
    lab.numberOfLines=limit;
	lab.text=str;
	lab.font=font;
	lab.textColor=color;
	lab.backgroundColor=KClearColor;
    
	[self addSubview:lab];
//	[lab release];
	return lab;
}
-(UILabel*) buildTopLeftLabelWithAutoScroll:(NSString*)str frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color
{
    CGSize temp={frame.size.width,900000};
    CGSize txtSize=[str sizeWithFont:font constrainedToSize:temp];
	CGRect rect=CGRectMake(frame.origin.x, frame.origin.y, txtSize.width, txtSize.height);
	
	UILabel* lab=[[UILabel alloc] initWithFrame:rect];
    lab.numberOfLines=0;
	lab.text=str;
	lab.font=font;
	lab.textColor=color;
	lab.backgroundColor=KClearColor;
    
    if(txtSize.height>frame.size.height)
    {
        UIScrollView* sv=[[UIScrollView alloc] initWithFrame:frame];
        [self addSubview:sv];
//        [sv release];
        
        txtSize.height+=30;
        sv.contentSize=txtSize;
        [sv addSubview:lab];
        
        rect.origin.x=0;
        rect.origin.y=0;
        lab.frame=rect;
    }
    else
        [self addSubview:lab];
    
//	[lab release];
	return lab;
}
-(UIView*) buildBgView:(UIColor*)color frame:(CGRect)rect
{
    UIView* view=[[UIView alloc] initWithFrame:rect];
    view.backgroundColor=color;
    
    [self addSubview:view];
//    [view release];
    return view;
}
-(UIScrollView*) buildBgScrollView:(UIColor*)color frame:(CGRect)rect
{
    UIScrollView* view=[[UIScrollView alloc] initWithFrame:rect];
    view.backgroundColor=color;
    
    [self addSubview:view];
//    [view release];
    return view;
}
-(UIImageView*) buildImage2:(UIImage*)img frame:(CGRect)rect
{
    UIImageView* iv=[[UIImageView alloc] initWithImage:img];
    [self addSubview:iv];
//    [iv release];
    
    iv.frame=rect;
    return iv;
}
-(UIImageView*) buildImage2:(UIImage*)img point:(CGPoint)point
{
    UIImageView* iv=[[UIImageView alloc] initWithImage:img];
    [self addSubview:iv];
//    [iv release];
    
    iv.frame=CGRectMake(point.x, point.y, img.size.width, img.size.height);
    return iv;
}
@end


