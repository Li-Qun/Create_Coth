//
//  SupplyDemandViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-14.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "SupplyDemandViewController.h"

//偏移量
#define Off             200
#define TITLETAG        1000
#define TABLETAG        10000
#define BUTTONWIDTH     59
#define BUTTONGAP       5

@interface SupplyDemandViewController ()

@end

@implementation SupplyDemandViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化数据
    selectedTag = 1000;
    titielArray = [NSArray arrayWithObjects:@"首页", @"职业制服", @"T恤文化衫", @"舞台戏服", @"特种服装",@"服装周边",nil];
    totalList   = [[NSMutableArray alloc] init];
    topList     = [[NSMutableArray alloc] init];
    broughList  = [[NSMutableArray alloc] init];
    
    supplyDemandTag = 1;

    [self createScrollTab];
    [self createClearView];
    [self createSlideView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createNavigationBarItem];
    [self getTopList];
    [self getBroughList];
}

#pragma -mark button action
- (void)getBroughList
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_AREA_BY_PID                                  forKey:ACTION];
    [request setPostValue:[CommonUtil getLocation]                         forKey:PID];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        
        for (int i = 0; i < array.count; i++) {
            [broughList addObject:[array objectAtIndex:i]];
        }
        NSLog(@">>>>>%@",[CommonUtil getLocation]);
        [self createCityComboxView];
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void) getTopList
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    NSString *tag = [NSString stringWithFormat:@"%d",supplyDemandTag];
    NSLog(@">>>>>>>>  %@",tag);
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_STICKIES         forKey:ACTION];
    
    if (![[CommonUtil getUserName] isEqualToString:@""] && [CommonUtil getUserName] != nil) {
        [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                             forKey:FOR_IS_FAV];
    }
    [request setPostValue:tag                                  forKey:CONTENT_TYPE];
    [request setPostValue:[CommonUtil getLocation]             forKey:AREA_ID];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        [topList removeAllObjects];

        for (int i=0; i<array.count; i++) {
            [topList addObject: [array objectAtIndex:i]];
        }
        
        NSLog(@"response >>>>>%@",responseString);
        

        [totalList removeAllObjects];
        [totalList addObjectsFromArray:topList];
        [myTableView reloadData];
        [self getList:myTableView  index:nil page:1];
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
    
}

