//
//  MensajeAnonimoViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 30/5/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "ConfirmacionViewController.h"
#import "MensajesCell.h"



@interface MensajeAnonimoViewController : ZiipBase <ConfirmacionViewControllerDelegate,UITableViewDataSource,UITableViewDelegate, UITextViewDelegate>


@property (nonatomic, retain) IBOutlet UITextView *mensaje;

@property (nonatomic, retain)  NSString *email;
@property (nonatomic, retain)  NSString *telefono;
@property (nonatomic, retain)  NSString *contacto_nombre;
@property (nonatomic, retain) ConfirmacionViewController *confirmacionViewController;
@property (nonatomic, retain)  NSMutableArray *listaMensajes;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;



-(IBAction) enviar;

@end
