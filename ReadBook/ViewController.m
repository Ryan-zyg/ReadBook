//
//  ViewController.m
//  ReadBook
//
//  Created by z z on 12-6-28.
//  Copyright (c) 2012年 z. All rights reserved.
//

#import "ViewController.h"
#import "GViewExtras.h"
#import "GTextView.h"

#define IosVersion floorf([[[UIDevice currentDevice] systemVersion] floatValue])

#define KPort 8181
#define KPageSize 10240

#define KBtnTop 10
#define KBtnLeft 25
#define KBtnWidith 80
#define KBtnHeight 30

#define KBarHeight 50
#define KListHeight 60
#define KTouchWidth 40
#define KTouchCenterWidth 50
#define KSettingFileName @"setting.dat"
#define KBookMarkFileName @"bookmark.dat"
#define KUploadPathName @"upload"

#define KSettingBgColor Color(200, 200, 230)
#define KDoneRect CGRectMake(KBtnLeft, KBtnTop+offy2, KBtnWidith, KBtnHeight)
#define KDoneDes @"Done"
#define KPageInfoTxt [NSString stringWithFormat:@"%d / %d",pageindex+1,pagecount]
#define KDefaultTxt @"我们已经见过使用木材、竹子、碳纤维或是玻璃来制作的笔记本外壳。"

// dict key
#define KKeyAutoOpen @"autoopen"
#define KKeyFontName @"fontname"
#define KKeyFontSize @"fontsize"
#define KKeyBgRed @"bg_r"
#define KKeyBgGreen @"bg_g"
#define KKeyBgBlue @"bg_b"
#define KKeyTxtRed @"txt_r"
#define KKeyTxtGreen @"txt_g"
#define KKeyTxtBlue @"txt_b"

@implementation ViewController
@synthesize currentTxt,currentFileName;

-(void) loadFileList
{
	[fileList removeAllObjects];
	NSString* docDir=[self filePathForFileName:@""];
	NSDirectoryEnumerator *direnum=[[NSFileManager defaultManager] enumeratorAtPath:docDir];
	NSString *pname;
	while (pname=[direnum nextObject])
	{
        if(![pname hasPrefix:@"."])
            [fileList addObject:pname];
	}
    
	[list reloadData];
}

-(void) initServer
{
	httpServer=[[HTTPServer alloc] init];
	[httpServer setType:@"_http._tcp."];	
	[httpServer setPort:KPort];
	[httpServer setName:@"CocoaWebResource"];
	[httpServer setupBuiltInDocroot];
	httpServer.fileResourceDelegate=self;
    
    hostAddressInfo.text=[NSString stringWithFormat:@"请手机与电脑都打开WIFI 使用电脑浏览\n器访问：http://%@:%d", [httpServer hostName], [httpServer port]];
}

