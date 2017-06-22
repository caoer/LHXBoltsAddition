//
//  NSPredicate+TMAddition.h
//  AppBuilderMVP
//
//  Created by Zitao Xiong on 8/24/16.
//  Copyright © 2016 lighthousex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (LHXAddition)
+ (instancetype)predicateWithType:(NSString *)type containedIn:(NSArray *)identifiers;
@end
