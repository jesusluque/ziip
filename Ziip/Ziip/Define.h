//
//  Define.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef d3_Define_h
#define d3_Define_h

#define CONEXION_URL @"http://ziip.marodriguez.com/api/"

#define IMAGENES_URL @"http://ziip.marodriguez.com:8000/uploads/"
#define CHAT_URL @"ziip.marodriguez.com"


#define TIPO_MENSAJE_BLOQUEAR = 4
#define TIPO_MENSAJE_DESBLOQUEAR = 5

#define ACCION_ANONIMO = "1"
#define ACCION_CELESTINO = "2"
#define ACCION_CONTACTA = "3"
#define ACCION_BANG = "4"

#endif


@interface UIColor (BackgroundColor)

+ (UIColor*)backgroundColor;

@end


@interface UIColor (ForegroundColor)

+ (UIColor*) foregroundColor;

@end

@interface UIColor (LogoColor)

+ (UIColor*)logoColor;

@end


@interface UIColor (BlancoColor)

+ (UIColor*)blancoColor;

@end