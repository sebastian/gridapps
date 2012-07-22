//
//  TeaError.h
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeaError : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) NSString *identifier;

+ (id) errorWithTitle:(NSString *)title description:(NSString *)description identifier:(NSString *)identifier;

@end
