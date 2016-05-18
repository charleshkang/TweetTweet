//
//  TTTweets.m
//  TweetTweet
//
//  Created by Charles Kang on 5/18/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import "TTTweets.h"
#import "TTHomeTableViewController.h"

@implementation TTTweets

- (instancetype)initWithUserDict:(NSDictionary *)userDict
                       tweetText:(NSString *)tweetText
                        userName:(NSString *)userName
                userProfileImage:(NSString *)userProfileImage
{
    if (self = [super init])
    {
        self.userDict = userDict;
        self.tweetText = tweetText;
        self.userName = userName;
        self.userProfileImage = userProfileImage;
    }
    return self;
}

+ (NSArray<TTTweets *> *)twitterDataFromJSON:(NSDictionary *)json
{
    NSMutableArray<TTTweets *> *tweetsDataArray = [NSMutableArray new];
    
    if (json)
    {
        
        NSString *tweetText = json[@"text"];
        
        NSDictionary *userDict = json[@"user"];
        NSString *userName = userDict[@"name"];
        NSString *userProfileImage = userDict[@"profile_image_url"];
        
        TTTweets *allTweets = [[TTTweets alloc] initWithUserDict:userDict tweetText:tweetText userName:userName userProfileImage:userProfileImage];
        [tweetsDataArray addObject:allTweets];
    }
    return tweetsDataArray;
}

@end
