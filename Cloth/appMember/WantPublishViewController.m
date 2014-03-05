//
//  WantPublishViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-10.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "WantPublishViewController.h"

@interface WantPublishViewController ()
{
    UILabel * label;
    
}
@end

@implementation WantPublishViewController

@synthesize didPublish = _didPublish;
@synthesize doPublish  = _doPublish;
@synthesize scrollView = _scrollView;
@synthesize index      = _index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    [self createNavigationItem];
    [self addBasicView];
    [self initScrollView];
    
    //初始化数据
    tempImagePath = [ NSTemporaryDirectory() stringByAppendingPathComponent:@"temp_image.png"];
    totalList    = [[NSMutableArray alloc] init];
    provinceList = [[NSMutableArray alloc] init];
    cityList     = [[NSMutableArray alloc] init];
    broughList   = [[NSMutableArray alloc] init];
    titielArray  = [[NSMutableArray alloc] init];
    
    [CommonUtil clearTemp:tempImagePath];
    [self getProvince];
}

- (void)viewWillAppear:(BOOL)animated{
    [totalList removeAllObjects];
    [doPublishView reloadData];
    [self getListwithPage:1];
    isChange = NO;
}

#pragma -mark custom method
- (void)getPid{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_AREA_BY_NAME                                          forKey:ACTION ];
    
    //判断是否选择了一个城市
        
    [request startAsynchronous];
}

- (void)addInfo{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    
    if (broughId ==nil || [broughId isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请选择区域"];
        return;
    }
    [SVProgressHUD show];
    
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    
    if (isChange) {
        [request setPostValue:UPDATE_TRADE                      forKey:ACTION];
        [request setPostValue:[tradeCell objectForKey:@"id"]    forKey:TRADE_ID];
    }else{
        [request setPostValue:ADD_TRADE                         forKey:ACTION];
        if ([self.index isEqualToString:@"0"]) {
            [request setPostValue:SUPPLYPUBLISH                 forKey:TRADE_TYPE];
        }else{
            [request setPostValue:WANTPUBLISH                   forKey:TRADE_TYPE];
        }
    }
    
    [request setPostValue:[CommonUtil getUserName]      forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]      forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]      forKey:ACCOUNT_TYPE];
    [request setPostValue:broughId                      forKey:AREA_ID];
    [request setPostValue:type                          forKey:CLOTHING_TYPE_ID];
    
    if ([tfPrice.text isEqualToString:@""]|| tfPrice.text == nil || [tfPrice.text isEqualToString:@"0"]) {
        [tfPrice setText:@"面议"];
        [request setPostValue:@"面议"                    forKey:PRICE];
    }else{
        [request setPostValue:tfPrice.text               forKey:PRICE];
    }
    
    [request setPostValue:tfTitle.text                  forKey:TITLE];
    [request setPostValue:tfOther.text                  forKey:DESCRIPTION];
    [request setPostValue:tfPhone.text                  forKey:TELEPHONE];
   
    //如果缓存图片不存在，不发送file
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempImagePath]) {
        [request setFile:tempImagePath                      forKey:LOCAL_FILE];
    }else{
        //图片不存在
        [SVProgressHUD showErrorWithStatus:@"请选择一张图片"];
        return;
    }
    [request startAsynchronous];
}

- (void)toTop{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:ADD_STICKY                        forKey:ACTION];
    [request setPostValue:[CommonUtil getUserName]          forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]          forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]          forKey:ACCOUNT_TYPE];
    [request setPostValue:[[totalList objectAtIndex:doPublishView.indexPathForSelectedRow.row] objectForKey:@"id"]    forKey:CONTENT_ID];
    
    //设置时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString        *dateString;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    dateString = [formatter stringFromDate:[NSDate date]];
    [request setPostValue:dateString                        forKey:START_DATE];
    [request setPostValue:dateString                        forKey:END_DATE];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@"response >>> %@",responseString);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSString *state = [dictionary objectForKey:@"state"];
        if (((![state isKindOfClass:[NSNull class]]) && state != nil)) {
            NSString *message = [dictionary objectForKey:@"message"];
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:message  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }

        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

