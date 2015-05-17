//
//  PerfilUsuarioViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 16/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "LastsMessages.h"

@class PerfilUsuarioViewController;
@protocol PerfilUsuarioDelegate <NSObject>

- (void)bloquear:(NSNumber *)usuarioId estado:(NSNumber *)estado;

@end
@interface PerfilUsuarioViewController : ZiipBase

@property (nonatomic,retain) LastsMessages *ultimoMensaje;
@property (nonatomic, retain) IBOutlet UILabel *username;
@property (nonatomic, retain) IBOutlet UIImageView *imagen;
@property (nonatomic, retain) IBOutlet UIButton *btnBloquear;
@property (weak) id <PerfilUsuarioDelegate> delegate;


-(IBAction) bloquear;

@end