-(void) initUploadPath
{
    NSFileManager* file=[NSFileManager defaultManager];
    NSError* err=nil;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString* documentsDirectory=[paths objectAtIndex:0];
	
	NSString* directory=[documentsDirectory stringByAppendingPathComponent:KUploadPathName];
    NSArray* dirContents=[file contentsOfDirectoryAtPath:directory error:&err];
    
    if(dirContents==nil)
        [file createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
}

-(void) initUploadView
{
    [UIApplication sharedApplication].statusBarHidden=NO;
    uploadView=[self.view buildBgView:KWhiteColor frame:CGRectMake(0, 0, KScreenWidth, KScreenHeight+offy)];
    uploadView.backgroundColor=KSettingBgColor;
    
    [uploadView buildTxtBtn:KDoneRect target:self action:@selector(uploadFinish) txt:KDoneDes];
    
    int y=100;
    [uploadView buildLabel:@"文本上传" position:CGPointMake(KScreenWidth/2-35, y) font:FontBold(18) color:KBlackColor];
    
    int x=20;
    y+=70;
    if(IsPad)
        x=200;
    NSString* address=[NSString stringWithFormat:@"请手机与电脑都打开WIFI 使用电脑浏览\n器访问：http://%@:%d", @"192.168.159.123",8181];//[httpServer hostName], [httpServer port]];
    UILabel* lab=[uploadView buildLabel:address position:CGPointMake(x, y) font:Font(16) color:KBlackColor];
    lab.width=KScreenWidth-lab.left*2;
    lab.numberOfLines=0;
    hostAddressInfo=lab;
}

-(void) initList
{
	list=[[UITableView alloc] initWithFrame:CGRectMake(0, KBarHeight, KScreenWidth, KScreenHeight-KBarHeight+offy)];
	list.delegate=self;
	list.dataSource=self;
	[self.view addSubview:list];
//	[list release];
}

-(void) startUpload
{
    [self initServer];
    
    uploadView.hidden=NO;
    jumpBar.hidden=YES;
    [self setUploadService:YES];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

-(void) initSettingBar
{
    settingBar=[self.view buildBgScrollView:KWhiteColor frame:CGRectMake(0, 0, KScreenWidth, KBarHeight)];
    settingBar.contentSize=CGSizeMake(KScreenWidth, 200);
    
    float x=KBtnLeft;
    btnList=[settingBar buildTxtBtn:CGRectMake(x, KBtnTop+offy2, KBtnWidith, KBtnHeight) target:self action:@selector(clickBtnList) txt:@"List"];
    btnList.hidden=YES;
    
    float cx=(KScreenWidth-KBtnWidith)/2;
    [settingBar buildTxtBtn:CGRectMake(cx, KBtnTop+offy2, KBtnWidith, KBtnHeight) target:self action:@selector(initSettingView) txt:@"Setting"];
    
    float rx=KScreenWidth-KBtnWidith-KBtnLeft;
    [settingBar buildTxtBtn:CGRectMake(rx, KBtnTop+offy2, KBtnWidith, KBtnHeight) target:self action:@selector(startUpload) txt:@"Upload"];
    
    // add for process jump
    float y=60;
    float oh=10;
    float ow=110;
    float oy=6;
    
    if(IsPad)
        ow=240;
    
    [settingBar buildLabel:@"进度:" position:CGPointMake(x, y+oy) font:Font(14) color:KBlackColor];
    labPercent=[settingBar buildLabel:@"0.0" position:CGPointMake(x+35, y+oy) font:Font(14) color:KBlackColor];
    labPercent.width=70;
    
    UISlider* slider=[[UISlider alloc] initWithFrame:CGRectMake(x+65, y+oy, ow, oh)];
    [settingBar addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=100;
    slider.value=settingTxt.font.pointSize;
    [slider addTarget:self action:@selector(sliderTxtPercent:) forControlEvents:UIControlEventValueChanged];
    
    [settingBar buildTxtBtn:CGRectMake(rx, y, KBtnWidith, KBtnHeight) target:self action:@selector(doSliderJump) txt:@"Jump"];
    
    // add for long jump
    y+=50;
    [settingBar buildTxtBtn:CGRectMake(x, y, KBtnWidith, KBtnHeight) target:self action:@selector(jumpPrewTenPage) txt:@"上10页"];
    [settingBar buildTxtBtn:CGRectMake(rx, y, KBtnWidith, KBtnHeight) target:self action:@selector(jumpNextTenPage) txt:@"下10页"];
    
    // add for search key jump
    y+=50;
    ow=130;
    if(IsPad)
        ow=280;
    
    [settingBar buildLabel:@"搜索:" position:CGPointMake(x, y+oy) font:Font(14) color:KBlackColor];
    inputKey=[[UITextField alloc] initWithFrame:CGRectMake(x+40, y, ow, 30)];
    [settingBar addSubview:inputKey];
//    [inputKey release];
    
    int gray=230;
    inputKey.backgroundColor=Color(gray, gray, gray);
    inputKey.returnKeyType = UIReturnKeyDone;
    inputKey.delegate=self;
    
    [settingBar buildTxtBtn:CGRectMake(rx, y, KBtnWidith, KBtnHeight) target:self action:@selector(doSearchJump) txt:@"Jump"];
}

-(void) initJumpBar
{
    jumpBar=[self.view buildBgView:KWhiteColor frame:CGRectMake(0, KScreenHeight-KBarHeight+offy, KScreenWidth, KBarHeight)];
    
    float x=KBtnLeft;
    [jumpBar buildTxtBtn:CGRectMake(x, KBtnTop, KBtnWidith, KBtnHeight) target:self action:@selector(jumpPrewPage) txt:@"Prew"];
    
    x=(KScreenWidth-KBtnWidith)/2;
    pageInfoLab=[jumpBar buildLabel:KPageInfoTxt position:CGPointMake(x, KBtnTop+5) font:Font(15) color:KBlackColor];
    pageInfoLab.width=KBtnWidith;
    pageInfoLab.textAlignment=UITextAlignmentCenter;
    [pageInfoLab buildBlankBtn:self action:@selector(showHiddenJumpBar)];
    
    x=KScreenWidth-KBtnWidith-KBtnLeft;
    [jumpBar buildTxtBtn:CGRectMake(x, KBtnTop, KBtnWidith, KBtnHeight) target:self action:@selector(jumpNextPage) txt:@"Next"];
}

-(void) initTxtViewTouch
{
	if(BeUpIP6 || IsPad)
	{
        float height=KScreenHeight-KBarHeight-KBarHeight;
        touchLeft=[self.view buildBlankBtn:CGRectMake(0, KBarHeight, KTouchWidth, height) target:self action:@selector(scrollPageDown)];
        touchRight=[self.view buildBlankBtn:CGRectMake(KScreenWidth-KTouchWidth, KBarHeight, KTouchWidth, height) target:self action:@selector(scrollPageDown)];
	}
	
    //    float x=(KScreenWidth-KTouchCenterWidth)/2;
    //    float y=(KScreenHeight-KTouchCenterWidth)/2;
    //    touchCenter=[self.view buildBlankBtn:CGRectMake(x, y, KTouchCenterWidth, KTouchCenterWidth) target:self action:@selector(touchCenter)];
    
    UITapGestureRecognizer* singleRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTouchCenter)];  
    [txtView addGestureRecognizer:singleRecognizer];
//    [singleRecognizer release];
    
    UITapGestureRecognizer* doubleRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doJumpOtherApp)];
    doubleRecognizer.numberOfTapsRequired=2;
    [txtView addGestureRecognizer:doubleRecognizer];
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
//    [doubleRecognizer release];
    
    //    int color=255;
    //    float alpha=0.3;
    //    touchLeft.backgroundColor=ColorA(color, color, color, alpha);
    //    touchRight.backgroundColor=ColorA(color, color, color, alpha);
    //    touchCenter.backgroundColor=ColorA(color, color, color, alpha);
    
    UISwipeGestureRecognizer* recognizerRight=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPrewPage)];
    recognizerRight.direction=UISwipeGestureRecognizerDirectionRight;
    [txtView addGestureRecognizer:recognizerRight];
