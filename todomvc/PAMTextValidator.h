//
//  PAMTextValidator.h
//  PAM
//
//  Created by Thomas Sunde Nielsen on 03.07.13.
//  Copyright (c) 2013 thomassnielsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAMTextValidator : NSObject

+ (BOOL)validateEmail:(NSString *)email;

@end
