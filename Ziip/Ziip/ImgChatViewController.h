//
//  ImgChatViewController.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCache.h"

@interface ImgChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (retain, nonatomic) UIImage *originalImagen;
@property (weak, nonatomic) IBOutlet UIView *menuSuperior;
@property (weak, nonatomic) IBOutlet UIButton *botonImg;

@property (nonatomic,retain) ImageCache *imageCache;

- (IBAction)volver:(void *)sender;
- (IBAction)imgTouch:(void *)sender;

@end
