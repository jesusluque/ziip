//
//  ImageCache.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ImageCache.h"
#import "Define.h"

@implementation ImageCache

#define TMP NSTemporaryDirectory()


- (void)cacheImage:(NSString *)imageURLString {
    
    NSString *url_imagen = [[NSString alloc] initWithFormat:@"%@%@", IMAGENES_URL, imageURLString ];
	NSURL *imageURL = [NSURL URLWithString:url_imagen];
	// Generate a unique path to a resource representing the image you want
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, imageURLString];

	if (![[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {

		NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
		UIImage *image = [[UIImage alloc] initWithData:data];
		if ([imageURLString rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			
			NSError *error;
			[UIImagePNGRepresentation(image) writeToFile:uniquePath options:NSDataWritingAtomic error:&error];
		} else if ( [imageURLString rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound ||[imageURLString rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			[UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath atomically:YES];
		}
	}
}

- (void)cacheImagePubli:(NSString *)imageURLString {
    
    NSString *url_imagen = [[NSString alloc] initWithFormat:@"%@%@", IMAGENES_PUBLI_URL, imageURLString ];
    NSURL *imageURL = [NSURL URLWithString:url_imagen];
    // Generate a unique path to a resource representing the image you want
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, imageURLString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
        UIImage *image = [[UIImage alloc] initWithData:data];
        if ([imageURLString rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            NSError *error;
            [UIImagePNGRepresentation(image) writeToFile:uniquePath options:NSDataWritingAtomic error:&error];
        } else if ( [imageURLString rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound ||[imageURLString rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            [UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath atomically:YES];
        }
    }
}

- (void)cacheChatImage:(NSString *)ImageURLString {
    
	NSURL *ImageURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/%@", CONEXION_URL, ImageURLString ]];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, ImageURLString];
	if (![[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
		// The file doesn't exist, we should get a copy of it

		// Fetch image
		NSData *data = [[NSData alloc] initWithContentsOfURL:ImageURL];
		UIImage *image = [[UIImage alloc] initWithData:data];
        if ([ImageURLString rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[UIImagePNGRepresentation(image) writeToFile:uniquePath atomically:YES];
			NSError *error;
			[UIImagePNGRepresentation(image) writeToFile:uniquePath options:NSDataWritingAtomic error:&error];
		} else if ( [ImageURLString rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound ||[ImageURLString rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			[UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath atomically:YES];
		}
	}
}


- (UIImage *)getCachedImage:(NSString *)imageURLString {
    
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, imageURLString];
	UIImage *image = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
		image = [UIImage imageWithContentsOfFile:uniquePath];                          // this is the cached image
	} else {
		// get a new one
		[self cacheImage:imageURLString];
        //Y volvemos a comprobar si existe, porque ha podido fallar la descarga.
        if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
            image = [UIImage imageWithContentsOfFile:uniquePath];
        } else {
        }
	}

	return image;
}



- (UIImage *)getCachedImagePubli:(NSString *)imageURLString {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, imageURLString];
    UIImage *image = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
        image = [UIImage imageWithContentsOfFile:uniquePath];                          // this is the cached image
    } else {
        // get a new one
        [self cacheImagePubli:imageURLString];
        //Y volvemos a comprobar si existe, porque ha podido fallar la descarga.
        if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
            image = [UIImage imageWithContentsOfFile:uniquePath];
        } else {
        }
    }
    
    return image;
}


- (UIImage *)getChatCachedImage:(NSString *)ImageURLString {
    
	// Generate a unique path to a resource representing the image you want
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, ImageURLString];
	UIImage *image;

	// Check for a cached version
	if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
		image = [UIImage imageWithContentsOfFile:uniquePath];                          // this is the cached image
	} else {
		// get a new one
		[self cacheChatImage:ImageURLString];
		image = [UIImage imageWithContentsOfFile:uniquePath];
	}

	return image;
}


- (UIImage *)getChatCachedImageThumb:(NSString *)ImageURLString {
    
	// Generamos el thumb de la img para el tableView del chat.
	NSArray *datos = [ImageURLString componentsSeparatedByString:@"."];

	NSString *url_thum = [[NSString alloc] initWithFormat:@"%@_thum.%@", datos[0], datos[1]];
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, url_thum];
	UIImage *image;

	// Check for a cached version
	if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
		image = [UIImage imageWithContentsOfFile:uniquePath];                          // this is the cached image
	} else {
		// get a new one
		[self cacheChatImageThum:ImageURLString];
		image = [UIImage imageWithContentsOfFile:uniquePath];
	}

	return image;
}


- (void)cacheChatImageThum:(NSString *)imageURLString {
    
	NSArray *datos = [imageURLString componentsSeparatedByString:@"."];
	NSString *url_thum = [[NSString alloc] initWithFormat:@"%@_thum.%@", datos[0], datos[1]];
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, imageURLString];
	NSString *uniquePathThum = [NSString stringWithFormat:@"%@/%@", docDir, url_thum];
	UIImage *image;
	if ([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
		image = [UIImage imageWithContentsOfFile:uniquePath];                          // this is the cached image
	} else {
		// get a new one
		[self cacheChatImage:imageURLString];
		image = [UIImage imageWithContentsOfFile:uniquePath];
	}
	UIImage *thumbImg = [ImageCache redimensionaImage:image maxWidth:60 andMaxHeight:60];
	[UIImageJPEGRepresentation(thumbImg, 100) writeToFile:uniquePathThum atomically:YES];
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {

	float fw, fh;

	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth(rect) / ovalWidth;
	fh = CGRectGetHeight(rect) / ovalHeight;
	CGContextMoveToPoint(context, fw, fh / 2);
	CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1);
	CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1);
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (UIImage *)roundCorners:(UIImage *)img {
    
	int w = img.size.width;
	int h = img.size.height;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace,  kCGBitmapAlphaInfoMask);
	CGContextBeginPath(context);
	CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
	addRoundedRectToPath(context, rect, 5, 5);
	CGContextClosePath(context);
	CGContextClip(context);
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	return image;
}


+ (UIImage *)redimensionaImage:(UIImage *)image maxWidth:(float)max_width andMaxHeight:(float)max_height {
    
	CGSize imageSize = image.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat widthFactor = max_width / width;
	CGFloat heightFactor = max_height / height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = max_width;
	CGFloat scaledHeight = max_height;
	if (widthFactor < heightFactor) {
		scaleFactor = widthFactor;                         // scale to fit height
	} else {
		scaleFactor = heightFactor;                        // scale to fit width
	}
	scaledWidth  = width * scaleFactor;
	scaledHeight = height * scaleFactor;
	CGSize size = CGSizeMake(scaledWidth, scaledHeight);
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

@end