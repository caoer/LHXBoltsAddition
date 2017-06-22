//
//  NSPredicate+TMAddition.m
//  AppBuilderMVP
//
//  Created by Zitao Xiong on 8/24/16.
//  Copyright © 2016 lighthousex. All rights reserved.
//

#import "NSPredicate+LHXAddition.h"

@implementation NSPredicate (LHXAddition)
+ (instancetype)predicateWithType:(NSString *)type containedIn:(NSArray *)identifiers {
    return [NSPredicate predicateWithFormat:@"%K IN %@", type, identifiers];
}
@end
