//
//  NewsViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-12.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "NewsViewController.h"

#define Off             300
#define TITLETAG        1000
#define TABLETAG        10000
#define BUTTONWIDTH     59
#define BUTTONGAP       5

@interface NewsViewController ()

@end

@implementation NewsViewController

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
    titielArray = [[NSMutableArray alloc] init];

    newsList = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated
{
    [newsList removeAllObjects];
    [titielArray removeAllObjects];
    [newsList removeAllObjects];
    
    [self createNaviagtionBarItem];
    [rootView removeFromSuperview];
    [self getTitleArray]; 
}

#pragma -mark custom method
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
    [request setPostValue:@"4"                                 forKey:CONTENT_TYPE];
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
        
        [newsList removeAllObjects];
        [newsList addObjectsFromArray:topList];
        [mainTableView reloadData];
        [self getList:nil tableView:mainTableView page:1];
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
    
}

- (void)getTitleArray
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:GENERATE_CONST_INFORMATION         forKey:ACTION];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        
        [titielArray removeAllObjects];
        [titielArray addObject:@"首页"];
        for (int i = 0; i < array.count; i ++) {
            [titielArray addObject:[[array objectAtIndex:i] objectForKey:@"name"]];
        }
        
        [self createScrollTab];
        [self createSlideView];
        
        [self getTopList];

    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}


- (void) getList:(NSString *)type tableView:(PullingRefreshTableView *)tableView page:(int) page
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_INFORMATIONS                         forKey:ACTION];
    
    if (![[CommonUtil getUserName] isEqualToString:@""] && [CommonUtil getUserName] != nil) {
        [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                             forKey:FOR_IS_FAV];
    }
    
    if (type != nil) {
        [request setPostValue:type                             forKey:INFORMATION_TYPE_ID];
    }
    
    [request setPostValue:[NSString stringWithFormat:@"%d",page]         forKey:PAGE];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        [tableView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSArray *array = [dictionary objectForKey:@"res"];
        totalPage = [[dictionary objectForKey:@"total_page"] intValue];
        idPage = [[dictionary objectForKey:@"current_page"]intValue];
        
        [newsList removeAllObjects];
        for (int i =0; i < array.count; i++) {
            [newsList addObject:[array objectAtIndex:i]];
        }
        NSLog(@"response string >>>>>> %@",newsList);
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
    
    int index = sender.tag -1000;
    currentPage = index;
    [self getList:[NSString stringWithFormat:@"%d",index] tableView:mainTableView page:1];
    
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

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    NSLog(@"did start refreshing");
    tableView.reachedTheEnd = NO;
    [newsList removeAllObjects];
    [tableView reloadData];
    NSLog(@"top list >>>>   %@",topList);
    [newsList addObjectsFromArray:topList];
    idPage = 1;
    if (currentPage == 0) {
        [self getList:nil tableView:tableView page:1];
    }else{
        [self getList:[NSString stringWithFormat:@"%d",currentPage] tableView:tableView page:1];
    }
}


- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    NSLog(@"did start loading");
    idPage++;
    if (idPage <= totalPage) {
        if (currentPage == 0) {
            [self getList:nil tableView:tableView page:idPage];
        }else{
            [self getList:[NSString stringWithFormat:@"%d",currentPage] tableView:tableView page:idPage];
        }
    }else if(idPage > totalPage){
        [tableView tableViewDidFinishedLoadingWithMessage:@"没有了哦，亲"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [mainTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [mainTableView tableViewDidEndDragging:scrollView];
}


#pragma mark - tableview datasource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"newsCell";
    
    NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewsNib" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (indexPath.row < newsList.count) {
        NSDictionary *dictionary = [newsList objectAtIndex:indexPath.row];
        cell.title.text = [dictionary objectForKey:@"title"];
        cell.date.text  = [dictionary objectForKey:@"date_updated"];
        
        NSString *imageUrl = [dictionary objectForKey:@"image_path"];
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.head setImageURL:url];
        }else{
            [cell.head setImage:[UIImage imageNamed:@"icon_default"]];
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
    NewsDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"newsDetailView"];
    view.informationID = [[newsList objectAtIndex:indexPath.row] objectForKey:@"information_id"];
    view.strTitle = [[newsList objectAtIndex:indexPath.row] objectForKey:@"title"];
    view.strDate  = [[newsList objectAtIndex:indexPath.row] objectForKey:@"date_updated"];
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

#pragma -mark UI init
/**
 *创建滑动标题
 */
- (void)createScrollTab
{
    rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 40)];
    
    scrollTab = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)];
    scrollTab.contentSize = CGSizeMake((BUTTONWIDTH+BUTTONGAP)*[titielArray count]+BUTTONGAP, 26);
    scrollTab.showsHorizontalScrollIndicator = NO;
    scrollTab.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_scrollTab"]];
    
    int buttonPadding = 18;
    int xPos =2;
    for (int i=0; i<titielArray.count; i++) {
        NSString *title = [titielArray objectAtIndex:i] ;
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleButton setTitleColor:[CommonValue scrollTabTextColor] forState:UIControlStateNormal];
        [titleButton setBackgroundImage:[UIImage imageNamed:@"btn_scroll_tab"] forState:UIControlStateSelected];
        titleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
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
    [rootView addSubview:scrollTab];
}

/**
 *创建滑动列表
 */
- (void)createSlideView
{
    
    //公用
    currentPage = 0;
    mainTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 26, 320, self.view.frame.size.height)];
    mainTableView .separatorColor = [CommonValue purpuleColor];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.pullingDelegate = self;
    
    [rootView addSubview:mainTableView];
    [self.view addSubview:rootView];
}

/**
 *创建导航栏内容
 */
- (void)createNaviagtionBarItem
{
    [CommonUtil createNavigationItem:self text:@"资讯"];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    self.tabBarController.navigationItem.leftBarButtonItem = leftItem;
}

@end
