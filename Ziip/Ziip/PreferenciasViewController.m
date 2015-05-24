//
//  PreferenciasViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 23/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "PreferenciasViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSData+Base64.h"

@interface PreferenciasViewController ()

@end

@implementation PreferenciasViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.username.text = [defaults objectForKey:@"user"];
    NSString *movil = [defaults objectForKey:@"movil"];
    
    if (movil) {
        self.movil.hidden=YES;
        self.editMovil.hidden=YES;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [self.imageCache getCachedImage:[defaults objectForKey:@"imagen"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            CGSize size = CGSizeMake(50, 50);
            UIGraphicsBeginImageContext(size);
            [img drawInRect:CGRectMake(0, 0, 50, 50)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self.imagen setImage:scaledImage];
            [self.imagen.layer setCornerRadius:6.0f];
            [self.imagen.layer setMasksToBounds:YES];
        });
    });
}


- (IBAction) guardar {
    
    self.movil.hidden=YES;
    self.editMovil.hidden=YES;
    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"movil",nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.movil.text, nil];
    [self.r send:@"editaMovil" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:NO];
    
}


- (IBAction) editarImagen {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"editaMovil"]) {
        [self performSegueWithIdentifier:@"segue_cod_movil" sender: self];
    } if ([[datos objectForKey:@"resource"] isEqualToString:@"editaImagen"]) {
      //Ponemos en user default la url de la imagen.
    }
}






- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString: (NSString *) kUTTypeImage ]) {
        //Foto
        
        UIImage *image = [self fixrotation:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
        
        [self.imagen setImage:image];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
            NSString *imgStr = [imageData base64EncodedString];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"imagen",nil];
                NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:imgStr, nil];
                [self.r send:@"editaImagen" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:NO];
            });
        });
        
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}



- (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



@end
