//
//  CelestinoViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "ConfirmacionViewController.h"


@interface CelestinoViewController : ZiipBase <ConfirmacionViewControllerDelegate,UITableViewDataSource,UITableViewDelegate, UITextViewDelegate>


@property (nonatomic, retain) NSString *telefono1;
@property (nonatomic, retain) NSString *email1;
@property (nonatomic, retain)  NSString *contacto1_nombre;
@property (nonatomic, retain) NSString *telefono2;
@property (nonatomic, retain) NSString *email2;
@property (nonatomic, retain)  NSString *contacto2_nombre;
@property (nonatomic, retain) IBOutlet UITextView *mensaje;
@property (nonatomic, retain) ConfirmacionViewController *confirmacionViewController;
@property (nonatomic, retain)  NSMutableArray *listaMensajes;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;

@end
