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
    
    self.navigationItem.title = @"Tweet Tweet";
}

#pragma mark - Tableview Methods

- (void)setupTableView
{
    self.homeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.homeTableView.dataSource = self;
    self.homeTableView.delegate = self;
    self.homeTableView.frame = CGRectMake(10,30,80,80);
    
    self.homeTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.homeTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tweetCellIdentifier"];
    [self.homeTableView reloadData];
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
    [self.homeTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tweetCellIdentifier];
    
    UITableViewCell *cell = [self.homeTableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tweetCellIdentifier];
    }
    
    NSDictionary *tweetDictionary = self.tweetsArray[indexPath.row];
    NSString *tweetText = [tweetDictionary objectForKey:@"text"];
    NSDictionary *userDict = [tweetDictionary objectForKey:@"user"];
    NSString *username = [userDict objectForKey:@"name"];
    NSString *profileImage = [userDict objectForKey:@"profile_image_url"];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.textLabel.text = tweetText;
    cell.detailTextLabel.text = [NSString stringWithFormat:@" by %@", username];
    
    NSURL *url = [NSURL URLWithString: profileImage];
    NSData *data = [NSData dataWithContentsOfURL:url];
    cell.imageView.image = [[UIImage alloc] initWithData:data];
    
    [cell setNeedsUpdateConstraints];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.estimatedRowHeight = 100;
    return tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Twitter API Implementation

- (void)setUpTwitter
{
    self.twitterAPI = [TTTwitterAPIManager queryTwitterWithConsumerKey:clientId consumerSecret:clientSecret completion:^(NSString *userId, NSString *username) {
        NSLog(@"Login Successful");
        [self searchTwitterWithQueries:YES completion:nil];
        [self.homeTableView reloadData];
        
    } error:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)searchTwitterWithQueries:(BOOL)firstQuery completion: (void(^)(void))completion
{
    [self.twitterAPI fetchTweets:@"@Peek" maxId:self.maxId successBlock:^(NSDictionary *searchData, NSArray *data) {
        
        if (firstQuery == YES) {
            NSString *nextResults = searchData[@"next_results"];
            NSDictionary *nextResultsDict = [self queryDictionary:nextResults];
            self.tweetsArray = [[NSMutableArray alloc] init];
            [self.tweetsArray addObjectsFromArray:data];
            self.maxId = nextResultsDict[@"max_id"];
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

- (NSDictionary *)queryDictionary:(NSString *)parameter
{
    parameter = [parameter stringByReplacingOccurrencesOfString:@"?" withString:@""];
    NSMutableDictionary *paraDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *parameterString in [parameter componentsSeparatedByString:@"&"]) {
        NSArray *parts = [parameterString componentsSeparatedByString:@"="];
        if([parts count] < 2) continue;
        [paraDictionary setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    return paraDictionary;
}

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
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [dateFormatter stringFromDate:[NSDate date]]];
        NSDictionary *colorDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:colorDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
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
            [self.homeTableView finishInfiniteScrollWithCompletion:^(id scrollView) {
                [scrollView stopAnimating];
            }];
        }];
        
    }];
}

@end
