//
//  ViewController.h
//  ReadBook
//
//  Created by z z on 12-6-28.
//  Copyright (c) 2012年 z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import "GPickerView.h"

@class GTextView;

@interface ViewController : UIViewController <WebFileResourceDelegate,UITableViewDataSource,UITableViewDelegate,GPickViewDelegate,UITextFieldDelegate>
{
	HTTPServer *httpServer;
	NSMutableArray *fileList;
    
    UITableView* list;
    UIView* uploadView;
    GTextView* txtView;
    UIScrollView* settingView;
    UIScrollView* settingBar;
    UIView* jumpBar;
    UILabel* pageInfoLab;
    UILabel* hostAddressInfo;
    
    UIView* touchLeft;
    UIView* touchRight;
    UIView* touchCenter;
    
    UIButton* btnPageUp;
    UIButton* btnPageDown;
    
    UIButton* btnList;
    NSMutableDictionary* infoDict;
    NSMutableDictionary* markDict;
    
    int filesize;
    int pagecount;
    int pageindex;
    
    UITextView* settingTxt;
    
    UITextField* inputKey;
    UILabel* labPercent;
    int pageSize;
    
    float offy;
    float offy2;
    float txtViewHeight;
}

@property (nonatomic,copy) NSString* currentTxt;
@property (nonatomic,copy) NSString* currentFileName;

-(NSString*) filePathForFileName:(NSString*)filename;
-(void) setUploadService:(BOOL)on;

-(void) loadSetting;
-(void) updateSetting;
-(void) saveSetting;
-(void) getColor:(UIColor*)color red:(float*)red green:(float*)green blue:(float*)blue alpha:(float*)alpha;

-(void) loadBookMark;
-(void) saveBookMark;

-(void) listClick:(int)index;
-(void) delFile:(int)index;

-(void) clickBtnList;
-(void) jumpPrewPage;
-(void) jumpNextPage;
-(void) jumpToPage:(int)index;
-(void) touchPrewPage;
-(void) touchNextPage;
//-(void) touchCenter;

-(void) openFontPicker;
-(void) resetFont;

-(void) jumpUseSearch:(NSString*)key;
-(void) jumpPrewTenPage;
-(void) jumpNextTenPage;
-(void) doSliderJump;
-(void) doSearchJump;
-(void) jumpToPercent:(float)process;
-(void) showHiddenJumpBar;

-(void) popBlackCover;
-(void) clearBlackCover:(id)sender;

@end
