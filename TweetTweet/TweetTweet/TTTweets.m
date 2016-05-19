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
        self.userProfileImageURL = userProfileImage;
    }
    return self;
}

+ (NSArray<TTTweets *> *)twitterDataFromJSON:(NSArray *)json
{
    NSMutableArray<TTTweets *> *tweetsDataArray = [NSMutableArray new];
    
    if (json)
    {
        for (NSDictionary *data in json) {
            
            NSString *tweetText = data[@"text"];
            NSDictionary *userDict = data[@"user"];
            NSString *userName = userDict[@"name"];
            NSString *userProfileImage = userDict[@"profile_image_url"];
            
            TTTweets *allTweets = [[TTTweets alloc] initWithUserDict:userDict tweetText:tweetText userName:userName userProfileImage:userProfileImage];
            [tweetsDataArray addObject:allTweets];
        }
    }
    return tweetsDataArray;
}

- (void)getProfileImagesFromTwitterData:(void(^)(UIImage *image))completion
{
    if (!self.userProfileImageURL) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSURL *url = [NSURL URLWithString:self.userProfileImageURL];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        UIImage *img = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(img);
        });
    });
}

@end
