//
//  TTTwitterAPIManager.m
//  TweetTweet
//
//  Created by Charles Kang on 5/17/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import "TTTwitterAPIManager.h"

@implementation TTTwitterAPIManager

+ (instancetype)queryTwitterWithConsumerKey:(NSString *)consumerKey
                             consumerSecret:(NSString *)consumerSecret
                                 completion:(void (^)(NSString *userId, NSString *username))completion
                                      error:(void (^)(NSError *error))error
{
    TTTwitterAPIManager *twitterAPI = [[TTTwitterAPIManager alloc] init];
    twitterAPI.twitterAPI = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    [twitterAPI.twitterAPI verifyCredentialsWithUserSuccessBlock:completion errorBlock:error];
    return twitterAPI;
}

- (void)fetchTweets:(NSString *)query
              maxId:(NSString *)maxId
       successBlock:(void(^)(NSDictionary *searchData, NSArray *statuses))successBlock
         errorBlock:(void(^)(NSError *error))errorBlock
{
 [self.twitterAPI getSearchTweetsWithQuery:query
                                   geocode:nil
                                      lang:nil
                                    locale:nil
                                resultType:@"recent"
                                     count:@"120"
                                     until:nil
                                   sinceID:nil
                                     maxID:maxId
                           includeEntities:@(YES)
                                  callback:nil
                              successBlock:successBlock
                                errorBlock:errorBlock];
}

@end
