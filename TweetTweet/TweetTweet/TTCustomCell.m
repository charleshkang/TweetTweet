//
//  TTCustomCell.m
//  TweetTweet
//
//  Created by Charles Kang on 5/17/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import "TTCustomCell.h"

@interface TTCustomCell ()

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation TTCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.userNameLabel = [[UILabel alloc] init];
        [self.userNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.userNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.userNameLabel setNumberOfLines:1];
        [self.userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.userNameLabel setTextColor:[UIColor blackColor]];
        [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.userNameLabel];
        
        self.userTweetLabel = [[UILabel alloc] init];
        [self.userNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.userNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.userNameLabel setNumberOfLines:1];
        [self.userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.userNameLabel setTextColor:[UIColor blackColor]];
        [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.userTweetLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) return;
    
    NSDictionary *viewsDictionary = @{
                                      @"userNameLabel" : self.userNameLabel,
                                      @"userTweetLabel" : self.userTweetLabel
                                      };
    
    NSString *format;
    NSArray *constraintsArray;
    
    format = @"V:|-10-[userNameLabel]-10-[userTweetLabel]-10-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:viewsDictionary];
    [self.contentView addConstraints:constraintsArray];
    
    format = @"|-10-[userNameLabel]-10-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:viewsDictionary];
    [self.contentView addConstraints:constraintsArray];
    
    format = @"|-10-[userTweetLabel]-10-|";
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:viewsDictionary];
    [self.contentView addConstraints:constraintsArray];
    
    self.didSetupConstraints = YES;
    
}

@end
