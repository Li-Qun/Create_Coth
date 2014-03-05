//
//  SearchViewController.m
//  Cloth
//
//  Created by ss4346 on 13-10-10.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

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
    allList = [[NSMutableArray alloc] init];
    currentPage = 1;
    totalPage = 0;
    
    //初始化界面
	[self createClearView];
    [self createNavigationbarItem];
}
#pragma mark - custom method
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getList:(NSString *)keyward page:(NSString *)index
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_MANUFACTURERS         forKey:ACTION];
    
    if (![[CommonUtil getUserName] isEqualToString:@""]) {
        [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                             forKey:FOR_IS_FAV];
    }
    [request setPostValue:keyward                       forKey:KEYWORD];
    [request setPostValue:index                         forKey:PAGE];
    
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSArray *array = [dictionary objectForKey:@"res"];
        totalPage = [[dictionary objectForKey:@"total_page"] intValue];
        currentPage = [[dictionary objectForKey:@"current_page"]intValue];
        if (array.count == 0) {
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有结果"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }
        if ([index isEqualToString:@"1"]) {
            
        }
        
        
        for (int i = 0; i < array.count; i++) {
            [allList addObject:[array objectAtIndex:i]];
        }
        
        [myTableView tableViewDidFinishedLoading];
        myTableView.reachedTheEnd  = NO;
        [myTableView reloadData];
        NSLog(@"response >>  %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [myTableView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    NSLog(@"did start refreshing");
    [allList removeAllObjects];
    [myTableView reloadData];
    tableView.reachedTheEnd  = NO;
    [myTableView launchRefreshing];
    currentPage =1;
    [self getList:searchField.text page:@"1"];
    
}


- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    NSLog(@"did start loading");
    [myTableView launchRefreshing];
    currentPage++;
    if (currentPage <= totalPage) {
        [self getList:searchField.text page:[NSString stringWithFormat:@"%d",currentPage]];
         tableView.reachedTheEnd  = NO;
    }else if(currentPage > totalPage){
        [tableView tableViewDidFinishedLoadingWithMessage:@"没有了哦，亲"];
         tableView.reachedTheEnd  = YES;
    }
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [myTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [myTableView tableViewDidEndDragging:scrollView];
}

#pragma mark -tableview datasource delegate
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
    
    NSDictionary *dictionary = [allList objectAtIndex:indexPath.row];
    
    cell.title.text = [dictionary objectForKey:@"name"];
    cell.content.text = [dictionary objectForKey:@"phone"];
    cell.date.text = [dictionary objectForKey:@"address"];
    [cell.head setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_default"]]];
    NSString *imageUrl = [dictionary objectForKey:@"image"];
 
    if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
        NSURL *url = [[NSURL alloc] initWithString:COM_IMAGE(imageUrl)];
        [cell.head setImageURL:url];
    }else{
        [cell.head setImage:[UIImage imageNamed:@"icon_default"]];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CompanyDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"companyDetailView"];
    view.dictionary = [allList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - uiscrollviewdelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [allList removeAllObjects];
    [myTableView reloadData];
    [self getList:searchField.text page:@"1"];
    
    return YES;
}

#pragma mark - ui init
- (void)createNavigationbarItem
{
    self.navigationItem.title = @"搜索";
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
}

- (void)createClearView
{
    //设置背景
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建搜索栏
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    searchView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"searchbar"]];

    searchField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 315, 30)];
    searchField.backgroundColor = [UIColor clearColor];
    searchField.delegate = self;
    searchField.placeholder = @"搜索更多";
    
    myTableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 35, 320, self.view.frame.size.height - 80) pullingDelegate:self];
    [myTableView setSeparatorColor:[CommonValue purpuleColor]];
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    
    [self.view addSubview:searchField];
    [self.view addSubview:myTableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
