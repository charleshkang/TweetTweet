//
//  TTHomeTableViewController.m
//  TweetTweet
//
//  Created by Charles Kang on 5/17/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import <STTwitter/STTwitter.h>
#import <UIScrollView+InfiniteScroll.h>

#import "TTHomeTableViewController.h"
#import "TTCustomTableViewCell.h"
#import "TTTwitterAPIManager.h"

@interface TTHomeTableViewController ()

@property (nonatomic) UITableView *homeTableView;

@property (nonatomic) NSMutableArray<TTTweets *> *tweetsArray;
@property (nonatomic) TTTwitterAPIManager *twitterAPI;
@property (nonatomic) NSString *maxId;

@end

@implementation TTHomeTableViewController

static NSString *const clientId = @"0FgDEtuBA7uzji1rj0hiEUVJ2";
static NSString *const clientSecret = @"uNNLTO8RITEUK3Gz4ed7hlHKAQzZUWjxK9m7vassLCehDXGGdl";
static NSString *tweetCellIdentifier = @"customTweetCellIdentifier";

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self setUpTwitter];
    
    UINib *nib = [UINib nibWithNibName:@"TTCustomCell" bundle:nil];
    [self.homeTableView registerNib:nib forCellReuseIdentifier:tweetCellIdentifier];
    
    self.navigationItem.title = @"TweetTweet Feed";
}

#pragma mark - Tableview Methods

- (void)setupTableView
{
    self.homeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.homeTableView.rowHeight = UITableViewAutomaticDimension;
    self.homeTableView.estimatedRowHeight = 100.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.homeTableView.dataSource = self;
    self.homeTableView.delegate = self;
    self.homeTableView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    
    [self.view addSubview:self.homeTableView];
    [self setupRefreshControl];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweetsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTCustomTableViewCell *cell = (TTCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TTCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    TTTweets *tweet = self.tweetsArray[indexPath.row];
    cell.usernameLabel.text = [NSString stringWithFormat:@"Tweeted by: %@", tweet.userName];
    cell.tweetLabel.text = tweet.tweetText;
    
    [tweet getProfileImagesFromTwitterData:^(UIImage *image) {
        cell.userProfileImage.image = image;
        cell.userProfileImage.layer.cornerRadius = cell.userProfileImage.frame.size.width / 2;
        cell.userProfileImage.clipsToBounds = YES;
        cell.userProfileImage.layer.borderWidth = 3.0f;
        cell.userProfileImage.layer.borderColor = [UIColor blackColor].CGColor;
    }];
    
    if (indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor lightGrayColor];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - Twitter API Implementation

- (void)setUpTwitter
{
    self.twitterAPI = [TTTwitterAPIManager queryTwitterWithConsumerKey:clientId consumerSecret:clientSecret completion:^(NSString *userId, NSString *username) {
        NSLog(@"Authentication Successful");
        [self searchTwitterWithQueries:YES completion:nil];
        [self.homeTableView reloadData];
        
    } error:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Twitter Query Implementation

- (void)searchTwitterWithQueries:(BOOL)firstQuery completion: (void(^)(void))completion
{
    [self.twitterAPI fetchTweets:@"@Peek" maxId:self.maxId successBlock:^(NSDictionary *searchData, NSArray *data) {
        
        if (!self.tweetsArray) {
            self.tweetsArray = [NSMutableArray new];
        }
        if (firstQuery == YES) {
            self.tweetsArray = [NSMutableArray arrayWithArray:[TTTweets twitterDataFromJSON:data]];
            self.maxId = searchData[@"max_id"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.homeTableView reloadData];
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Swipe to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.tweetsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.homeTableView reloadData];
    }
}

#pragma mark - Refresh and Infinite Scrolling
- (void)setupRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(reloadData:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)reloadData:(UIRefreshControl *)control
{
    if (control) {
        [self searchTwitterWithQueries:YES completion:nil];
        [self.homeTableView reloadData];
        [self.refreshControl endRefreshing];
    }
}

- (void)setupInfiniteScrolling
{
    __weak typeof(self) weakSelf = self;
    
    self.homeTableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    
    [self.homeTableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        
        [weakSelf searchTwitterWithQueries:YES completion:^{
            [tableView finishInfiniteScroll];
        }];
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.homeTableView.contentOffset.y >= (self.homeTableView.contentSize.height - self.homeTableView.frame.size.height)) {
        [self setupInfiniteScrolling];
    }
}

@end