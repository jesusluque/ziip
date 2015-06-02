//
//  ConfirmacionViewController.h
//  d3
//
//  Created by Manuel Rodriguez Morales on 3/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConfirmacionViewController;
@protocol ConfirmacionViewControllerDelegate <NSObject>

- (void) cierraConfirmacion;
- (void) respuestaUsuario:(bool) respuesta;

@end
@interface ConfirmacionViewController : UIViewController

@property (weak) __weak id <ConfirmacionViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UILabel *titulo;
@property (nonatomic, retain) IBOutlet UILabel *mensaje;

@property (nonatomic, retain) IBOutlet UIButton *btnCancelar;
@property (nonatomic, retain) IBOutlet UIButton *btnAceptar;
@property (nonatomic, retain) IBOutlet UIButton *btnCerrar;




- (void) configuraPantalla:(NSDictionary *) confirmacion;
- (IBAction)cancelar:(id)sender;
- (IBAction)aceptar:(id)sender;
- (IBAction)cerrar:(id)sender;

@end
