//
//  LHXWeakObjectContainer.h
//  Pods
//
//  Created by Zitao Xiong on 6/16/16.
//
//

#import <Foundation/Foundation.h>

@interface LHXWeakObjectContainer : NSObject
@property (nonatomic, readonly, weak) id target;
- (instancetype)initWithTarget:(id)target;
@end
