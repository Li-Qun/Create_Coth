//
//  UserCenterViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "UserCenterViewController.h"

@interface UserCenterViewController ()

@end

@implementation UserCenterViewController

@synthesize totalCredit     = _totalCredit;
@synthesize costCredit      = _costCredit;
@synthesize surplusCredit   = _surplusCredit;
@synthesize imageHead       = _imageHead;
@synthesize textName        = _textName;
@synthesize textLevel       = _textLevel;

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
    [self  createCollapseClick];
    
    //初始化数据
    newsArray    = [[NSMutableArray alloc] init];
    supplyArray  = [[NSMutableArray alloc] init];
    companyArray = [[NSMutableArray alloc] init];
    demandArray  = [[NSMutableArray alloc] init];
    productArray = [[NSMutableArray alloc] init];
    
    self.collapseClickView.CollapseClickDelegate = self;
    [self.collapseClickView reloadCollapseClick];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createNaviagtionBarItem];
    [self addASubView];
    
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(isUserExist) object:nil];
    [thread start];
}

#pragma  -mark custom method
- (void)logOut
{
    
}

- (void)getUserInfor
{
    
}

- (BOOL)isUserExist
{
    if([[CommonUtil getUserName] isEqualToString:@""] || [CommonUtil getUserName] == nil){
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请登录后查看信息" delegate:self cancelButtonTitle:@"返回" destructiveButtonTitle:nil otherButtonTitles:@"登录", nil];
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
        return YES;
    }else{
        [self postSomeData];
        return NO;
    }
    [thread finalize];
}

#pragma -mark uiactionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"登录"]) {
        LoginViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}


- (void)postSomeData
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:LOGIN_ACTION                  forKey:ACTION ];
    [request setPostValue:[CommonUtil getUserName]      forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]      forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]      forKey:ACCOUNT_TYPE];
    [request setPostValue:@"1"                          forKey:FOR_LOGIN];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *jsonString = [request responseString];
        SBJsonParser *parser =[[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:jsonString];
        int state = [[dictionary objectForKey:@"state"]intValue];
        if (state == 1) {
            
        }else if (state == 0) {
            //登陆失败
            LoginViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
            [self.navigationController pushViewController:view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        NSLog(@"finished");
    }];
    
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        LoginViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"failed");
    }];
    
    [request startAsynchronous];
    
}

- (void)getFavWithIndex:(NSString *)index gridView:(MyUIGridView *)gridView
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_FAVORITES            forKey:ACTION ];
    [request setPostValue:[CommonUtil getUserName]      forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]      forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]      forKey:ACCOUNT_TYPE];
    [request setPostValue:index                         forKey:CONTENT_TYPE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *jsonString = [request responseString];
        SBJsonParser *parser =[[SBJsonParser alloc] init];
        NSMutableArray *list = [parser objectWithString:jsonString];
        
        [supplyArray removeAllObjects];
        if([index isEqualToString:@"1"]){
            for (int i =0; i <list.count; i ++) {
                [supplyArray addObject:[list objectAtIndex:i]];
            }
        }
        
        [companyArray removeAllObjects];
        if([index isEqualToString:@"2"]){
            for (int i =0; i <list.count; i ++) {
                [companyArray addObject:[list objectAtIndex:i]];
            }
        }
        
        [newsArray removeAllObjects];
        if([index isEqualToString:@"3"]){
            for (int i =0; i <list.count; i ++) {
                [newsArray addObject:[list objectAtIndex:i]];
            }
        }
        
        [demandArray removeAllObjects];
        if([index isEqualToString:@"4"]){
            for (int i =0; i <list.count; i ++) {
                [demandArray addObject:[list objectAtIndex:i]];
            }
        }
        
        [productArray removeAllObjects];
        if([index isEqualToString:@"5"]){
            for (int i =0; i <list.count; i ++) {
                [productArray addObject:[list objectAtIndex:i]];
            }
        }
     [gridView reloadData];
    }];
    
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        LoginViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"failed");
    }];
    
    [request startAsynchronous];
    
}

#pragma mark - Collapse Click Delegate

// Required Methods
-(int)numberOfCellsForCollapseClick {
    return 7;
}

