//
//  ChatCell.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ChatCell.h"
#import "Define.h"
#import <QuartzCore/QuartzCore.h>


@implementation ChatCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    if (self) {
        // Initialization code
    }
    
    
    
    return self;
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSString *sysVer7 = @"7.0";
    NSString *sysVer8 = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
   
    if ([currSysVer compare:sysVer8 options:NSNumericSearch] != NSOrderedAscending) {
        for ( UIView *subview in self.subviews){
            [subview removeFromSuperview];
        }
    } else if ([currSysVer compare:sysVer7 options:NSNumericSearch] != NSOrderedAscending) {

        NSArray *subviews = self.subviews;
        UIScrollView *scrollView= [subviews objectAtIndex:0];
        subviews = scrollView.subviews ;
        for ( UIView *subview in subviews){
            [subview removeFromSuperview];
        }
    } else {
        for ( UIView *subview in self.subviews){
            [subview removeFromSuperview];
        }
    }
    
    
    
    int max_width = self.frame.size.width -110;
    
    
    
    
    
    //self.imageCache = [[ImageCache alloc] init];
    //El label con el texto
    bool fromMe=NO;
    NSString *imgGlobo = @"bblanco"; //Blanco
    
    if ([self.myId isEqualToString:[self.message.from stringValue]]){
        fromMe=YES;
        imgGlobo = @"bmorado"; //Morado
    }

    
    CGSize size=CGSizeMake(0,0);
    UILabel *lblTexto ;
    float pos_x;
    UIButton *btn_localizacion;
    
    if ([self.message.tipo intValue]==1) {
        
        //UIFont *font = [UIFont  systemFontOfSize:17.0f];
        UIFont *font = [UIFont  fontWithName:@"Futura-Medium" size:17.0f];
        
        size = [self.message.text sizeWithFont:font constrainedToSize:CGSizeMake(max_width, 2000)];
        if (fromMe){
            pos_x=((self.frame.size.width-RIGTH_MARGIN)-size.width)-10;
        } else {
            pos_x= LEFT_MARGIN+10;
        }
        
        lblTexto = [[UILabel alloc] initWithFrame:CGRectMake(pos_x,TOP_MARGIN+3,size.width,size.height)];
        lblTexto.font = font;
        lblTexto.text = self.message.text;
        lblTexto.numberOfLines=0;
        if (fromMe){
            lblTexto.textColor = [UIColor blancoColor];
        } else {
            lblTexto.textColor = [UIColor foregroundColor];
        }
        lblTexto.backgroundColor =[UIColor clearColor];
        
        //self.texto.text = self.message.text;
        
    } /*else if ([self.message.tipo intValue]==2) {
        
        size=CGSizeMake(60,60);
        if (fromMe){
            pos_x=((320-RIGTH_MARGIN)-size.width)-10;
        } else {
            pos_x= LEFT_MARGIN+10;
        }
        btn_localizacion=[[UIButton alloc] initWithFrame:CGRectMake(pos_x,TOP_MARGIN+3,size.width,size.height)];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img=[imageCache getChatCachedImageThumb:self.message.text];
            
            img = [self fixrotation:img];
            dispatch_async(dispatch_get_main_queue(), ^{
                //UIImage *scaledImage = [imageCache redimensionaImage:img maxWidth:60 andMaxHeight:60];
                [btn_localizacion setImage:img forState:UIControlStateNormal];
                [btn_localizacion addTarget:self action:@selector(mostrarLoc)  forControlEvents:UIControlEventTouchUpInside];
            });
        });
        
    } else if([self.message.tipo intValue]==3) {
        size=CGSizeMake(18,30);
        UIImage *location = [UIImage imageNamed:@"location_place"];
        if (fromMe){
            pos_x=((320-RIGTH_MARGIN)-size.width)-10;
        } else {
            pos_x= LEFT_MARGIN+10;
        }
        btn_localizacion=[[UIButton alloc] initWithFrame:CGRectMake(pos_x,TOP_MARGIN+3,size.width,size.height)];
        [btn_localizacion setImage:location forState:UIControlStateNormal];
        [btn_localizacion addTarget:self action:@selector(mostrarLoc)  forControlEvents:UIControlEventTouchUpInside];
    }
       */
    //El Globo

    //UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgGlobo ofType:@"png"]];
    UIImage *bubble = [UIImage imageNamed:imgGlobo];

    UIImageView *globitoView = [[UIImageView alloc] initWithImage:[bubble resizableImageWithCapInsets:UIEdgeInsetsMake(5,20,23,20)]];
    
    float width_globo;
    float globo_pos_x;
    if (size.width<20){
        width_globo=40;
    } else {
        width_globo=size.width+20;
    }
    if (fromMe) {
        globo_pos_x=((self.frame.size.width-RIGTH_MARGIN)- width_globo);
    } else {
        globo_pos_x= LEFT_MARGIN;
    }
    globitoView.frame = CGRectMake(globo_pos_x, TOP_MARGIN, width_globo,size.height+10);
    
    
    //La fecha
    //UIFont *dateFont = [UIFont systemFontOfSize:12.0f];
    UIFont *dateFont = [UIFont  fontWithName:@"Futura-Medium" size:12.0f];

    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setDateFormat:@"hh:mm aaa"];
    NSString *strFecha= [dateFormat stringFromDate:self.message.fecha];
    CGSize sizeFecha=[strFecha sizeWithFont:dateFont constrainedToSize:CGSizeMake(self.frame.size.width-max_width, 2000)];
    
    float date_pos_x;
    float date_pos_y;
    date_pos_y=size.height-2;
    if (fromMe) {
        date_pos_x = globo_pos_x-sizeFecha.width - 20;
    } else {
        date_pos_x = globo_pos_x+width_globo +3;
    }
    UILabel *lblFecha = [[UILabel alloc] initWithFrame:CGRectMake(date_pos_x,date_pos_y,sizeFecha.width,sizeFecha.height)];
    lblFecha.font = dateFont;
    lblFecha.text = strFecha;
    lblFecha.backgroundColor=[UIColor clearColor];
    lblFecha.textColor = [UIColor foregroundColor];
    
    //EL CHECK
    UIImageView *checkView;
    int sumaFondo=10;
    if (fromMe) {
        NSString *imgCheck=@"chat_received";
        if (!self.message.fechaLeido) {
            imgCheck=@"chat_sent" ;
        }
        UIImage *check = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgCheck ofType:@"png"]];
        checkView = [[UIImageView alloc] initWithImage:check];
        checkView.frame=CGRectMake(date_pos_x+sizeFecha.width+3, date_pos_y+1, 17, 11);
        sumaFondo=30;
    }
    
    //el fondo de la fecha
    
    
    CGRect frameFondoFecha= CGRectMake(date_pos_x-5, date_pos_y-3, sizeFecha.width +sumaFondo , sizeFecha.height+6);
    UIView *fondoFecha = [[UIView alloc] initWithFrame:frameFondoFecha];
    fondoFecha.backgroundColor = [UIColor greenColor];
    [fondoFecha.layer setCornerRadius:3.0f];
    [fondoFecha.layer setMasksToBounds:YES];
    fondoFecha.layer.borderColor = [UIColor lightGrayColor].CGColor;
    fondoFecha.layer.borderWidth = 1.0f;
    [fondoFecha setBackgroundColor:[UIColor colorWithPatternImage:[self generaDegradado]]];
   /*
    UILongPressGestureRecognizer *LongPressgesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressgesture:)];
    [self addGestureRecognizer:LongPressgesture];
    */
    
    [self addSubview: globitoView];
    if ([self.message.tipo intValue]==1) {
        [self addSubview: lblTexto];
    } else if([self.message.tipo intValue]==2) {
        [self addSubview: btn_localizacion];
    } else if([self.message.tipo intValue]==3) {
        [self addSubview: btn_localizacion];
    }
    //[self addSubview:fondoFecha];
    
    [self addSubview: lblFecha];
    if (fromMe){
        [self addSubview: checkView];
    }
    //if (self.segmentedControl){
    //    [self addSubview:self.segmentedControl];
    //}
    
    
    
}
/*
- (void)LongPressgesture:(UILongPressGestureRecognizer *)recognizer{


    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self.delegate optionsMensaje:self];
    }
}
*/
-(UIImage *) generaDegradado {
    
    CGFloat colors [] = {
        0.6, 0.6, 0.6, 1,
        1.0, 1.0, 1.0, 1
        
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, 320   ,22, 8, 0, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipFirst);
    CGContextDrawLinearGradient(bitmapContext, gradient, CGPointMake(0.0f,0.0f), CGPointMake(0, 22.0f),0 );
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    return uiImage;
}

/*
- (void) mostrarLoc {
    
    [self.delegate verLocalizacion:self.message];
}
*/

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