//    [recognizerRight release];
    
    UISwipeGestureRecognizer* recognizerLeft=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(jumpNextPage)];
    recognizerLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [txtView addGestureRecognizer:recognizerLeft];
//    [recognizerLeft release];
}

-(void) initSettingView
{
    settingView=[self.view buildBgScrollView:KWhiteColor frame:KScreenRect];
    settingView.backgroundColor=KSettingBgColor;
    settingView.contentSize=CGSizeMake(KScreenWidth, 600);
    
    [settingView buildTxtBtn:KDoneRect target:self action:@selector(updateSetting) txt:KDoneDes];
    
    int x=20;
    int y=60;
    int w=KScreenWidth-40;
    int h=80;
    int ox=80;
    int ow=150;
    int oh=10;
    
    if(IsPad)
        ow*=2;
    
    settingTxt=[[UITextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [settingView addSubview:settingTxt];
//    [settingTxt release];
    
    settingTxt.font=txtView.font;
    settingTxt.backgroundColor=txtView.backgroundColor;
    settingTxt.textColor=txtView.textColor;
    settingTxt.text=KDefaultTxt;
    
    y+=100;
    if(IsPad)
    {
        y+=50;
        x+=120;
        ox+=120;
    }
    [settingView buildLabel:@"大小:" position:CGPointMake(x,y) font:Font(15) color:KBlackColor];
    UISlider* slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y, ow, oh)];
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=10;
    slider.maximumValue=40;
    slider.value=settingTxt.font.pointSize;
    [slider addTarget:self action:@selector(sliderFontChange:) forControlEvents:UIControlEventValueChanged];
    
    y+=45;
    [settingView buildLabel:@"字体:" position:CGPointMake(x,y) font:Font(15) color:KBlackColor];
    [settingView buildTxtBtn:CGRectMake(x+60, y, KBtnWidith, KBtnHeight) target:self action:@selector(openFontPicker) txt:@"选字体"];
    [settingView buildTxtBtn:CGRectMake(x+80+KBtnWidith, y, KBtnWidith, KBtnHeight) target:self action:@selector(resetFont) txt:@"Reset"];
    
    y+=45;
    oh=30;
    float r,g,b,a;
    [self getColor:txtView.textColor red:&r green:&g blue:&b alpha:&a];
    [settingView buildLabel:@"字色:" position:CGPointMake(x,y) font:Font(15) color:KBlackColor];
    
    slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y, ow, oh)]; // R
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=r;
    [slider addTarget:self action:@selector(sliderTxtColorRChange:) forControlEvents:UIControlEventValueChanged];
    
    slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y+oh, ow, oh)]; // G
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=g;
    [slider addTarget:self action:@selector(sliderTxtColorGChange:) forControlEvents:UIControlEventValueChanged];
    
    slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y+oh+oh, ow, oh)]; // B
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=b;
    [slider addTarget:self action:@selector(sliderTxtColorBChange:) forControlEvents:UIControlEventValueChanged];
    
    y+=100;
    [self getColor:txtView.backgroundColor red:&r green:&g blue:&b alpha:&a];
    [settingView buildLabel:@"背景:" position:CGPointMake(x,y) font:Font(15) color:KBlackColor];
    
    slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y, ow, oh)]; // R
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=r;
    [slider addTarget:self action:@selector(sliderBgColorRChange:) forControlEvents:UIControlEventValueChanged];
    
    slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y+oh, ow, oh)]; // G
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=g;
    [slider addTarget:self action:@selector(sliderBgColorGChange:) forControlEvents:UIControlEventValueChanged];
    
    slider=[[UISlider alloc] initWithFrame:CGRectMake(ox, y+oh+oh, ow, oh)]; // B
    [settingView addSubview:slider];
