//
//  ZiipRequest.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@class ZiipRequest;
@protocol ZiipRequestDelegate
- (void) recibeDatos:(NSDictionary *) datos;
- (void) muestra_fallo_red;
- (void) no_autorizado;
- (void) showLoading;
- (void) hideLoading;
- (void) muestra_error;

@end

@interface ZiipRequest : NSObject


@property (nonatomic,retain) NSString *urlBase;
@property (weak) __weak id <ZiipRequestDelegate> delegate;
@property (nonatomic, retain) AppDelegate *miDelegado;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) send:(NSString *)action tipo_peticion:(NSString* )tipo_peticion withParams:(NSMutableArray *)parametros andValues:(NSMutableArray *)valores enviarToken:(bool)enviarToken;
- (void) send:(NSString *)action tipo_peticion:(NSString* )tipo_peticion withParams:(NSMutableArray *)parametros andValues:(NSMutableArray *)valores imagenes:(NSArray *)imagenes enviarToken:(bool)enviarToken;


@end
