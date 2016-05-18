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
#import "TTTwitterAPIManager.h"

@interface TTHomeTableViewController ()

@property (nonatomic) UITableView *homeTableView;

@property (strong,nonatomic) NSMutableArray *titleArray;
@property (strong,nonatomic) NSMutableArray *bodyArray;

@end

@implementation TTHomeTableViewController

static NSString *const clientId = @"0FgDEtuBA7uzji1rj0hiEUVJ2";
static NSString *const clientSecret = @"uNNLTO8RITEUK3Gz4ed7hlHKAQzZUWjxK9m7vassLCehDXGGdl";
static NSString *tweetCellIdentifier = @"customCellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self setUpTwitter];
    [self refreshTweets];
    [self setupInfiniteScrolling];
    
    self.navigationItem.title = @"TweetTweet Feed";
}

#pragma mark - Tableview Methods

- (void)setupTableView
{
    self.homeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.homeTableView.dataSource = self;
    self.homeTableView.delegate = self;
    self.homeTableView.frame = CGRectMake(0,0,0,0);
    
    self.homeTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.homeTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tweetCellIdentifier"];
    [self.tableView reloadData];
    [self.view addSubview:self.homeTableView];
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tweetCellIdentifier];
    
    UITableViewCell *cell = [self.homeTableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tweetCellIdentifier];
    }
    
    if (indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor lightGrayColor];
    else
        cell.backgroundColor = [UIColor whiteColor];

    NSDictionary *tweetDict = self.tweetsArray[indexPath.row];
    NSDictionary *userDict = [tweetDict objectForKey:@"user"];
    NSString *tweetText = [tweetDict objectForKey:@"text"];
    NSString *username = [userDict objectForKey:@"name"];
    NSString *profileImage = [userDict objectForKey:@"profile_image_url"];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    cell.textLabel.text = tweetText;
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tweet by: %@", username];
    
    NSURL *url = [NSURL URLWithString: profileImage];
    NSData *data = [NSData dataWithContentsOfURL:url];
    cell.imageView.image = [[UIImage alloc] initWithData:data];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.estimatedRowHeight = 70.0;
    return tableView.rowHeight = UITableViewAutomaticDimension;
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
        
        if (firstQuery == YES) {
            
            self.maxId = searchData[@"max_id"];
            self.tweetsArray = [[NSMutableArray alloc] init];
            [self.tweetsArray addObjectsFromArray:data];
        } else {
            
            [self.tweetsArray addObjectsFromArray:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
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
    }
}

#pragma mark - Refresh and Infinite Scrolling
- (void)refreshTweets
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)reloadData {
    [self.tableView reloadData];
    if (self.refreshControl) {
        
        [self.tweetsArray removeAllObjects];
        [self.tableView reloadData];
        [self searchTwitterWithQueries:YES completion:nil];
        [self.refreshControl endRefreshing];
    }
}

- (void)setupInfiniteScrolling
{
    __weak typeof(self) weakSelf = self;
    
    self.homeTableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        [weakSelf searchTwitterWithQueries:NO completion:^{
            [weakSelf.homeTableView finishInfiniteScrollWithCompletion:^(id scrollView) {
                [scrollView stopAnimating];
            }];
        }];
    }];
}

@end