- (void) getList:(PullingRefreshTableView *)tableView index:(NSString *)index page:(int)page
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    NSString *tag = [NSString stringWithFormat:@"%d",supplyDemandTag];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_TRADES                               forKey:ACTION];
    
    if (![[CommonUtil getUserName] isEqualToString:@""] && [CommonUtil getUserName] != nil) {
        [request setPostValue:[CommonUtil getUserName]                  forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]                  forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]                  forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                                      forKey:FOR_IS_FAV];
    }
    
    if (index != nil) {
        [request setPostValue:index                                     forKey:CLOTHING_TYPE_ID];
    }
    
    [request setPostValue:@"324"                                        forKey:AREA_ID];
    [request setPostValue:tag                                           forKey:TRADE_TYPE];
    [request setPostValue:@"1"                                          forKey:RETRIEVE_TYPE];
    [request setPostValue:[NSString stringWithFormat:@"%d",page]        forKey:PAGE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        [tableView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        NSLog(@"response>>>> %@",responseString);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSArray *array = [dictionary objectForKey:@"res"];
        totalPage = [[dictionary objectForKey:@"total_page"] intValue];
        idPage = [[dictionary objectForKey:@"current_page"]intValue];
        
        for (int i =0 ; i < array.count; i++) {
            [totalList addObject:[array objectAtIndex:i]];
        }
        [tableView reloadData];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        [tableView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}


- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
}

- (void)supplyAction
{
    titleButton2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_sd_normal"]];
    titleButton1.backgroundColor = [UIColor clearColor];
    NSLog(@"supply aciton");
    supplyDemandTag = 1;
    [self btnActionShow];
    [self getTopList];
}

- (void)demandAction
{
    titleButton1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_sd_normal"]];
    titleButton2.backgroundColor = [UIColor clearColor];
    NSLog(@"demand Action");
    supplyDemandTag = 2;
    [self btnActionShow];
    [self getTopList];
}

- (void)btnActionShow
{
    [self buttonSlected: (UIButton *)[scrollTab viewWithTag:TITLETAG + currentPage]];
}

- (void)buttonSlected:(UIButton *)sender
{
    if(sender.tag != selectedTag)
    {
        UIButton *button = (UIButton *)[scrollTab viewWithTag:selectedTag];
        button.selected = NO;
        selectedTag = sender.tag;
    }
    sender.selected = YES;
    
    float x = scrollTab.contentOffset.x;
    [scrollTab setContentOffset:CGPointMake(x, 0)];
    
    if(sender.tag == 1003 || sender.tag == 1002){
        [scrollTab setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    int index = sender.tag -1000;
    currentPage = index;

    [totalList removeAllObjects];
    [totalList addObjectsFromArray:topList];
    [myTableView reloadData];
    if (index == 0) {
        [self getList:myTableView  index:nil page:1];
    }else{
        [self getList:myTableView  index:[NSString stringWithFormat:@"%d",index ] page:1];
    }
    

    //设置居中
    if (sender.frame.origin.x>Off)
    {
        [scrollTab setContentOffset:CGPointMake(sender.frame.origin.x-130, 0) animated:YES];
    }
    
}

- (void)changeStatus {
    
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=titleTB.frame;
            frame.size.height=1;
            [titleTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=titleTB.frame;
            frame.size.height=200;
            [titleTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
    
}


#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    NSLog(@"did start refreshing");
    tableView.reachedTheEnd = NO;
    [totalList removeAllObjects];
    [totalList addObjectsFromArray:topList];
    [tableView reloadData];
    idPage = 1;
    if (currentPage == 0) {
        [self getList:tableView index:nil page:idPage];
    }else{
        [self getList:tableView index:[NSString stringWithFormat:@"%d",currentPage] page:idPage];
    }
}


- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    NSLog(@"did start loading");
    [tableView launchRefreshing];
    idPage++;
    if (idPage <= totalPage) {
        if (currentPage == 0) {
            [self getList:tableView index:nil page:idPage];
        }else{
            [self getList:tableView index:[NSString stringWithFormat:@"%d",currentPage]  page:idPage];
        }
    }else if(idPage > totalPage){
//        [tableView tableViewDidFinishedLoadingWithMessage:@"没有了哦，亲"];
        tableView.reachedTheEnd  = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [myTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [myTableView tableViewDidEndDragging:scrollView];
}


#pragma -mark tableview deletate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return totalList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"supplyDemandCell";
    
    SupplayDemandCell *cell = (SupplayDemandCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SupplyDemandCellNib" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (indexPath.row < totalList.count) {
        NSDictionary *dictionary = [totalList objectAtIndex:indexPath.row];
        //设置标题
        cell.labelTitle.text     = [dictionary objectForKey:@"title"];
        //设置价格
        cell.labelPrice.text     = [dictionary objectForKey:@"price"];
        //设置收藏
        cell.labelFavorate.text = [dictionary objectForKey:@"fav_count"];
        //设置内容
        cell.labelContent.text  = [dictionary objectForKey:@"description"];
        //设置头像
        NSString *path = [dictionary objectForKey:@"image_path"];
        if (path != nil &&(![path isEqualToString:@""])) {
            NSString *imageUrl = IMAGE_TEMP(path);
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.imageHead setImageURL:url];
        }else{
            [cell.imageHead setImage:[UIImage imageNamed:@"icon_default"]];
        }
        
    }
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailView"];
    view.moreInfor = [totalList objectAtIndex:indexPath.row];
    view.contentId = @"2";
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return  indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma -mark UI init
- (void)createCityComboxView
{
    titleTB = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(0, 26, 50, 1)];
    [self.view addSubview:titleTB];
    isOpened=NO;
    
    [titleTB initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        int count = broughList.count+1;
        return count;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        
        if (indexPath.row == broughList.count) {
            [cell.lb setText:@"全部"];
        }else{
            [cell.lb setText:[[broughList objectAtIndex:indexPath.row] objectForKey:@"name"]];
        }
        
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [submit setTitle:cell.lb.text forState:UIControlStateNormal];
        [submit sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        if (indexPath.row == broughList.count) {
            areaId = [CommonUtil getLocation];
        }else{
            areaId = [[broughList objectAtIndex:indexPath.row] objectForKey:@"id"];
        }
        

        [totalList removeAllObjects];
        [totalList addObjectsFromArray:topList];
        [myTableView reloadData];
        [self getList:myTableView  index:nil page:1];
        
        NSLog(@"area id >>  %@",areaId);
    }];

    [titleTB.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [titleTB.layer setBorderWidth:2];
}



- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //点击空处，取消键盘
    [mySearchBar resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}


- (void)createNavigationBarItem
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 30)];
    
    titleButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton1.frame = CGRectMake(0, 0, 85, 30);
    [titleButton1 setTitle:@"供应" forState:UIControlStateNormal];
    [titleButton1 addTarget:self action:@selector(supplyAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titleButton1];
    [self supplyAction];
    
    titleButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton2.frame = CGRectMake(85, 0, 85, 30);
    [titleButton2 setTitle:@"求购" forState:UIControlStateNormal];
    titleButton2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_sd_normal"]];
    [titleButton2 addTarget:self action:@selector(demandAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titleButton2];
    
    titleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_sd_selected"]];
    self.tabBarController.navigationItem.titleView = titleView;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    self.tabBarController.navigationItem.leftBarButtonItem = leftItem;
}

- (void)createClearView
{
    //创建首行左侧菜单按钮
    submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.showsTouchWhenHighlighted = YES;
    submit.frame = CGRectMake(0, 0, 50, 26);
    [submit setBackgroundImage:[UIImage imageNamed:@"bg_btn_city"] forState:UIControlStateNormal];
    [submit setTitle:@"全城" forState: UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:14];
    [submit addTarget:self action:@selector(changeStatus) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:submit];

}

- (void)createScrollTab
{
    scrollTab = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 0, 280, 26)];
    scrollTab.contentSize = CGSizeMake((BUTTONWIDTH+BUTTONGAP)*[titielArray count]+BUTTONGAP, 26);
    scrollTab.showsHorizontalScrollIndicator = NO;
    scrollTab.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_scrollTab"]];
    
    int buttonPadding = 18;
    int xPos =10;
    for (int i=0; i<titielArray.count; i++) {
        NSString *title = [titielArray objectAtIndex:i] ;
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleButton setBackgroundImage:[UIImage imageNamed:@"btn_scroll_tab"] forState:UIControlStateSelected];
        [titleButton setTitleColor:[CommonValue scrollTabTextColor] forState:UIControlStateNormal];
        titleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        titleButton.tag = i+1000;
        int buttonWidth = [title sizeWithFont:titleButton.titleLabel.font constrainedToSize:CGSizeMake(150, 28) lineBreakMode:NSLineBreakByClipping].width;
        titleButton.frame = CGRectMake(xPos, 0, buttonWidth+buttonPadding, 26);
        [titleButton setTitle:title forState:UIControlStateNormal];
        [titleButton addTarget:self action:@selector(buttonSlected:) forControlEvents:UIControlEventTouchUpInside];
        
        if(i ==0){
            titleButton.selected = YES;
            selectedTag = i+1000;
        }
        
        xPos += buttonWidth+buttonPadding;
        [scrollTab addSubview:titleButton];
        
    }
   
    [self.view addSubview:scrollTab];
}

- (void)createSlideView
{
    int height = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height -85;
    myTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 26, 320, height-26) style:UITableViewStylePlain];
    myTableView.separatorColor = [CommonValue purpuleColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.pullingDelegate = self;
    
    [self.view addSubview:myTableView];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
