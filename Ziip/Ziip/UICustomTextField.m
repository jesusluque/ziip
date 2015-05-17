//
//  UICustomTextField.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 17/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "UICustomTextField.h"

@implementation UICustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

*/

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor colorWithRed:130 green:81 blue:160 alpha:0]CGColor];
    
    self.layer.borderWidth= 1.0f;
}
@end
