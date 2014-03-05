//
//  CompanyViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-6.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "CompanyViewController.h"
#import "LoginViewController.h"

//偏移量
#define Off             200
#define TITLETAG        1000
#define TABLETAG        10000
#define BUTTONWIDTH     59
#define BUTTONGAP       5

@interface CompanyViewController ()

@end

@implementation CompanyViewController

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
    
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    //初始化数据
    selectedTag = 1000;

    titielArray = [NSArray arrayWithObjects:@"首页", @"职业制服", @"T恤文化衫", @"舞台戏服", @"特种服装",@"服装周边",nil];
    advList     = [[NSMutableArray alloc] init];
    topList     = [[NSMutableArray alloc] init];
    allList     = [[NSMutableArray alloc] init];
    broughList  = [[NSMutableArray alloc] init];
    
    [self createScrollTab];
    [self createSlideView];
    [self createClearView];
    [self registerGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createNavigationItem];
    [self setCurrentCityNumber];
}

#pragma -mark button action
- (void)setCurrentCityNumber{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_AREA_BY_NAME      forKey:ACTION];
    [request setPostValue:[CommonUtil getCity]                  forKey:AREA_NAME];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        [CommonUtil writeLocation:[dictionary objectForKey:@"id"]];
        [CommonUtil writeCity:[dictionary objectForKey:@"name"]];
        NSLog(@">>>> %@",responseString);
        [self getBroughList];
        [self getTopList];
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}



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
        [broughList removeAllObjects];
        
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
    [request setPostValue:@"3"                                 forKey:CONTENT_TYPE];
    [request setPostValue:[CommonUtil getLocation]             forKey:AREA_ID];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        [advList removeAllObjects];
         NSString *str;
        for (int i=0; i<array.count; i++) {
            NSString *type = [[array objectAtIndex:i] objectForKey:@"sticky_manufacturer_type"];
            
            if ([type isEqualToString:@"5"]) {
                str = IMAGE_TEMP([[array objectAtIndex:i] objectForKey:@"sticky_image_path"]);
                NSLog(@"image_path > %@",str);
                [advList addObject:str];
            }
            
            if ([type isEqualToString:@"4"] || [type isEqualToString:@"3"]||[type isEqualToString:@"2"]) {
                [topList addObject:[array objectAtIndex:i]];
            }
        }
        
        NSLog(@"response >>>>>%@",responseString);
        [self createBannerView];
        PullingRefreshTableView *tableview = (PullingRefreshTableView *)[self.view viewWithTag:TABLETAG];
        [allList addObjectsFromArray:topList];
        [self getList:nil tableView:tableview page:1];
       
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void) getList:(NSString *)index tableView:(PullingRefreshTableView *)tableView page:(int)page
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_MANUFACTURERS                        forKey:ACTION];
    
    if (![[CommonUtil getUserName] isEqualToString:@""] && [CommonUtil getUserName] != nil) {
        [request setPostValue:[CommonUtil getUserName]                  forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]                  forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]                  forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                                      forKey:FOR_IS_FAV];
    }
    
    if (index != nil) {
        [request setPostValue:index                                     forKey:CLOTHING_TYPE_ID];
    }
    
    [request setPostValue:[CommonUtil getLocation]                      forKey:AREA_ID];
    [request setPostValue:[NSString stringWithFormat:@"%d",page]        forKey:PAGE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSArray *array = [dictionary objectForKey:@"res"];
        totalPage = [[dictionary objectForKey:@"total_page"] intValue];
        idPage = [[dictionary objectForKey:@"current_page"]intValue];
        
        for (int i = 0; i < array.count; i++) {
            [allList addObject:[array objectAtIndex:i]];
        }
        
        [tableView reloadData];
        [tableView tableViewDidFinishedLoading];
        NSLog(@"response >>  %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        [tableView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void) getMoreCity
{
    CityViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"cityView"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
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
    [myScrollView setContentOffset:CGPointMake(320*index,0)];
    
    //请求list
    PullingRefreshTableView *tableview = (PullingRefreshTableView *)[self.view viewWithTag:index+TABLETAG];
    [allList removeAllObjects];
    [allList addObjectsFromArray:topList];
    idPage = 1;
    [tableview reloadData];
    
    if (index == 0) {
        [self getList:nil tableView:tableview page:1];
    }else{
        [self getList:[NSString stringWithFormat:@"%d",index] tableView:tableview page:1];
    }
    
    
    //设置居中
    if (sender.frame.origin.x>Off)
    {
        [scrollTab setContentOffset:CGPointMake(sender.frame.origin.x-130, 0) animated:YES];
    }
    
}

- (void)btnActionShow
{
    [self buttonSlected: (UIButton *)[scrollTab viewWithTag:TITLETAG + currentPage]];
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
//    [tableView launchRefreshing];
    tableView.reachedTheEnd = NO;
    [allList removeAllObjects];
    [tableView reloadData];
    [allList addObjectsFromArray:topList];
    idPage = 1;
    if (currentPage == 0) {
        [self getList:nil tableView:tableView page:1];
    }else{
        [self getList:[NSString stringWithFormat:@"%d",currentPage] tableView:tableView page:1];
    }
}


- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    NSLog(@"did start loading");
//    [tableView launchRefreshing];
    idPage++;
    if (idPage <= totalPage) {
        if (currentPage == 0) {
            [self getList:nil tableView:tableView page:idPage];
        }else{
            [self getList:[NSString stringWithFormat:@"%d",currentPage] tableView:tableView page:idPage];
        }
    }else if(idPage > totalPage){
//        [tableView tableViewDidFinishedLoadingWithMessage:@"没有了哦，亲"];
        tableView.reachedTheEnd  = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    PullingRefreshTableView *tableview = (PullingRefreshTableView *)[self.view viewWithTag:TABLETAG+currentPage];
    [tableview tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    PullingRefreshTableView *tableview = (PullingRefreshTableView *)[self.view viewWithTag:TABLETAG+currentPage];
    [tableview tableViewDidEndDragging:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate
-(void)registerGesture{
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [myScrollView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [myScrollView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [myScrollView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [myScrollView addGestureRecognizer:recognizer];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    //如果往左滑
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"****************向左滑****************");
    }
    //如果往右滑
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"****************向右滑****************");
    }
    if (recognizer.direction==UISwipeGestureRecognizerDirectionDown){
        NSLog(@"****************向下滑****************");
    }
    if (recognizer.direction==UISwipeGestureRecognizerDirectionUp){
        NSLog(@"****************向上滑****************");
    }
}

#pragma mark - TableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //初始化cell部分
    static NSString *cellIdentifier = @"companyCell";
    CompanyCell *cell = (CompanyCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CompanyCellNib" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    if (indexPath.row <= allList.count) {
        NSDictionary *dictionary = [allList objectAtIndex:indexPath.row];
        
        cell.title.text = [dictionary objectForKey:@"name"];
        cell.content.text = [dictionary objectForKey:@"phone"];
        cell.date.text = [dictionary objectForKey:@"address"];
        int index = [[dictionary objectForKey:@"sticky_manufacturer_type"] intValue];
        
        if (index == 2) {
            [cell.level setImage:[UIImage imageNamed:@"icon_sliver"]];
        }else if (index == 3) {
            [cell.level setImage:[UIImage imageNamed:@"icon_gold"]];
        }else if (index == 4) {
            [cell.level setImage:[UIImage imageNamed:@"icon_platinum"]];
        }else{
            [cell.level setImage:[[UIImage alloc] init]];
        }
        
        
        [cell.head setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_default"]]];
        NSString *imageUrl = [dictionary objectForKey:@"image"];
        //    NSLog(@"image url >>  %@",imageUrl);
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:COM_IMAGE(imageUrl)];
            [cell.head setImageURL:url];
        }else{
            //        [cell.head setImage:[UIImage imageNamed:@"icon_default"]];
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
    //    int index =indexPath.row;
    CompanyDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"companyDetailView"];
    view.dictionary = [allList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - UI init
- (void)createCityComboxView
{
    [titleTB removeFromSuperview];
    
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
        
        PullingRefreshTableView *tableview = (PullingRefreshTableView *)[self.view viewWithTag:TABLETAG];
        [allList removeAllObjects];
        [allList addObjectsFromArray:topList];
        [tableView reloadData];
        [self getList:nil tableView:tableview page:1];

        NSLog(@"area id >>  %@",areaId);
    }];
    [titleTB.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [titleTB.layer setBorderWidth:2];
}

- (void)createBannerView
{
    //添加最后一张图 用于循环
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:advList.count+2];
    if (advList.count > 1)
    {
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:nil image:[advList objectAtIndex:advList.count-1] tag:-1];
        [itemArray addObject:item];
    }
    for (int i = 0; i < advList.count; i++)
    {
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:nil image:[advList objectAtIndex:i] tag:i];
        [itemArray addObject:item];
        
    }
    //添加第一张图 用于循环kl
    if (advList.count >1)
    {
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:nil image:[advList objectAtIndex:0] tag:advList.count];
        [itemArray addObject:item];
    }
    
    SGFocusImageFrame *bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 60, 320, 140) delegate:self imageItems:itemArray isAuto:YES];
    [bannerView scrollToIndex:2];
    
    [self.view addSubview:bannerView];
    [self.view sendSubviewToBack:bannerView];
}