-(NSString *)titleForCollapseClickAtIndex:(int)index {
    array = [[NSArray alloc] initWithObjects:@"供应发布",@"求购发布",@"供应收藏",@"企业收藏",@"资讯收藏",@"求购收藏",@"商品收藏", nil];
    switch (index) {
        case 0:
            return [array objectAtIndex:0];
        case 1:
            return [array objectAtIndex:1];
        case 2:
            return [array objectAtIndex:2];
        case 3:
            return [array objectAtIndex:3];
        case 4:
            return [array objectAtIndex:4];
        case 5:
            return [array objectAtIndex:5];
        case 6:
            return [array objectAtIndex:6];
        default:
            return [array objectAtIndex:0];
    }
}

-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index {
    switch (index) {
        case 0:
            return nil;
            break;
        case 1:
            return nil;
            break;
        case 2:
            return supplyGrid;
            break;
        case 3:
            return companyGrid;
            break;
        case 4:
            return newsGrid;
            break;
        case 5:
            return demandGrid;
            break;
        case 6:
            return productGrid;
            break;
        default:
            return nil;
            break;
    }
}


// Optional Methods

-(UIColor *)colorForCollapseClickTitleViewAtIndex:(int)index {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"userinfo_expanlist_bg"]];
}


-(UIColor *)colorForTitleLabelAtIndex:(int)index {
    return [UIColor blackColor];
}

-(UIColor *)colorForTitleArrowAtIndex:(int)index {
    return [UIColor colorWithWhite:0.0 alpha:0.25];
}

-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open {
    WantPublishViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"wantPublishView"];
    switch (index) {
        case 0:
            view.index = @"0";
            [self.navigationController pushViewController:view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            view.index = @"1";
            [self.navigationController pushViewController:view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 2:
            [self getFavWithIndex:@"1" gridView:supplyGrid];
            break;
        case 3:
            [self getFavWithIndex:@"3" gridView:companyGrid];
            break;
        case 4:
            [self getFavWithIndex:@"4" gridView:newsGrid];
            break;
        case 5:
            [self getFavWithIndex:@"2" gridView:demandGrid];
            break;
        case 6:
            [self getFavWithIndex:@"5" gridView:productGrid];
            break;
        default:
            break;
    }
    
}

#pragma mark uigridview delegate
- (CGFloat) gridView:(MyUIGridView *)grid widthForColumnAt:(int)columnIndex
{
	return 80;
}

- (CGFloat) gridView:(MyUIGridView *)grid heightForRowAt:(int)rowIndex
{
	return 80;
}

- (NSInteger) numberOfColumnsOfGridView:(MyUIGridView *) grid
{
	return 4;
}


- (NSInteger) numberOfCellsOfGridView:(MyUIGridView *) grid
{
	
    if (grid == supplyGrid) {
        return supplyArray.count;
    }else if(grid == companyGrid){
        return companyArray.count;
    }else if(grid == newsGrid){
        return newsArray.count;
    }else if(grid == demandGrid){
        return demandArray.count;
    }else if(grid == productGrid){
        return productArray.count;
    }
    return 0;
}

- (MyUIGridViewCell *) gridView:(MyUIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
	Cell *cell = (Cell *)[grid dequeueReusableCell];
	
	if (cell == nil) {
		cell = [[Cell alloc] init];
	}
	
    if (grid == newsGrid) {

        NSString *imageUrl = IMAGE_TEMP([[newsArray objectAtIndex:(rowIndex*4 + columnIndex)]objectForKey:@"image_path"]);
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.thumbnail setImageURL:url];
        }
        
    }else if(grid == supplyGrid){
        
        NSString *imageUrl = IMAGE_TEMP([[supplyArray objectAtIndex:(rowIndex*4 + columnIndex)]objectForKey:@"image_path"]);
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.thumbnail setImageURL:url];
        }
        
    }else if(grid == companyGrid){
        
        NSString *imageUrl = IMAGE_TEMP([[companyArray objectAtIndex:(rowIndex*4 + columnIndex)]objectForKey:@"image_path"]);
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.thumbnail setImageURL:url];
        }
        
    }else if(grid == demandGrid){
        
        NSString *imageUrl = IMAGE_TEMP([[demandArray objectAtIndex:(rowIndex*4 + columnIndex)]objectForKey:@"image_path"]);
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.thumbnail setImageURL:url];
        }
        
    }else if(grid == productGrid){
        
        NSString *imageUrl = IMAGE_TEMP([[productArray objectAtIndex:(rowIndex*4 + columnIndex)]objectForKey:@"image_path"]);
        if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
            NSURL *url = [[NSURL alloc] initWithString:imageUrl];
            [cell.thumbnail setImageURL:url];
        }
    }

	return cell;
}