//    [slider release];
    
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=b;
    [slider addTarget:self action:@selector(sliderBgColorBChange:) forControlEvents:UIControlEventValueChanged];
}

-(void) initTxtView
{
    txtView=[[GTextView alloc] initWithFrame:CGRectMake(0, offy, KScreenWidth, KScreenHeight)];
    [self.view addSubview:txtView];
//    [txtView release];
    
    NSString* fontname=[infoDict objectForKey:KKeyFontName];
    float fontsize=[[infoDict objectForKey:KKeyFontSize] floatValue];
    txtView.font=[UIFont fontWithName:fontname size:fontsize];
    
    float r=[[infoDict objectForKey:KKeyBgRed] floatValue];
    float g=[[infoDict objectForKey:KKeyBgGreen] floatValue];
    float b=[[infoDict objectForKey:KKeyBgBlue] floatValue];
    txtView.backgroundColor=Color0(r, g, b);
    
    r=[[infoDict objectForKey:KKeyTxtRed] floatValue];
    g=[[infoDict objectForKey:KKeyTxtGreen] floatValue];
    b=[[infoDict objectForKey:KKeyTxtBlue] floatValue];
    txtView.textColor=Color0(r, g, b);
    
    txtView.editable=NO;
    
    btnPageUp=[self.view buildBlankBtn:CGRectMake(0, offy, KScreenWidth, 70) target:self action:@selector(scrollPageUp)];
    btnPageDown=[self.view buildBlankBtn:CGRectMake(0, KScreenHeight-80+offy2+offy2, KScreenWidth, 60) target:self action:@selector(scrollPageDown)];
    
//    btnPageUp.backgroundColor=ColorA(0, 0, 0, 0.4);
//    btnPageDown.backgroundColor=ColorA(0, 0, 0, 0.4);
}

-(void) viewDidLoad
{
    [self initUploadPath];
	fileList=[[NSMutableArray alloc] init];
    
    if(IosVersion<7.0)
        offy=-20;
    else
        offy2=10;
    
    pageSize=KPageSize;
    if(IsPad)
        pageSize+=KPageSize;
    
	[self loadFileList];
//    [self initServer];
    [self initList];
    
    [self loadSetting];
    [self loadBookMark];
    [self initTxtView];
    
    txtView.hidden=YES;
    btnPageUp.hidden=YES;
    btnPageDown.hidden=YES;
    
    [self initSettingBar];
    [self initUploadView];
    uploadView.hidden=YES;
    
    [self initJumpBar];
    jumpBar.hidden=YES;
    
    [self initTxtViewTouch];
    touchLeft.hidden=YES;
    touchRight.hidden=YES;
    touchCenter.hidden=YES;
}

-(void) dealloc
{
	httpServer.fileResourceDelegate=nil;
//	[httpServer release];
//	[fileList release];
    
    self.currentTxt=nil;
    self.currentFileName=nil;
    
//    [super dealloc];
}