- (void)createClearView
{
    //设置背景
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建搜索栏
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 28, 320, 28)];
    mySearchBar.delegate = self;
    
    UIView *segment = [mySearchBar.subviews objectAtIndex:0];
    [segment removeFromSuperview];
    mySearchBar.backgroundColor = [UIColor yellowColor];
    // searchBar.backgroundImage = [UIImage imageNamed:@"bg_search"];
    
    searchField = [[mySearchBar subviews] lastObject];
    [searchField setReturnKeyType:UIReturnKeyDone];
    [searchField setDelegate:self];
    
    mySearchBar.barStyle = UIBarStyleBlackTranslucent;
    mySearchBar.keyboardType = UIKeyboardTypeDefault;
    mySearchBar.placeholder = @"搜索更多";
    
    //创建首行左侧菜单按钮
    submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.showsTouchWhenHighlighted = YES;
    submit.frame = CGRectMake(0, 0, 50, 26);
    [submit setBackgroundImage:[UIImage imageNamed:@"bg_btn_city"] forState:UIControlStateNormal];
    [submit setTitle:@"全部" forState: UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:11];
    [submit addTarget:self action:@selector(changeStatus) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:mySearchBar];
    [self.view addSubview:submit];
}

- (void)createScrollTab
{
   
    scrollTab = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 0, 270, 28)];
    scrollTab.contentSize = CGSizeMake(320, 26);
    scrollTab.showsHorizontalScrollIndicator = NO;
    scrollTab.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_scrollTab"]];
    
    int buttonPadding = 18;
    int xPos =10;
    for (int i=0; i<titielArray.count; i++) {
        NSString *title = [titielArray objectAtIndex:i] ;
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleButton setTitleColor:[CommonValue scrollTabTextColor] forState:UIControlStateNormal];
        [titleButton setBackgroundImage:[UIImage imageNamed:@"btn_scroll_tab"] forState:UIControlStateSelected];
        titleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        titleButton.tag = i+TITLETAG;
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
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 200, 320, self.view.frame.size.height-200-44-50)];
    myScrollView.pagingEnabled = YES;
    myScrollView.clipsToBounds = NO;
    myScrollView.contentSize = CGSizeMake(myScrollView.frame.size.width * titielArray.count, myScrollView.frame.size.height);
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.scrollsToTop = NO;
    myScrollView.delegate = self;
    myScrollView.delaysContentTouches = YES;
    [myScrollView setContentOffset:CGPointMake(0, 0)];
    
    
    //公用
    currentPage = 0;
    pageControl.numberOfPages = titielArray.count;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor whiteColor];
    
    
    
    for (int i = 0; i < titielArray.count; i++) {
        PullingRefreshTableView *table = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(320*i, 0, 320, myScrollView.frame.size.height) style:UITableViewStylePlain];
        table .separatorColor = [CommonValue purpuleColor];
        table.delegate = self;
        table.dataSource = self;
        table.pullingDelegate = self;
        table.tag = TABLETAG+i;
        
        [myScrollView addSubview:table];
    }
    
    [self.view addSubview:myScrollView];
    
}

