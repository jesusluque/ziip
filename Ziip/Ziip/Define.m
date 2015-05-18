//
//  Define.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "Define.h"


@implementation UIColor (BackgroundColor)

+ (UIColor*)backgroundColor {
    return [UIColor colorWithRed:242/255.0 green:237/255.0 blue:249/255.0 alpha:1];
}
@end

@implementation UIColor (ForegroundColor)

+ (UIColor*)foregroundColor {
    return [UIColor colorWithRed:130/255.0 green:81.0/255.0 blue:161.0/255.0 alpha:1];
}
@end

@implementation UIColor (LogoColor)

+ (UIColor*)logoColor {
    return [UIColor colorWithRed:161.0/255.0 green:37/255.0 blue:239/255.0 alpha:1];
}
@end


@implementation UIColor (BlancoColor)

+ (UIColor*)blancoColor {
    return [UIColor colorWithRed:247/255.0 green:246/255.0 blue:248/255.0 alpha:1];
}

@end