-(void) setUploadService:(BOOL)on
{
	if(on)
	{
        NSError *error=nil;
		BOOL serverIsRunning=[httpServer start:&error];
		if(!serverIsRunning)
		{
			NSLog(@"Error starting HTTP Server: %@", error);
		}
	}
	else
	{
		[httpServer stop];
	}
}

#pragma mark WebFileResourceDelegate
-(NSInteger) numberOfFiles
{
	return [fileList count];
}

-(NSString*) fileNameAtIndex:(NSInteger)index
{
	return [fileList objectAtIndex:index];
}

-(NSString*) filePathForFileName:(NSString*)filename
{
	NSString* docDir=[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),KUploadPathName];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

-(NSString*) filePathForDocumentsName:(NSString*)filename
{
	NSString* docDir=[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

-(void) newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath
{
	if(name==nil || tmpPath==nil)
		return;
    
	NSString *path=[self filePathForFileName:name];
	NSFileManager *fm=[NSFileManager defaultManager];
	NSError *error;
	if (![fm moveItemAtPath:tmpPath toPath:path error:&error])
	{
		NSLog(@"can not move %@ to %@ because: %@", tmpPath, path, error );
	}
    
	[self loadFileList];
}

-(void) fileShouldDelete:(NSString*)fullname
{
	NSFileManager* fm=[NSFileManager defaultManager];
	NSError* error=nil;
	if(![fm removeItemAtPath:fullname error:&error])
	{
		NSLog(@"%@ can not be removed because:%@", fullname, error);
	}
	[self loadFileList];
}

#pragma mark UITableViewDataSource
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [fileList count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	CGRect rect=CGRectMake(0,0,list.frame.size.width,list.frame.size.height);
	UITableViewCell *cell=[[UITableViewCell alloc] initWithFrame:rect];
    
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	cell.textLabel.text=[fileList objectAtIndex:indexPath.row];
    
	return cell;
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self delFile:indexPath.row];
}

#pragma mark UITableViewDelegate
-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return KListHeight;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self listClick:indexPath.row];
}

-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

