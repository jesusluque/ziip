//
//  DetalleRecientesViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipBase.h"


@interface DetalleRecientesViewController : ZiipBase

@property (nonatomic, retain) NSDictionary *reciente;

@property (nonatomic, retain) IBOutlet UIImageView *imgTipoAccion;

@property (nonatomic, retain) IBOutlet UILabel *tipoAccion;
@property (nonatomic, retain) IBOutlet UILabel *contacto_nombre;
@property (nonatomic, retain) IBOutlet UILabel *contacto_contacto;
@property (nonatomic, retain) IBOutlet UILabel *contacto2_nombre;
@property (nonatomic, retain) IBOutlet UILabel *contacto2_contacto;
@property (nonatomic, retain) IBOutlet UILabel *mensaje_personalizado;
@property (nonatomic, retain) IBOutlet UILabel *mensaje;




-(void) pintaReciente;






@end