//预约置顶
- (void)orderTop{

    DateViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"dateView"];
    view.index = self.index;
    view.tradeCell = [totalList objectAtIndex:doPublishView.indexPathForSelectedRow.row];
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)deleteInfor{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:DELETE_TRADE                      forKey:ACTION];
    [request setPostValue:[CommonUtil getUserName]          forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]          forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]          forKey:ACCOUNT_TYPE];
    [request setPostValue:[[totalList objectAtIndex:doPublishView.indexPathForSelectedRow.row] objectForKey:@"id"]    forKey:TRADE_ID];
    
    //设置时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString        *dateString;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    dateString = [formatter stringFromDate:[NSDate date]];
    [request setPostValue:dateString                        forKey:START_DATE];
    [request setPostValue:dateString                        forKey:END_DATE];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@"response >>> %@",responseString);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSString *state = [dictionary objectForKey:@"state"];
        if (((![state isKindOfClass:[NSNull class]]) && state != nil)) {
            NSString *message = [dictionary objectForKey:@"message"];
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:message  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }
        //刷新
        doPublishView.reachedTheEnd = NO;
        [totalList removeAllObjects];
        [doPublishView reloadData];
        idPage = 1;
        [self getListwithPage:idPage];
        
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

//删除置顶
- (void)deleteTop{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:DELETE_STICKY                      forKey:ACTION];
    [request setPostValue:[CommonUtil getUserName]          forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]          forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]          forKey:ACCOUNT_TYPE];
    
    if ([self.index isEqualToString:@"0"]) {
        [request setPostValue:SUPPLYPUBLISH                 forKey:CONTENT_TYPE];
    }else{
        [request setPostValue:WANTPUBLISH                   forKey:CONTENT_TYPE];
    }
    
    [request setPostValue:[[totalList objectAtIndex:doPublishView.indexPathForSelectedRow.row] objectForKey:@"id"]    forKey:CONTENT_ID];
    
    //处理请求返回
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@"response >>>>>>%@",responseString);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSString *state = [dictionary objectForKey:@"state"];
        if (((![state isKindOfClass:[NSNull class]]) && state != nil)) {
            NSString *message = [dictionary objectForKey:@"message"];
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:message  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@"failed >>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)getListwithPage:(int)page{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_TRADES                           forKey:ACTION];
    [request setPostValue:[CommonUtil getUserName]                  forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]                  forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]                  forKey:ACCOUNT_TYPE];
    [request setPostValue:[CommonUtil getLocation]                  forKey:AREA_ID];
    
    if ([self.index isEqualToString:@"0"]) {
        [request setPostValue:SUPPLYPUBLISH                         forKey:TRADE_TYPE];
    }else{
        [request setPostValue:WANTPUBLISH                           forKey:TRADE_TYPE];
    }
    
    [request setPostValue:@"2"                                      forKey:RETRIEVE_TYPE];
    [request setPostValue:[NSString stringWithFormat:@"%d",page]    forKey:PAGE];
    
    [request setCompletionBlock:^{
        [doPublishView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        
        NSArray *array = [dictionary objectForKey:@"res"];
        totalPage = [[dictionary objectForKey:@"total_page"] intValue];
        idPage = [[dictionary objectForKey:@"current_page"]intValue];
        
        for (int i =0 ; i < array.count; i++) {
            [totalList addObject:[array objectAtIndex:i]];
            
        }
        [doPublishView reloadData];
        NSLog(@"response >>  %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [doPublishView tableViewDidFinishedLoading];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)change{
    [self doPublishAction];
    isChange = YES;
}

- (void)didPublishAction{
    NSLog(@"did Publish Action");
    [self.didPublish setBackgroundImage:[UIImage imageNamed:@"btn_publish_selected"] forState:UIControlStateNormal];
    [self.doPublish setBackgroundImage:[UIImage imageNamed:@"btn_publish_normal"] forState:UIControlStateNormal];
    [self.scrollView setContentOffset:CGPointMake(320*0, 0)];
}

- (void)doPublishAction{
    NSLog(@"do Publish Action");
    [self.doPublish setBackgroundImage:[UIImage imageNamed:@"btn_publish_selected"] forState:UIControlStateNormal];
    [self.didPublish setBackgroundImage:[UIImage imageNamed:@"btn_publish_normal"] forState:UIControlStateNormal];
    [self.scrollView setContentOffset:CGPointMake(320*1, 0)];
}

- (void)addImage{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark - ASIHttpDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    NSString *jsonString = [request responseString];
    isChange = NO;
    
    //判断返回字符串是否是string，是否为空
    if (((![jsonString isKindOfClass:[NSNull class]]) && ![jsonString isEqualToString:@""] && jsonString != nil)) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:jsonString];
        NSString *state = [dictionary objectForKey:@"state"];
        //发送发表供求的返回信息
        if (((![state isKindOfClass:[NSNull class]]) && state != nil)) {
            NSString *message = [dictionary objectForKey:@"message"];
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:message  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }
      
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {

    [SVProgressHUD dismiss];
    isChange = NO;
    NSString *jsonString = [request responseString];
    NSLog(@"failed >>>>>>>>> %@",jsonString);
}

#pragma -mark PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    NSLog(@"did start refreshing");
//    [tableView launchRefreshing];
    tableView.reachedTheEnd = NO;
    [totalList removeAllObjects];
    [tableView reloadData];
    idPage = 1;
    [self getListwithPage:idPage];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    NSLog(@"did start loading");
//    [tableView launchRefreshing];
    idPage++;
    if (idPage <= totalPage) {
        [self getListwithPage:idPage];
    }else if(idPage > totalPage){
        [tableView tableViewDidFinishedLoadingWithMessage:@"没有了哦，亲"];
        tableView.reachedTheEnd  = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [doPublishView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [doPublishView tableViewDidEndDragging:scrollView];
}

#pragma -mark UIImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    chosenImage = info[UIImagePickerControllerEditedImage];
    [CommonUtil clearTemp:tempImagePath];
    [UIImagePNGRepresentation(chosenImage) writeToFile:[ NSTemporaryDirectory() stringByAppendingPathComponent:@"temp_image.png"] atomically:YES];
    [addImage setImage:chosenImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma -mark tableview datasource delgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return totalList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"wantCell";
    
    WantPublishCell *cell = (WantPublishCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WantPublishNib" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *dictionary = [totalList objectAtIndex:indexPath.row];
    //设置标题
    cell.title.text     = [dictionary objectForKey:@"title"];
    //设置价格
    cell.price.text     = [dictionary objectForKey:@"price"];
    //设置收藏
    cell.favourate.text = [dictionary objectForKey:@"fav_count"];
    //设置内容
    cell.material.text  = [dictionary objectForKey:@"description"];
    //设置头像
    NSString *path = [dictionary objectForKey:@"image_path"];
    if (path != nil &&(![path isEqualToString:@""])) {
        NSString *imageUrl = IMAGE_TEMP(path);
        NSURL *url = [[NSURL alloc] initWithString:imageUrl];
        [cell.head setImageURL:url];
    }else{
        [cell.head setImage:[UIImage imageNamed:@"icon_default"]];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tradeCell = [totalList objectAtIndex:indexPath.row];
    
    ProductDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailView"];
    view.moreInfor = [totalList objectAtIndex:indexPath.row];
    
    if ([self.index isEqualToString:@"0"]) {
        //供应
        view.contentId = @"1";
    }else{
        //求购
        view.contentId = @"2";
    }
    
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73;
}

- (void) btnActionShow{
    if(currentPage == 0){
        [self didPublishAction];
    }else{
        [self doPublishAction];
    }
}

//读取文件
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
    [self createProvinceComboxView];
    [self getTitleArray];
    
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
        }
        
        [cityTB removeFromSuperview];
        [self createCityComboxView];
        NSLog(@">>>> %@",responseString);
              
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)getBroughWithId:(int) indexs{
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
        [broughList removeAllObjects];
        for (int i = 0; i < array.count; i++) {
            [broughList addObject:[array objectAtIndex:i]];
        }
        
        [boroughTB removeFromSuperview];
        [self createBoroughComboxView];
        NSLog(@">>>> %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)getTitleArray{
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
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:[request responseString]];
        
        [titielArray removeAllObjects];
        for (int i = 0; i < array.count; i ++) {
            [titielArray addObject:[array objectAtIndex:i]];
        }
        [self createCatComboxView];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}


#pragma -mark scrollview delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2)/pageWidth)+1;
    pageControl.currentPage = page;
    currentPage = page;
    pageControlUsed = NO;
    [self btnActionShow];
    
}

#pragma -mark UI init
- (void)createProvinceComboxView{
    provinceTB = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(25, 110, 60, 1)];
    [didPublishView addSubview:provinceTB];
    isOpened=NO;
    
    // province*********************************************************************************
    [provinceTB initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        int count = provinceList.count;
        return count;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        [cell.lb setText:[[provinceList objectAtIndex:indexPath.row] objectForKey:@"name"]] ;
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [btnProvince setTitle:cell.lb.text forState:UIControlStateNormal];
        [btnProvince sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self getCityWithId:[[[provinceList objectAtIndex:indexPath.row] objectForKey:@"id"] intValue] ];
    }];
    
    [provinceTB.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [provinceTB.layer setBorderWidth:2];
       
}

- (void)createCityComboxView{
    cityTB = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(95, 110, 60, 1)];
    [didPublishView addSubview:cityTB];
    isOpened=NO;
    
    [cityTB initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        int count = cityList.count;
        return count;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        [cell.lb setText:[[cityList objectAtIndex:indexPath.row] objectForKey:@"name"]];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [btnCity setTitle:cell.lb.text forState:UIControlStateNormal];
        [btnCity sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self getBroughWithId:[[[cityList objectAtIndex:indexPath.row]objectForKey:@"id"]intValue]];
    }];
    [cityTB.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cityTB.layer setBorderWidth:2];
}

