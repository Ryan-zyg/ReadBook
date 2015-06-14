
#import <Foundation/Foundation.h>

@interface NSDictionary(DeepMutableCopy)
-(NSMutableDictionary*) mutableDeepCopy;
@end

@interface  UIView(Extras)
@property CGSize    size;
@property CGPoint   origin;
@property (readonly) CGPoint    bottomLeft;
@property (readonly) CGPoint    bottomRight;
@property (readonly) CGPoint    topRight;
@property CGFloat   height;
@property CGFloat   width;
@property CGFloat   top;
@property CGFloat   left;
@property CGFloat   bottom;
@property CGFloat   right;

-(void) moveBy:(CGPoint) delta;
-(void) scaleBy:(CGFloat) scaleFactor;
-(void) fitInSize:(CGSize) aSize;
-(void) removeAllSubViews;
-(void) removeAllSubViews:(Class)cla;
-(void) moveToParentCenter;
-(void) moveToParentCenterX;
-(void) moveToParentCenterY;

-(UIButton*) buildTxtBtn:(CGRect)rect target:(id)target action:(SEL)action txt:(NSString*)txt;
-(UIButton*) buildBlankBtn:(CGRect)rect target:(id)target action:(SEL)action;
-(UIButton*) buildBlankBtn:(id)target action:(SEL)action;
-(UILabel*) buildLabel:(NSString*)str position:(CGPoint)pt font:(UIFont*)font color:(UIColor*)color;
-(UILabel*) buildTopLeftLabel:(NSString*)str frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color;
-(UILabel*) buildTopLeftLabel:(NSString*)str frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color linelimit:(int)limit;
-(UILabel*) buildTopLeftLabelWithAutoScroll:(NSString*)str frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color;
-(UIView*) buildBgView:(UIColor*)color frame:(CGRect)rect;
-(UIScrollView*) buildBgScrollView:(UIColor*)color frame:(CGRect)rect;
-(UIImageView*) buildImage2:(UIImage*)img frame:(CGRect)rect;
-(UIImageView*) buildImage2:(UIImage*)img point:(CGPoint)point;
@end

