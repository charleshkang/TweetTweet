//
//  TTHomeTableViewController.h
//  TweetTweet
//
//  Created by Charles Kang on 5/17/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTwitterAPIManager.h"

@interface TTHomeTableViewController : UITableViewController

@property (nonatomic) TTTwitterAPIManager *twitterAPI;
@property (nonatomic) STTwitterAPI *twitter;

@property (nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic) NSString *maxId;

@end
