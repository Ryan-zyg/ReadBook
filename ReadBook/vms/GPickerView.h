
#import <UIKit/UIKit.h>

@protocol GPickViewDelegate
-(void) finishPick:(id)sender picked:(NSString*)str picked2:(NSString*)str2;
@end

@interface GPickView : UIView <UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray* array;
    NSMutableDictionary* dict;
    BOOL    beDict;
    
    UIPickerView*   pick;
	__unsafe_unretained id<GPickViewDelegate> delegate;
}

@property (nonatomic,assign) id<GPickViewDelegate>	delegate;
@property (nonatomic,retain) NSMutableArray*		array;
@property (nonatomic,retain) NSMutableDictionary*	dict;
@property (nonatomic,assign) BOOL					beDict;

-(void) buildTestData;
-(void) buildPickView;

@end