- (void) gridView:(MyUIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)colIndex
{
    ProductDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailView"];

    if (grid == newsGrid) {
        
        view.moreInfor = [newsArray objectAtIndex:(rowIndex*4 +colIndex)];
        view.contentId = @"4";
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else if(grid == supplyGrid){
        
        view.moreInfor = [supplyArray objectAtIndex:(rowIndex*4 +colIndex)];
        view.contentId = @"1";
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else if(grid == companyGrid){
        
        view.moreInfor = [companyArray objectAtIndex:(rowIndex*4 +colIndex)];
        view.contentId = @"3";
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else if(grid == demandGrid){
        
        view.moreInfor = [demandArray objectAtIndex:(rowIndex*4 +colIndex)];
        view.contentId = @"2";
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else if(grid == productGrid){
        
        view.moreInfor = [productArray objectAtIndex:(rowIndex*4 +colIndex)];
        view.contentId = @"5";
        [self.navigationController pushViewController:view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    
    }
    
}

#pragma -mark UI init
- (void)createCollapseClick
{
    newsGrid = [[MyUIGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [newsGrid setUiGridViewDelegate:self];
    [newsGrid setSeparatorColor:[UIColor clearColor]];
    
    supplyGrid = [[MyUIGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [supplyGrid setUiGridViewDelegate:self];
    [supplyGrid setSeparatorColor:[UIColor clearColor]];
    
    companyGrid = [[MyUIGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [companyGrid setUiGridViewDelegate:self];
    [companyGrid setSeparatorColor:[UIColor clearColor]];
    
    demandGrid = [[MyUIGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [demandGrid setUiGridViewDelegate:self];
    [demandGrid setSeparatorColor:[UIColor clearColor]];
    
    productGrid = [[MyUIGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [productGrid setUiGridViewDelegate:self];
    [productGrid setSeparatorColor:[UIColor clearColor]];
}

#define TEST_IMAGE_URL @"http://42.96.192.186/f/upload/2013/12/122421dda0c35aba1e92d2e45cacf3e03c0bedf3.png"

- (void)addASubView
{
    //设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //用户头像
    NSString *imageUrl = IMAGE_TEMP([CommonUtil getImagePath]);
    if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
        NSURL *url = [[NSURL alloc] initWithString:imageUrl];
        [self.imageHead setImageURL:url];
    }else{
        [self.imageHead setImage:[UIImage imageNamed:@"icon_head"]];
    }
    
////    [self.imageHead setImageURL:[[NSURL alloc] initWithString:TEST_IMAGE_URL]];
//    [self.imageHead setImage:[UIImage imageNamed:@"icon_head"]];
    
    //会员名称
    NSString *userName = [CommonUtil getUserName];
    self.textName.text = userName;
    
    //总积分
    int intTotalCredit = [[CommonUtil getTotalCredit] intValue];
    self.totalCredit.text = [NSString stringWithFormat:@"%d",intTotalCredit];
    
    //花费积分
    int intCostCredit = [[CommonUtil getCostCredit] intValue];
    self.costCredit.text = [NSString stringWithFormat:@"%d",intCostCredit];

    //剩余积分
    int  intSurplusCredit= intTotalCredit - intCostCredit;
    self.surplusCredit.text = [NSString stringWithFormat:@"%d",intSurplusCredit];
    
    //用户等级
    if (intTotalCredit >= 100) {
        self.textLevel.text = @"高级会员";
    }else{
        self.textLevel.text = @"普通会员";
    }
}

- (void)createNaviagtionBarItem
{
    [CommonUtil createNavigationItem:self text:@"会员"];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    self.tabBarController.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 50, 25);
    [rightButton setTitle:@"返回" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [rightButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    [rightItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
