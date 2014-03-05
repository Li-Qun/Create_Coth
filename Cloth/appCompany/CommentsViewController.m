//
//  CommentsViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-23.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "CommentsViewController.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController

@synthesize labelTitle   = _labelTitle;
@synthesize labelContent = _labelContent;
@synthesize comentTable  = _comentTable;
@synthesize contentId    = _contentId;
@synthesize contentType  = _contentType;

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
    totalList = [[NSMutableArray alloc] init];
	
    [self createNavigationItem];
    [self createSubView];
    [self getList];
}

#pragma -mark custom method
- (void) getList
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETREIEVE_COMMENTS         forKey:ACTION];
    [request setPostValue:self.contentId             forKey:CONTENT_ID];
    [request setPostValue:self.contentType           forKey:CONTENT_TYPE];
  
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        
        [totalList removeAllObjects];
        for (int i = 0; i < array.count; i++) {
            [totalList addObject:[array objectAtIndex:i]];
        }
        
        [self.comentTable reloadData];
        NSLog(@"response >>  %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}



-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark tableview delegate datasoucre
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return totalList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //moreDSCell
    static NSString *CellIdentifier = @"commentCell";
    CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.labelTitle.text   = [[totalList objectAtIndex:indexPath.row] objectForKey:@"text"];
    cell.labelContent.text = [[totalList objectAtIndex:indexPath.row] objectForKey:@"date_added"];
    return cell;
}


#pragma -mark UI init
-(void)createSubView
{
    [self.comentTable setSeparatorColor:[CommonValue purpuleColor]];
}

- (void)createNavigationItem
{
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
    
    self.navigationItem.title = @"评价";
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
