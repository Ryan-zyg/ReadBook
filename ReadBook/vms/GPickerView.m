
#import <QuartzCore/QuartzCore.h>
#import "GPickerView.h"

@implementation GPickView
@synthesize delegate,beDict,array,dict;

-(id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        array=[[NSMutableArray alloc] initWithCapacity:5];
        dict=[[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

-(void) buildTestData
{
    [array removeAllObjects];
    [dict removeAllObjects];
    
//    beDict=false;
//    [array addObject:@"list-1"];
//    [array addObject:@"list-2"];
//    [array addObject:@"list-3"];
    
    beDict=true;
    NSArray* a1=[NSArray arrayWithObjects:@"a1-1",@"a1-2",@"a1-3",@"a1-4", nil];
    NSArray* a2=[NSArray arrayWithObjects:@"a2-1",@"a2-2",@"a2-3", nil];
    [dict setObject:a1 forKey:@"a1"];
    [dict setObject:a2 forKey:@"a2"];
    [array addObject:@"a1"];
    [array addObject:@"a2"];
}

-(void) buildPickView
{
//    if(IsPad)
//        pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 345, 400, 216)];
//    else
        pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    pick.delegate = self;
    pick.dataSource = self;
    pick.autoresizingMask = UIViewAutoresizingFlexibleWidth; // 20120709 add
    pick.showsSelectionIndicator = YES;
    [pick reloadComponent:0];	
    [pick selectRow:0 inComponent:0 animated:YES];
    
    UIActionSheet* sheet=[[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil 
                                            otherButtonTitles:@"Ok",nil];
    [sheet addSubview:pick];
//    [pick release];
    [sheet showInView:self];
//    [sheet showInView:self.window];
//    [sheet release];
}

// UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(beDict)
        return 2;
    
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(beDict)
    {
        if(component==0)
            return [array count];
        
        int index=[pickerView selectedRowInComponent:0];
        return [[dict objectForKey:[array objectAtIndex:index]] count];
    }
    
    return [array count];
}

// UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(beDict)
        return 140;
    
	return 260.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(beDict)
    {
        if(component==0)
        {
            return [array objectAtIndex:row];
        }
        else if(component==1)
        {
            int index=[pickerView selectedRowInComponent:0];
            return [[dict objectForKey:[array objectAtIndex:index]] objectAtIndex:row];
        }
    }
    
	return [array objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(!beDict)
		return;
	
    if (component==0)
    {
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView reloadComponent:1];
    }
    else if (component==1)
    {
        [pickerView reloadComponent:1];
    }
}

// UIActionSheetDelegate
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [delegate finishPick:self picked:nil picked2:nil];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    int row=[pick selectedRowInComponent:0];
    
	if(delegate==nil)
		return;
	
    if(buttonIndex==0)
    {
        if(!beDict)
            [delegate finishPick:self picked:[array objectAtIndex:row] picked2:nil];
        else
        {
            int index=[pick selectedRowInComponent:1];
            [delegate finishPick:self 
                          picked:[array objectAtIndex:row] 
                         picked2:[[dict objectForKey:[array objectAtIndex:row]] objectAtIndex:index]];
        }
    }
    else
        [self actionSheetCancel:actionSheet];
}

-(void) dealloc
{
    [array removeAllObjects];
//    [array release];
    
    [dict removeAllObjects];
//    [dict release];
//    
//    [super dealloc];
}

@end