- (void)createBoroughComboxView{
    boroughTB = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(165, 110, 60, 1)];
    [didPublishView addSubview:boroughTB];
    isOpened=NO;
    
    // borough*********************************************************************************
    [boroughTB initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        int count = broughList.count;
        return count;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        [cell.lb setText:[[broughList objectAtIndex:indexPath.row] objectForKey:@"name"]];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [btnBorough setTitle:cell.lb.text forState:UIControlStateNormal];
        [btnBorough sendActionsForControlEvents:UIControlEventTouchUpInside];
        broughId = [[broughList objectAtIndex:indexPath.row] objectForKey:@"id"];
        NSString *str = [[broughList objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSLog(@">>>  %@",str);
    }];
    
    [boroughTB.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [boroughTB.layer setBorderWidth:2];
}

- (void)createCatComboxView{
    catTB = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(235, 110, 60, 1)];
    [didPublishView addSubview:catTB];
    isOpened=NO;
    
    // borough*********************************************************************************
    [catTB initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        int count = titielArray.count;
        return count;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        [cell.lb setText:[[titielArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [btnCat setTitle:cell.lb.text forState:UIControlStateNormal];
        [btnCat sendActionsForControlEvents:UIControlEventTouchUpInside];
        type = [[titielArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    }];
    
    [catTB.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [catTB.layer setBorderWidth:2];
}

- (void)changeProvinceStatus {
    
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=provinceTB.frame;
            frame.size.height=1;
            [provinceTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=provinceTB.frame;
            frame.size.height=200;
            [provinceTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
    
}

- (void)changeCityStatus {
    
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=cityTB.frame;
            frame.size.height=1;
            [cityTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=cityTB.frame;
            frame.size.height=200;
            [cityTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
    
}

- (void)changeBoroughStatus {
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=boroughTB.frame;
            frame.size.height=1;
            [boroughTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=boroughTB.frame;
            frame.size.height=200;
            [boroughTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
}

- (void)changeCatStatus {
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=catTB.frame;
            frame.size.height=1;
            [catTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=catTB.frame;
            frame.size.height=200;
            [catTB setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
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
    
    if ([self.index isEqualToString:@"0"]) {
        self.navigationItem.title = @"供应发布";
    }else{
        self.navigationItem.title = @"求购发布";
    }
}

- (void)addBasicView{
    //设置按钮事件 背景
    self.didPublish.showsTouchWhenHighlighted = YES;
    [self.didPublish setBackgroundImage:[UIImage imageNamed:@"btn_publish_selected"] forState:UIControlStateNormal];
    [self.didPublish addTarget:self action:@selector(didPublishAction) forControlEvents:UIControlEventTouchUpInside];
    self.doPublish.showsTouchWhenHighlighted  = YES;
    [self.doPublish setBackgroundImage:[UIImage imageNamed:@"btn_publish_normal"] forState:UIControlStateNormal];
    [self.doPublish addTarget:self action:@selector(doPublishAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void) initScrollView{
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*2, self.scrollView.frame.size.height-80);
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    
    currentPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    [self createAllEmptyPagesForScrollView];
}

- (void) createAllEmptyPagesForScrollView{
    [self createDidPublishView];
    [self createDoPublishView];
    
    [self.scrollView addSubview:didPublishView];
    [self.scrollView addSubview:doPublishView];
}

- (void)createDidPublishView{
    didPublishView = [[TPKeyboardAvoidingScrollView alloc] init];
    didPublishView.frame = CGRectMake(320*1, 0, 320, self.scrollView.frame.size.height);
    didPublishView.contentSize = CGSizeMake(320, self.scrollView.frame.size.height + 40);
    didPublishView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //创建 添加头像按钮
    addImage = [UIButton buttonWithType:UIButtonTypeCustom];
    addImage.frame = CGRectMake(130, 10, 70, 70);
    [addImage setBackgroundImage:[UIImage imageNamed:@"btn_addimage"] forState:UIControlStateNormal];
    [addImage addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [didPublishView addSubview:addImage];
    
    //添加 spinner city
    btnProvince = [UIButton buttonWithType:UIButtonTypeCustom];
    btnProvince.frame = CGRectMake(25, 85, 60, 25);
    btnProvince.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    btnProvince.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    btnProvince.layer.borderWidth = 1;
    [btnProvince setTitle:@"省" forState:UIControlStateNormal];
    btnProvince.titleLabel.textAlignment = UIControlContentVerticalAlignmentCenter;
    [btnProvince setTitleColor:[CommonValue purpuleColor] forState:UIControlStateNormal];
    [btnProvince addTarget:self action:@selector(changeProvinceStatus) forControlEvents:UIControlEventTouchUpInside];
    [didPublishView addSubview: btnProvince];
   
    //添加 spinner borough
    btnCity = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCity.frame = CGRectMake(95, 85, 60, 25);
    btnCity.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    btnCity.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    btnCity.layer.borderWidth = 1;
    [btnCity setTitle:@"市" forState:UIControlStateNormal];
    btnCity.titleLabel.textAlignment = UIControlContentVerticalAlignmentCenter;
    [btnCity setTitleColor:[CommonValue purpuleColor] forState:UIControlStateNormal];
    [btnCity addTarget:self action:@selector(changeCityStatus) forControlEvents:UIControlEventTouchUpInside];
    [didPublishView addSubview: btnCity];
    
    btnBorough = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBorough.frame = CGRectMake(165, 85, 60, 25);
    btnBorough.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    btnBorough.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    btnBorough.layer.borderWidth = 1;
    [btnBorough setTitle:@"区" forState:UIControlStateNormal];
    btnBorough.titleLabel.textAlignment = UIControlContentVerticalAlignmentCenter;
    [btnBorough setTitleColor:[CommonValue purpuleColor] forState:UIControlStateNormal];
    [btnBorough addTarget:self action:@selector(changeBoroughStatus) forControlEvents:UIControlEventTouchUpInside];
    [didPublishView addSubview: btnBorough];
    
    btnCat = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCat.frame = CGRectMake(235, 85, 60, 25);
    btnCat.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    btnCat.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    btnCat.layer.borderWidth = 1;
    [btnCat setTitle:@"类型" forState:UIControlStateNormal];
    btnCat.titleLabel.textAlignment = UIControlContentVerticalAlignmentCenter;
    [btnCat setTitleColor:[CommonValue purpuleColor] forState:UIControlStateNormal];
    [btnCat addTarget:self action:@selector(changeCatStatus) forControlEvents:UIControlEventTouchUpInside];
    [didPublishView addSubview: btnCat];
    
    //添加 label price
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 40, 30)];
    price.text = @"价 格";
    price.font = [UIFont fontWithName:@"Helvetica" size:15];
    price.backgroundColor = [UIColor clearColor ];
    [didPublishView addSubview:price];
    
    //添加 textfield price
    tfPrice = [[UITextField alloc] initWithFrame:CGRectMake(60, 120, 245, 30)];
    tfPrice.borderStyle = UITextBorderStyleNone;//外框类型
    tfPrice.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    tfPrice.layer.borderWidth = 1;
	tfPrice.autocorrectionType = UITextAutocorrectionTypeNo;
	tfPrice.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tfPrice.returnKeyType = UIReturnKeyDone;
    tfPrice.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	tfPrice.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    [didPublishView addSubview:tfPrice];
    
    //添加 label title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, 40, 30)];
    title.text = @"标 题";
    title.font = [UIFont fontWithName:@"Helvetica" size:15];
    title.backgroundColor = [UIColor clearColor ];
    [didPublishView addSubview:title];
    
    //添加 textfield title
    tfTitle = [[UITextField alloc] initWithFrame:CGRectMake(60, 160, 245, 30)];
    tfTitle.borderStyle = UITextBorderStyleNone;//外框类型
    tfTitle.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    tfTitle.layer.borderWidth = 1;
	tfTitle.autocorrectionType = UITextAutocorrectionTypeNo;
	tfTitle.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tfTitle.returnKeyType = UIReturnKeyDone;
    tfTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	tfTitle.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    [didPublishView addSubview:tfTitle];
    
    //添加 label phone
    UILabel *phone = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 40, 30)];
    phone.text = @"电 话";
    phone.font = [UIFont fontWithName:@"Helvetica" size:15];
    phone.backgroundColor = [UIColor clearColor ];
    [didPublishView addSubview:phone];
    
    //添加 textfield phone
    tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(60, 200, 245, 30)];
    tfPhone.borderStyle = UITextBorderStyleNone;//外框类型
    tfPhone.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    tfPhone.layer.borderWidth = 1;
	tfPhone.autocorrectionType = UITextAutocorrectionTypeNo;
	tfPhone.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tfPhone.returnKeyType = UIReturnKeyDone;
    tfPhone.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    [didPublishView addSubview:tfPhone];
    
    //添加 label other
    UILabel *other = [[UILabel alloc] initWithFrame:CGRectMake(10, 240, 40, 30)];
    other.text = @"描 述";
    other.font = [UIFont fontWithName:@"Helvetica" size:15];
    other.backgroundColor = [UIColor clearColor ];
    [didPublishView addSubview:other];
    
    //添加 textfield other
    tfOther = [[UITextView alloc] initWithFrame:CGRectMake(60, 240, 245, 120)];
    tfOther.layer.borderColor = [[CommonValue purpuleColor] CGColor];
    tfOther.layer.borderWidth = 1;
	tfOther.autocorrectionType = UITextAutocorrectionTypeNo;
	tfOther.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tfOther.returnKeyType = UIReturnKeyDone;
    [didPublishView addSubview:tfOther];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.showsTouchWhenHighlighted = YES;
    submit.frame = CGRectMake(135, 370, 50, 30);
    [submit setBackgroundImage:[UIImage imageNamed:@"bg_btn_submit"] forState:UIControlStateNormal];
    [submit setTitle:@"完成" forState: UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:12];
    [submit setTitleColor:[CommonValue purpuleColor] forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(addInfo) forControlEvents:UIControlEventTouchUpInside];
    [didPublishView addSubview:submit];
    
    //添加 combox content
    
    
    
}

- (void)createDoPublishView{
    doPublishView = [[PullingRefreshTableView alloc]init ];
    doPublishView.frame = CGRectMake(320*0, 0, 320, self.scrollView.frame.size.height);
    doPublishView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    doPublishView.dataSource = self;
    doPublishView.delegate   = self;
    doPublishView.pullingDelegate = self;
    doPublishView.separatorColor = [CommonValue purpuleColor];
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [doPublishView addGestureRecognizer:longPressGr];
}

//长按事件，触发响应
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:doPublishView];
        NSIndexPath * indexPath = [doPublishView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        //add your code here
        NSLog(@"response");
        [self showAlert];
    }
}

- (void)showAlert{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"请选择操作" message:nil];
    [alert addButtonWithTitle:@"修改供求" block:^{
        [self change];
    }];

    [alert addButtonWithTitle:@"置顶" block:^{
        [self toTop];
    }];
    [alert addButtonWithTitle:@"预约置顶" block:^{
        [self orderTop];
    }];
    [alert addButtonWithTitle:@"删除置顶" block:^{
        [self deleteTop];
    }];
    [alert addButtonWithTitle:@"删除信息" block:^{
        [self deleteInfor];
    }];
    [alert setCancelButtonWithTitle:@"取消" block:nil];
    
    [alert show];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end
