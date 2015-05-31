//
//  Recientes.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Recientes : NSManagedObject

@property(nonatomic, retain) NSNumber *id;
@property(nonatomic, retain) NSString *accion;
@property(nonatomic, retain) NSString *contacto_nombre;
@property(nonatomic, retain) NSString *contacto2_nombre;
@property(nonatomic, retain) NSString *contacto_contacto;
@property(nonatomic, retain) NSString *contacto2_contacto;
@property(nonatomic, retain) NSString *mensaje;
@property(nonatomic, retain) NSString *mensaje_anonimo;

@property(nonatomic, retain) NSDate *fecha;

@end
