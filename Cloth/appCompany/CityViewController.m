//
//  CityViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-27.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//
#import "CityViewController.h"

@interface CityViewController ()

@end

@implementation CityViewController

@synthesize isOpen,selectIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createNavigationItem];
    [self addSubView];
    
    provinceList = [[NSMutableArray alloc] init];
    cityList     = [[NSMutableArray alloc] init];
    
    [self getProvince];
    
    [cityLabel setTitle:[CommonUtil getCity] forState:UIControlStateNormal];
    
}


#pragma -mark ui init
- (void)addSubView
{
    UIView *view1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view1 setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    
    UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 320, 30)];
    [currentLabel setText:@"当前城市"];
    [currentLabel setBackgroundColor:[UIColor clearColor]];
    currentLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [currentLabel setTextColor:[UIColor blackColor]];
    [view1 addSubview:currentLabel];
    
    cityLabel  = [UIButton buttonWithType:UIButtonTypeCustom];
    cityLabel.frame = CGRectMake(0, 30, 320, 30);
    [cityLabel setTitle:[CommonUtil getCity] forState:UIControlStateNormal];
    [cityLabel setTitleColor:[CommonValue purpuleColor] forState:UIControlStateNormal];
    cityLabel.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [cityLabel addTarget:self action:@selector(setCurrentCity) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 30)];
    [view2 setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    
    UILabel *listLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 320, 30)];
    [listLabel setText:@"城市列表"];
    [listLabel setBackgroundColor:[UIColor clearColor]];
    [listLabel setTextColor:[UIColor blackColor]];
    listLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [view2 addSubview:listLabel];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 320, self.view.frame.size.height -44 -90) style:UITableViewStylePlain];
    myTableView.sectionFooterHeight = 0;
    myTableView.sectionHeaderHeight = 0;
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    self.isOpen = NO;
    
    [self.view addSubview:view1];
    [self.view addSubview:cityLabel];
    [self.view addSubview:view2];
    [self.view addSubview:myTableView];
}

- (void)createNavigationItem{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 50, 25);
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [leftButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.title = @"当前城市";
}

#pragma mark custom method
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getProvince{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"pro" ofType: @"txt"];
    NSString *content = [NSString stringWithContentsOfFile:myFile encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"content >>>   %@",content);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray * array = [parser objectWithString:content];
    for (int i = 0; i < array.count; i++) {
        [provinceList addObject:[array objectAtIndex:i]];
    }
    
}

- (void)getCityWithId:(int) indexs{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_AREA_BY_PID                                  forKey:ACTION];
    [request setPostValue:[NSString stringWithFormat:@"%d",indexs]         forKey:PID];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        [cityList removeAllObjects];
        for (int i = 0; i < array.count; i++) {
            [cityList addObject:[array objectAtIndex:i]];
            [myTableView reloadData];
        }
        
        NSLog(@">>>> %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)setCurrentCity{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_AREA_BY_NAME                 forKey:ACTION];
    [request setPostValue:cityLabel.titleLabel.text        forKey:AREA_NAME];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        [CommonUtil writeLocation:[dictionary objectForKey:@"id"]];
        [CommonUtil writeCity:[dictionary objectForKey:@"name"]];
        NSLog(@">>>> %@",responseString);
        [self backAction];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [provinceList count] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return [cityList count]+1;
        }
    }
    return 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
        static NSString *CellIdentifier = @"Cell2";
        Cell2 *cell = (Cell2*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        }
        cell.titleLabel.text = [[cityList objectAtIndex:indexPath.row-1] objectForKey:@"name"];
//        cell.titleLabel.text = @"test...";
        return cell;
    }else
    {
        static NSString *CellIdentifier = @"Cell1";
        Cell1 *cell = (Cell1*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        }
        NSString *name = [[provinceList objectAtIndex:indexPath.section] objectForKey:@"name"];
        cell.titleLabel.text = name;
        [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];
        return cell;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"current indexpath section >> %d",indexPath.section);
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
            
        }else
        {
            if (!self.selectIndex) {
                [self getCityWithId:[[[provinceList objectAtIndex:indexPath.section] objectForKey:@"id"]intValue ]];
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
                
            }else
            {
                [self getCityWithId:[[[provinceList objectAtIndex:indexPath.section] objectForKey:@"id"]intValue ]];
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
        
    }else
    {
        NSString *item = [[cityList objectAtIndex:indexPath.row-1] objectForKey:@"name"];
        [CommonUtil writeLocation:[[cityList objectAtIndex:indexPath.row-1] objectForKey:@"id"]];
        [CommonUtil writeCity:item];
        [self backAction];
        NSLog(@"COMMONUTIL LOCTATION :%@   CITY>>>>  %@",[CommonUtil getLocation],[CommonUtil getCity]);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert{
    self.isOpen = firstDoInsert;
    
    Cell1 *cell = (Cell1 *)[myTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [myTableView beginUpdates];
    
    int section = self.selectIndex.section;
    int contentCount = [cityList count];
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
    {   [myTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [myTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	
	[myTableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [myTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen) [myTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