#pragma mark fun
-(void) uploadFinish
{
    [self setUploadService:NO];
    uploadView.hidden=YES;
    if(!txtView.hidden)
        jumpBar.hidden=NO;
    
    //    [self loadFileList]; // do in newFileDidUpload
    
	httpServer.fileResourceDelegate=nil; // del http, 
//	[httpServer release];
    httpServer=nil;
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

-(void) loadSetting
{
    NSString* filename=[self filePathForDocumentsName:KSettingFileName];
    NSDictionary* dict=[NSDictionary dictionaryWithContentsOfFile:filename];
    
    if(dict==nil || [dict count]==0)
    {
        infoDict=[[NSMutableDictionary alloc] init];
        
        // default setting
        [infoDict setValue:@"Helvetica" forKey:KKeyFontName];
        [infoDict setValue:@"18" forKey:KKeyFontSize];
        [infoDict setValue:@"0" forKey:KKeyBgRed];
        [infoDict setValue:@"0" forKey:KKeyBgGreen];
        [infoDict setValue:@"0" forKey:KKeyBgBlue];
        [infoDict setValue:@"1" forKey:KKeyTxtRed];
        [infoDict setValue:@"1" forKey:KKeyTxtGreen];
        [infoDict setValue:@"1" forKey:KKeyTxtBlue];
        
        [self saveSetting];
    }
    else
    {
        infoDict=[dict mutableDeepCopy];
    }
}
-(void) updateSetting
{
    txtView.font=settingTxt.font;
    txtView.backgroundColor=settingTxt.backgroundColor;
    txtView.textColor=settingTxt.textColor;
    
    [infoDict setValue:txtView.font.fontName forKey:KKeyFontName];
    [infoDict setValue:SFF(txtView.font.pointSize) forKey:KKeyFontSize];
    
    float r,g,b,a;
    [self getColor:txtView.backgroundColor red:&r green:&g blue:&b alpha:&a];
    [infoDict setValue:SFF(r) forKey:KKeyBgRed];
    [infoDict setValue:SFF(g) forKey:KKeyBgGreen];
    [infoDict setValue:SFF(b) forKey:KKeyBgBlue];
    
    [self getColor:txtView.textColor red:&r green:&g blue:&b alpha:&a];
    [infoDict setValue:SFF(r) forKey:KKeyTxtRed];
    [infoDict setValue:SFF(g) forKey:KKeyTxtGreen];
    [infoDict setValue:SFF(b) forKey:KKeyTxtBlue];
    
    [settingView removeFromSuperview];
    [self saveSetting];
}
-(void) saveSetting
{
    NSString* filename=[self filePathForDocumentsName:KSettingFileName];
	[infoDict writeToFile:filename atomically:YES];
}
-(void) getColor:(UIColor*)color red:(float*)red green:(float*)green blue:(float*)blue alpha:(float*)alpha
{
//    if(ValidClass(color, UIColor))
    if([color respondsToSelector:@selector(getRed:green:blue:alpha:)])
    {
        [color getRed:red green:green blue:blue alpha:alpha];
    }
    else// if(ValidClass(color, UIDeviceRGBColor))
    {
        const CGFloat* components=CGColorGetComponents(color.CGColor);
        *red=components[0];
        *green=components[1]; 
        *blue=components[2];
        *alpha=CGColorGetAlpha(color.CGColor);
    }
}

-(void) loadBookMark
{
    NSString* filename=[self filePathForDocumentsName:KBookMarkFileName];
    NSDictionary* dict=[NSDictionary dictionaryWithContentsOfFile:filename];
    
    if(dict==nil || [dict count]==0)
    {
        markDict=[[NSMutableDictionary alloc] init];
    }
    else
    {
        markDict=[dict mutableDeepCopy];
    }
}
-(void) saveBookMark
{
    if(txtView==nil || !StrValid(txtView.text))
        return;
    
    float process=(txtView.contentOffset.y*txtView.text.length/(txtViewHeight-KScreenHeight)+pageindex*pageSize)/filesize;
    NSString* spro=SFF(process);
    
    if(StrValid(spro))
        [markDict setValue:spro forKey:currentFileName];
    
    NSString* filename=[self filePathForDocumentsName:KBookMarkFileName];
	[markDict writeToFile:filename atomically:YES];
}

-(void) listClick:(int)index // open a txt
{
    NSString* filename=[fileList objectAtIndex:index];
	NSString* fullname=[self filePathForFileName:filename];
    
    NSString* txt=nil;
    NSStringEncoding enc=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); // GB2312 ?
    txt=[NSString stringWithContentsOfFile:fullname encoding:enc error:nil];
    
    if(txt==nil)
    {
        txt=[NSString stringWithContentsOfFile:fullname encoding:NSUTF8StringEncoding error:nil]; // utf8 or ascii
    }
    if(txt==nil)
    {
        txt=[NSString stringWithContentsOfFile:fullname encoding:NSUTF32StringEncoding error:nil]; // NSUTF32StringEncoding
    }
    if(txt==nil)
    {
        txt=[NSString stringWithContentsOfFile:fullname encoding:NSUTF16StringEncoding error:nil]; // NSUTF16StringEncoding
    }
    
    if(txt==nil || [txt length]==0)
    {
        NSLog(@"read error or encode error: %@",fullname);
        return;
    }
    
    self.currentTxt=txt;
    self.currentFileName=filename;
    btnList.hidden=NO;
    txtView.hidden=NO;
    btnPageUp.hidden=NO;
    btnPageDown.hidden=NO;
    
    filesize=[currentTxt length];
    pagecount=(filesize+pageSize-1)/pageSize;
    
    float process=0;
    NSString* sp=[markDict objectForKey:currentFileName];
    if(sp!=nil)
        process=[sp floatValue];
    
    if(filesize>pageSize)
    {
        pageindex=(int)(process*filesize/pageSize);
        int size=(filesize-pageindex*pageSize)>pageSize ? pageSize:(filesize-pageindex*pageSize);
        txtView.text=[currentTxt substringWithRange:NSMakeRange(pageindex*pageSize,size)]; // jump to current page
        process=(process*filesize-pageindex*pageSize)/size; // jump to current page offset
        
        if(process>0.99)
        {
            [self jumpNextPage];
            process=0;
        }
    }
    else
    {
        pageindex=0;
        txtView.text=currentTxt;
    }
    
	CGSize temp = {KScreenWidth, 999999};
	CGSize txtSize = [txtView.text sizeWithFont:txtView.font constrainedToSize:temp];
    
    txtViewHeight=txtSize.height; // for fuck ios7, when scroll txtView, txtView.contentSize.height is in change
    if(txtViewHeight<KScreenHeight)
        txtViewHeight=KScreenHeight;
    
    txtView.contentOffset=CGPointMake(0, process*(txtViewHeight-KScreenHeight));
    
    pageInfoLab.text=KPageInfoTxt;
    jumpBar.hidden=NO;
    touchLeft.hidden=NO;
    touchRight.hidden=NO;
    touchCenter.hidden=NO;
}
-(void) delFile:(int)index
{
    NSString* filename=[fileList objectAtIndex:index];
	NSString* fullname=[self filePathForFileName:filename];
    
    if(FileExsit(fullname))
    {
        [self fileShouldDelete:fullname];
        
        if([markDict.allKeys containsObject:filename])
            [markDict removeObjectForKey:filename];
    }
    
//    [filename release];
//    [fullname release];
    [self saveBookMark];
}

