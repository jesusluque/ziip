//
//  ChatViewController.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MensajesAntiguosCell.h"
#import "ChatCell.h"
#import "ImageCache.h"
#import  "PerfilUsuarioViewController.h"
#import "LastsMessages.h"
//#import "ImgChatViewController.h"

@class ChatViewController;
@protocol ChatDelegate <NSObject>

- (void)enviaMensaje:(NSDictionary *)datos;
- (void)bloquear:(NSNumber *)usuarioId estado:(NSNumber *)estado;
@end

@interface ChatViewController : ZiipBase <UINavigationControllerDelegate, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, MensajesAntiguosCellDelegate,ChatCellDelegate,PerfilUsuarioDelegate>//UIImagePickerControllerDelegate

@property (nonatomic)int num_paginas;
//@property (nonatomic,retain) NSString *userCity;
//@property (nonatomic,retain) NSString *userName;
//@property (nonatomic,retain) NSNumber *userType;
//@property (nonatomic,retain) NSString *urlImg;


@property (nonatomic,retain) LastsMessages *ultimoMensaje;

//@property (nonatomic,retain) ImgChatViewController *imgChatViewController;

@property (nonatomic,retain) UIImagePickerController *imagePicker;
@property (nonatomic,retain) ChatMessage *showLoc;
@property (nonatomic,retain) ChatMessage *deleteMSg;
@property (nonatomic,retain) ChatCell *selCell;
@property (nonatomic,retain) IBOutlet UITextField *texto;
@property (nonatomic,retain) IBOutlet UIButton *btnEnviar;
@property (nonatomic,retain) IBOutlet UIButton *btnMas;
@property (nonatomic,retain)  NSString *userId;
@property (weak) id <ChatDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *listaMensajes;
@property (nonatomic,retain) NSMutableArray *dias;
@property (nonatomic,retain) NSMutableDictionary *mensajes;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic,retain) NSString *myId;
@property (nonatomic,retain) IBOutlet UIView *menuInferior;
@property (nonatomic) bool is_ipad;
@property (nonatomic) bool is_iphone5;
@property (nonatomic, retain) IBOutlet UIImageView *fondo;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic) bool segmentedOpen;
@property (nonatomic) long total_mensajes;
@property (nonatomic,retain) IBOutlet UIView *fondoPie;

-(void) recarga;
-(IBAction) enviar;
//-(IBAction) doFoto;
//-(IBAction) selectFoto;
//-(IBAction) selectVideo;
//-(IBAction) enviaLoc;
//-(IBAction) cerrarMenu;
//-(IBAction) masAcciones;
-(void) cerrarChat;
- (void) goFin;
- (void) activaBotonSend;
- (void) desactivaBotonSend;
- (void) montaCabecera;



@end
