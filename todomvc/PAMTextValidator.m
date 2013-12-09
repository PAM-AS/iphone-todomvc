//
//  PAMTextValidator.m
//  PAM
//
//  Created by Thomas Sunde Nielsen on 03.07.13.
//  Copyright (c) 2013 thomassnielsen. All rights reserved.
//

#import "PAMTextValidator.h"

@implementation PAMTextValidator

+ (BOOL)validateEmail:(NSString *)email
{
    if (!email)
        return NO;
    if ([email length] == 0)
        return NO;
    NSError *error = [[NSError alloc] init];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\w\\.!#$%&+-/=?_~-]+@[a-zA-Z0-9\\.-]+\\.([a-zA-Z]){2,63}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *result = [regex matchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if ([result count] >= 1)
        return YES;
    else
        return NO;
}

@end
