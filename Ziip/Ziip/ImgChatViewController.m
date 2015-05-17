//
//  ImgChatViewController.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ImgChatViewController.h"


@implementation ImgChatViewController

@synthesize imagen;
@synthesize menuSuperior;
@synthesize imageCache;
@synthesize originalImagen;
@synthesize botonImg;


-(void) viewDidLoad{
    
    [super viewDidLoad];
    self.imageCache = [[ImageCache alloc] init];
}


- (NSUInteger)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight |UIInterfaceOrientationMaskPortraitUpsideDown;
}


- (IBAction)volver:(void *)sender {
  
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.menuSuperior.alpha=0;
}


- (void) imgTouch:(void *)sender {
    
    float newAlpha;
    if (self.menuSuperior.alpha==1) {
        newAlpha = 0;
    } else {
        newAlpha = 1;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.menuSuperior.alpha = newAlpha;
    }completion:^(BOOL finished){
    }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   
    return YES;
}
/*

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
      
    NSLog(@"willRotate");

     NSLog(@"antes de  redimensionarla tiene alto %f y ancho %f",self.originalImagen.size.height, self.originalImagen.size.width);
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft ||toInterfaceOrientation==UIInterfaceOrientationLandscapeRight){
       
        UIImage *img2=[imageCache redimensionaImage:self.originalImagen maxWidth:480 andMaxHeight:320];
        NSLog(@"y tras redimensionarla tiene alto %f y ancho %f",img2.size.height, img2.size.width);
        float pos_x= (480-img2.size.width)/2;
        float pos_y= (320-img2.size.height)/2;
        CGRect frame= CGRectMake(pos_x, pos_y,img2.size.width,img2.size.height);
        CGRect frame2= CGRectMake(0, 0,480,320);
        self.botonImg.frame=frame2;
        CGRect frameMenu= CGRectMake(0, 0,480,49);
        self.menuSuperior.frame=frameMenu;
        self.imagen.frame=frame;
        [self.imagen setImage:img2];
    } else {
      
        UIImage *img2=[imageCache redimensionaImage:self.originalImagen maxWidth:320 andMaxHeight:480];
        NSLog(@"y tras redimensionarla tiene alto %f y ancho %f",img2.size.height, img2.size.width);
        float pos_x= (320-img2.size.width)/2;
        float pos_y= (480-img2.size.height)/2;
        
        NSLog(@"la posicion y es:%f",pos_y);
        NSLog(@"la posicion x es:%f",pos_x);
        
        CGRect frame= CGRectMake(pos_x, 100,img2.size.width,img2.size.height);
         self.imagen.frame=frame;
        CGRect frameBoton= CGRectMake(0, 0,320,480);
        self.botonImg.frame=frameBoton;
        CGRect frameMenu= CGRectMake(0, 0,320,49);
        self.menuSuperior.frame=frameMenu;
        
        [self.imagen setImage:img2];
        self.imagen.frame=frame;
        
        frame =self.imagen.frame;
        
        
        NSLog(@"uiimageview la posicion y es:%f",frame.origin.y);
        NSLog(@"uiimageview la posicion x es:%f",frame.origin.x);
        NSLog(@"uiimageview la alto es:%f",frame.size.height);
        NSLog(@"uiimageview  ancho x es:%f",frame.size.width);
       
        
    }
  
      
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
NSLog(@"didRotate");
 
NSLog(@"antes de  redimensionarla tiene alto %f y ancho %f",self.originalImagen.size.height, self.originalImagen.size.width);
if (fromInterfaceOrientation==UIInterfaceOrientationPortrait||fromInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown){
    
    UIImage *img2=[imageCache redimensionaImage:self.originalImagen maxWidth:480 andMaxHeight:320];
    NSLog(@"y tras redimensionarla tiene alto %f y ancho %f",img2.size.height, img2.size.width);
    float pos_x= (480-img2.size.width)/2;
    float pos_y= (320-img2.size.height)/2;
    CGRect frame= CGRectMake(pos_x, pos_y,img2.size.width,img2.size.height);
    CGRect frame2= CGRectMake(0, 0,480,320);
    self.botonImg.frame=frame2;
    CGRect frameMenu= CGRectMake(0, 0,480,49);
    self.menuSuperior.frame=frameMenu;
    self.imagen.frame=frame;
    [self.imagen setImage:img2];
} else {
    UIImage *img2=[imageCache redimensionaImage:self.originalImagen maxWidth:320 andMaxHeight:480];
    NSLog(@"y tras redimensionarla tiene alto %f y ancho %f",img2.size.height, img2.size.width);
    float pos_x= (320-img2.size.width)/2;
    float pos_y= (480-img2.size.height)/2;
    
    NSLog(@"la posicion y es:%f",pos_y);
    NSLog(@"la posicion x es:%f",pos_x);
    
    CGRect frame= CGRectMake(pos_x, pos_y,img2.size.width,img2.size.height);
    self.imagen.frame=frame;
    CGRect frameBoton= CGRectMake(0, 0,320,480);
    self.botonImg.frame=frameBoton;
    CGRect frameMenu= CGRectMake(0, 0,320,49);
    self.menuSuperior.frame=frameMenu;
    
    [self.imagen setImage:img2];
    self.imagen.frame=frame;
    
    frame =self.imagen.frame;
    
    
    NSLog(@"uiimageview la posicion y es:%f",frame.origin.y);
    NSLog(@"uiimageview la posicion x es:%f",frame.origin.x);
    NSLog(@"uiimageview la alto es:%f",frame.size.height);
    NSLog(@"uiimageview  ancho x es:%f",frame.size.width);
    
    
    }

}
 */


@end