- (void)createNavigationItem
{
    [CommonUtil createNavigationItem:self text:@"服装定制商家"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    [leftButton setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
//    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0.00, 0.00)];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location"]];
    image.frame = CGRectMake(5, 7, 9, 12);
    [leftButton addSubview:image];
    
    [leftButton setTitle:[CommonUtil getCity] forState:UIControlStateNormal];
    int buttonWidth = [[CommonUtil getCity] sizeWithFont:leftButton.titleLabel.font constrainedToSize:CGSizeMake(150, 28) lineBreakMode:NSLineBreakByClipping].width;
    leftButton.frame = CGRectMake(0, 0, buttonWidth+8, 25);
    
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [leftButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(getMoreCity) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setCustomView:leftButton];
    self.tabBarController.navigationItem.leftBarButtonItem = leftItem;
    
}
#pragma -mark - uitextfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [mySearchBar resignFirstResponder];
    SearchViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
    [self.navigationController pushViewController:view animated:YES];
    return NO;
}

#pragma -mark - uiscrollviewdelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = myScrollView.frame.size.width;
    int page = floor((myScrollView.contentOffset.x - pageWidth / titielArray.count) / pageWidth) + 1;
    NSLog(@"page is %d",page);
    pageControl.currentPage = page;
    currentPage = page;
    [self btnActionShow];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
