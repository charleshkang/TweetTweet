//
//  TTTweets.h
//  TweetTweet
//
//  Created by Charles Kang on 5/18/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTTweets : NSObject

@property (nonatomic) NSDictionary *tweetDict;
@property (nonatomic) NSDictionary *userDict;

@property (nonatomic) NSString *tweetText;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *userProfileImageURL;

+ (NSArray<TTTweets *> *)twitterDataFromJSON:(NSArray *)json;
- (void)getProfileImagesFromTwitterData:(void(^)(UIImage *image))completion;

@end