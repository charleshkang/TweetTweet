//
//  main.m
//  Test
//
//  Created by Charles Kang on 5/28/16.
//  Copyright © 2016 Charles Kang. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        NSString *name = @"charles";
        NSInteger age = 21;
        NSString *address= @"45-35, 44th St Sunnyside NY, 11104";
        
        NSLog(@"hello, my name is %@, and i am %ld years old and i live on %@", name, (long)age, address);
        
    }
    return 0;
}