-(void) clickBtnList
{
    if(settingBar.height!=KBarHeight)
        [self showHiddenJumpBar];
    
    btnList.hidden=YES;
    txtView.hidden=YES;
    btnPageUp.hidden=YES;
    btnPageDown.hidden=YES;
    jumpBar.hidden=YES;
    
    touchLeft.hidden=YES;
    touchRight.hidden=YES;
    touchCenter.hidden=YES;
    [self saveBookMark];
}

-(void) logFont
{
	NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
	NSArray *fontNames;
	NSInteger indFamily, indFont;
	for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
	{
		NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
		fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
		for (indFont=0; indFont<[fontNames count]; ++indFont)
		{
			NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
		}
//		[fontNames release];
	}
//	[familyNames release];
}

-(void) jumpPrewPage
{
    if(pageindex>0)
        [self jumpToPage:pageindex-1];
}
-(void) jumpNextPage
{
    if(pageindex<pagecount-1)
        [self jumpToPage:pageindex+1];
}
-(void) jumpToPage:(int)index
{
    pageindex=index;
    int size=filesize-pageindex*pageSize;
    if(size>pageSize)
        size=pageSize;
    
    txtView.text=[currentTxt substringWithRange:NSMakeRange(pageindex*pageSize,size)];
    txtView.contentOffset=CGPointMake(0, 0);
    pageInfoLab.text=KPageInfoTxt;
//    [self saveBookMark];
}
-(void) jumpUseSearch:(NSString*)key
{
    if(key==nil || key.length==0)
        return;
    
    int loc=txtView.contentOffset.y/txtViewHeight*txtView.text.length+pageindex*pageSize;
    NSString* substr=[currentTxt substringFromIndex:loc];
    NSRange range=[substr rangeOfString:key];
    
    range.location+=loc; // add offset
    if(range.location>0 && range.location<filesize)
    {
        float process=(float)range.location/filesize;
        [self jumpToPercent:process];
    }
}
-(void) jumpPrewTenPage
{
    if(pageindex>10)
        [self jumpToPage:pageindex-10];
}
-(void) jumpNextTenPage
{
    if(pageindex<pagecount-11)
        [self jumpToPage:pageindex+10];
}
-(void) doSliderJump
{
    float process=[[labPercent text] floatValue]/100;
    [self jumpToPercent:process];
}
-(void) doSearchJump
{
    [self jumpUseSearch:[inputKey text]];
}
-(void) sliderTxtPercent:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    labPercent.text=[NSString stringWithFormat:@"%2.2f",value];
}
-(void) jumpToPercent:(float)process
{
    pageindex=(int)(process*filesize/pageSize);
    txtView.text=[currentTxt substringWithRange:NSMakeRange(pageindex*pageSize,pageSize)]; // jump to current page
    process=(process*filesize-pageindex*pageSize)/txtView.text.length; // jump to current page offset
    
    if(process>0.99)
    {
        [self jumpNextPage];
    }
    
    process*=(txtViewHeight-KScreenHeight);
    txtView.contentOffset=CGPointMake(0, process);
    
    pageInfoLab.text=KPageInfoTxt;
    [self saveBookMark];
}

-(void) doJumpOtherApp
{
    [self popBlackCover];
    return;
    
    //    NSURL* url=[NSURL URLWithString:@"http://google.com"];
    //    NSURL* url=[NSURL URLWithString:@"mailto:steve@apple.com subject= test"];
    //    NSURL* url=[NSURL URLWithString:@"sms:555-1234"];
    //    NSURL* url=[NSURL URLWithString:@"tel://555-1234"];
    //    NSURL* url=[NSURL URLWithString:@"http://maps.google.com/maps?q=pizza"];
    
//    NSURL* url=[NSURL URLWithString:@"gypsiivlingdi://"];
//    [[UIApplication sharedApplication] openURL:url];
}

