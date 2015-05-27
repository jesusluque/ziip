//
//  ImageCache.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCache : NSObject


- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImagePubli: (NSString *) ImageURLString;

- (UIImage *) getChatCachedImage: (NSString *) ImageURLString;
+ (UIImage *) redimensionaImage: (UIImage *) image maxWidth: (float) max_width andMaxHeight:(float) max_height;
- (UIImage *) getChatCachedImageThumb: (NSString *) ImageURLString;

@end
