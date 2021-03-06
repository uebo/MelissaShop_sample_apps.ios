//
//  MELSHomeViewController.m
//  MelissaShop
//
//  Created by 植田 洋次 on 2014/05/12.
//  Copyright (c) 2014年 Appiaries Corporation. All rights reserved.
//

#import "MELSHomeViewController.h"
#import "MELSUserManager.h"
#import "MELSInformationManager.h"
#import "MELSInformation.h"
#import "MELSHomeViewCell.h"
#import "MELSInformationViewController.h"

static NSString *const kCellIdentifier = @"HomeViewCell";
static NSString *const kCellSegue = @"InformationPushSegue";

@interface MELSHomeViewController ()

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,strong) UIRefreshControl *refreshControl;

@end

@implementation MELSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NavigationBar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header"]];
    
    //RefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self refreshAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_tableView setDelegate:nil];
}

//--------------------------------------------------------------//
#pragma mark -- UITableViewDataSource --
//--------------------------------------------------------------//
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[MELSInformationManager sharedManager].collections count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    MELSHomeViewCell *cell = (MELSHomeViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if ([[MELSInformationManager sharedManager].collections count] <= indexPath.row) {
        return cell;
    }
    
    MELSInformation *information = [MELSInformationManager sharedManager].collections[(NSUInteger) indexPath.row];
    [cell setupWithInformation:information];

    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kCellSegue]) {
        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
        MELSInformation *information = [MELSInformationManager sharedManager].collections[(NSUInteger) selected.row];
        
        MELSInformationViewController *controller = segue.destinationViewController;
        controller.information = information;
    }
}

//--------------------------------------------------------------//
#pragma mark Action method
//--------------------------------------------------------------//
- (void)refreshAction:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    [self loadTableView];
}

-(void)loadTableView
{
    __weak typeof(self) weakSelf = self;

    //HOMEデータ呼び出し
    [[MELSInformationManager sharedManager]getInformationWithCompletion:^(NSError *error) {
        if (error) {
            [weakSelf displayError:error completion:nil];
        } else {
            [weakSelf.tableView reloadData];
        }
        [weakSelf.refreshControl endRefreshing];
    }];
}

@end