-(void) scrollPageUp
{
//    [self scrollTxt:-KScreenHeight+20];
    [self scrollTxt:KScreenHeight+offy];
}
-(void) scrollPageDown
{
    [self scrollTxt:KScreenHeight+offy];
}
-(void) scrollTxt:(float)offset
{
    CGPoint pt=txtView.contentOffset;
    CGSize size=txtView.contentSize;
    
    if(pt.y>=size.height-KScreenHeight+40)
    {
        [self jumpNextPage];
        return;
    }
    else if(pt.y+offset<0)
    {
        pt.y=0;
    }
    else if(pt.y+offset>=size.height-KScreenHeight/2)
    {
        pt.y=size.height-KScreenHeight/2;
    }
    else
    {
        pt.y+=offset;
    }
    
    txtView.contentOffset=pt;
}

-(void) popBlackCover
{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [[self.view buildBgView:KBlackColor frame:CGRectMake(0, offy, KScreenWidth, KScreenHeight+20)] buildBlankBtn:self action:@selector(clearBlackCover:)];
}
-(void) clearBlackCover:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UIView class]])
        return;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    [((UIView*)sender).superview removeFromSuperview];
}

-(void) touchPrewPage
{
    if(txtView.hidden)
        return;
    
    [self jumpPrewPage];
}
-(void) touchNextPage
{
    if(txtView.hidden)
        return;
    
    [self jumpNextPage];
}
-(void) doTouchCenter
{    
    if(txtView.hidden)
        return;
    
    if(settingBar.hidden)
    {
        [UIApplication sharedApplication].statusBarHidden=NO;
        settingBar.hidden=NO;
        jumpBar.hidden=NO;
        
        txtView.canMenu=YES;
        txtView.canClick=YES;
    }
    else
    {
        [UIApplication sharedApplication].statusBarHidden=YES;
        settingBar.hidden=YES;
        jumpBar.hidden=YES;
        
        txtView.canMenu=NO;
        txtView.canClick=NO;
    }
}

-(void) sliderFontChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    NSString* fontname=settingTxt.font.fontName;
    settingTxt.font=[UIFont fontWithName:fontname size:value];
}
-(void) sliderTxtColorRChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    float r,g,b,a;
    [self getColor:settingTxt.textColor red:&r green:&g blue:&b alpha:&a];
    settingTxt.textColor=Color0(value, g, b);
}
-(void) sliderTxtColorGChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    float r,g,b,a;
    [self getColor:settingTxt.textColor red:&r green:&g blue:&b alpha:&a];
    settingTxt.textColor=Color0(r, value, b);
}
-(void) sliderTxtColorBChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    float r,g,b,a;
    [self getColor:settingTxt.textColor red:&r green:&g blue:&b alpha:&a];
    settingTxt.textColor=Color0(r, g, value);
}
-(void) sliderBgColorRChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    float r,g,b,a;
    [self getColor:settingTxt.backgroundColor red:&r green:&g blue:&b alpha:&a];
    settingTxt.backgroundColor=Color0(value, g, b);
}
-(void) sliderBgColorGChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    float r,g,b,a;
    [self getColor:settingTxt.backgroundColor red:&r green:&g blue:&b alpha:&a];
    settingTxt.backgroundColor=Color0(r, value, b);
}
-(void) sliderBgColorBChange:(id)sender
{
    if(sender==nil || ![sender isKindOfClass:[UISlider class]])
        return;
    
    float value=((UISlider*)sender).value;
    float r,g,b,a;
    [self getColor:settingTxt.backgroundColor red:&r green:&g blue:&b alpha:&a];
    settingTxt.backgroundColor=Color0(r, g, value);
}

-(void) resetFont
{
    settingTxt.font=Font(20);
}
-(void) openFontPicker
{
    GPickView* pick=[[GPickView alloc] init];
    pick.delegate=self;
    pick.beDict=false;
    [self.view addSubview:pick];
//    [pick release];
    
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            [pick.array addObject:[fontNames objectAtIndex:indFont]];
        }
//        [fontNames release];
    }
    
//    [familyNames release];
    [pick buildPickView];
}

-(void) finishPick:(id)sender picked:(NSString*)str picked2:(NSString*)str2
{
    if(str!=nil)
    {
        float fontsize=settingTxt.font.pointSize;
        settingTxt.font=[UIFont fontWithName:str size:fontsize];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) showHiddenJumpBar
{
    if(settingBar.height==KBarHeight)
        settingBar.height=200;
    else
        settingBar.height=KBarHeight;
}

@end
