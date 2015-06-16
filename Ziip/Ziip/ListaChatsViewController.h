//
//  ViewController.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCell.h"
#import "SocketIO.h"
#import "ChatViewController.h"
#import "ChatMessage.h"
#import "NewChatViewController.h"
#import "LastsMessages.h"
#import "ZiipBase.h"
#import "ImageCache.h"

//#import "NSData+Base64.h"

/*
@class ListaChatsViewController;
@protocol ListaChatsDelegate <NSObject>

-(void) cargarChat:(LastsMessages *)last;
-(void) recargaChatController;
-(void) activaBotonSend;
-(void) desactivaBotonSend;


@end
*/
@interface ListaChatsViewController : ZiipBase <UITableViewDataSource,UITableViewDelegate,SocketIODelegate,ChatDelegate,ZiipRequestDelegate>
//@property (weak) __weak id <ListaChatsDelegate> delegate;
@property (nonatomic) bool notifica;
@property (nonatomic) bool conectar;
@property (nonatomic) bool conectado;
@property (nonatomic,retain) SocketIO *miSocket;
@property (retain, nonatomic) NSNumber *myId;
@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) NSNumber *lastMessageId;
@property (retain, nonatomic) ChatViewController *chatViewController;
@property (retain, nonatomic) NewChatViewController *addChatViewController;
@property (nonatomic) NSInteger selectedRow;
@property (retain, nonatomic) NSMutableArray *ultimosMensajes;
@property ( nonatomic) bool chatAbierto;
@property (nonatomic,retain) NSString *openUserId;
@property (nonatomic,retain) NSString *openUserName;
@property (nonatomic,retain) NSString *openUserImg;
@property (nonatomic,retain) NSString *openUserCity;
@property (nonatomic,retain) LastsMessages *ultimoMensaje;
@property (nonatomic,retain) NSDictionary *abrirChatUsuario;



- (void) newMsg:(NSDictionary *) datos;
- (void) abrirChat:(NSDictionary *) usuario;
- (void)desconectar;
@end
