//
//  TTTwitterAPIManager.h
//  TweetTweet
//
//  Created by Charles Kang on 5/17/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STTwitter/STTwitter.h>

@interface TTTwitterAPIManager : NSObject

@property (nonatomic) STTwitterAPI *userAPI;
@property (nonatomic) STTwitterAPI *twitterAPI;

+ (instancetype)queryTwitterWithConsumerKey:(NSString *)consumerKey
                             consumerSecret:(NSString *)consumerSecret
                                 completion:(void (^)(NSString *userId, NSString *username))completion
                                      error:(void (^)(NSError *error))error;

- (void)fetchTweets:(NSString *)query
              maxId:(NSString *)maxId
       successBlock:(void (^)(NSDictionary *searchData, NSArray *statuses))successBlock
         errorBlock:(void (^)(NSError *error))error;
@end
