//
//  ViewController.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ListaChatsViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SocketIOPacket.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "MPNotificationView.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "Define.h"

@implementation ListaChatsViewController



- (void) viewDidAppear:(BOOL)animated {
    
    NSLog(@"View did appear");
    self.chatAbierto = NO;
    [super viewDidAppear:animated];
}


- (void) viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    self.chatAbierto = NO;
    [self recarga];
    if (self.abrirChatUsuario) {
        [self abrirChat:self.abrirChatUsuario];
        self.abrirChatUsuario=nil;
        
    }

}


- (void) viewDidDisappear:(BOOL)animated {
    
    self.chatAbierto = YES;
    [super viewDidDisappear:animated];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.conectado=NO;
    self.chatAbierto = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.myId = [NSNumber numberWithInt:[[defaults objectForKey:@"id"] intValue]];
    self.conectar = YES;
    self.imageCache = [[ImageCache alloc]init];
    AppDelegate *delegado = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = delegado.managedObjectContext;
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:nil andSortKey:@"idMessage" andSortAscending:false andContext:self.managedObjectContext];
    if ([listaMensajes count] > 0) {
        ChatMessage *message = [listaMensajes objectAtIndex:0];
        self.lastMessageId = message.idMessage;
    } else {
        self.lastMessageId = 0;
    }
    //[self conectarSocket];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    reach.reachableBlock = ^(Reachability*reach) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.conectar = YES;
            [self conectarSocket];
            
        });
    };
    reach.unreachableBlock = ^(Reachability*reach) {
        
    };
    [reach startNotifier];
}


- (void) socketIODidConnect:(SocketIO *)socket {
    
    self.conectado = YES;
    
    if (self.chatAbierto) {
        [self.chatViewController activaBotonSend];
    }
}


- (void)conectarSocket {
    
    if (self.conectar) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *user = [defaults objectForKey:@"user"];
        NSString *pass = [defaults objectForKey:@"password"];
        self.miSocket = [[SocketIO alloc] initWithDelegate:self];
        self.miSocket.delegate = self;
        [self.miSocket connectToHost:CHAT_URL onPort:8888];
        NSArray *valores = [[NSArray alloc] initWithObjects:user, pass, nil];
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"user", @"pass", nil];
        NSDictionary *datos = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        [self.miSocket sendEvent:@"login" withData:datos];
    }
}


- (void)toForeground {
    
    self.conectar = YES;
    [self conectarSocket];
}


- (void)toBackground {

    self.conectar = NO;
    [self.miSocket disconnect];
}





- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error; {

    self.conectado = NO;
    if (self.chatAbierto) {
        [self.chatViewController desactivaBotonSend];
    }
    [self conectarSocket];
}


- (void)desconectar {

    self.conectar = NO;
    [self.miSocket disconnect];
}


- (void)recarga {
    
    NSArray *listaLastMensajes = [CoreDataHelper searchObjectsForEntity:@"LastsMessages" withPredicate:nil andSortKey:@"fecha" andSortAscending:false andContext:self.managedObjectContext];
    self.ultimosMensajes = [[NSMutableArray alloc] init];
    for (LastsMessages *last in listaLastMensajes) {
        [self.ultimosMensajes addObject:last];
    }
    [self.myTableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.ultimosMensajes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserCell *cell;
    static NSString *CellIdentifier;
    CellIdentifier = @"userCell";
    cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in nibObjects) {
            if ([currentObject isKindOfClass:[UserCell class]]) {
                cell = (UserCell *)currentObject;
            }
        }
    }
    LastsMessages *last = [self.ultimosMensajes objectAtIndex:indexPath.row];
    cell.usuario.text = last.userName;
    NSString *texto;
    if ([last.tipo intValue] == 1) {
        texto = last.text;
    }
    
    if ([last.tipo intValue] == 2) {
        texto = @"Image";
    }
    if ([last.tipo intValue] == 3) {
        texto = @"Localization";
    }
    if ([last.tipo intValue] == 4) {
        texto = @"Video";
    }
    cell.texto.text = texto;
    cell.numMensajes.text = [[NSString alloc] initWithFormat:@"%@", last.noRead];
    [cell.numMensajes.layer setCornerRadius:5.0f];
    [cell.numMensajes.layer setMasksToBounds:YES];
    if ([last.noRead intValue] == 0) {
        cell.numMensajes.hidden = YES;
    } else {
        cell.numMensajes.hidden = NO;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *diaFecha = [dateFormat stringFromDate:last.fecha];
    NSString *hoy = [dateFormat stringFromDate:[NSDate date]];
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    if ([hoy isEqualToString:diaFecha]) {
        [dateFormat2 setDateFormat:@"h:mm aaa"];
    } else {
        [dateFormat2 setDateFormat:@"MMM/dd/yy"];
    }
    cell.hora.text = [dateFormat2 stringFromDate:last.fecha];
    /*
    if ([last.userType intValue] == 2) {
        cell.imgTipoUsuario.hidden = NO;
        [cell.imgTipoUsuario setImage:  [UIImage imageNamed:@"user_ribbon_professor"]];
        cell.usuario.text = [[NSString alloc] initWithFormat:@"%@ - Professor", last.userName];
    } else if ( [last.userType intValue] == 4) {
        cell.imgTipoUsuario.hidden = NO;
        [cell.imgTipoUsuario setImage:  [UIImage imageNamed:@"user_ribbon_staff"]];
        cell.usuario.text = [[NSString alloc] initWithFormat:@"%@ - Staff", last.userName];    } else if ( [last.userType intValue] == 5) {
            cell.imgTipoUsuario.hidden = NO;
            [cell.imgTipoUsuario setImage:  [UIImage imageNamed:@"user_ribbon_program_admin"]];
            cell.usuario.text = [[NSString alloc] initWithFormat:@"%@ - Program Admin", last.userName];
        } else {
            cell.imgTipoUsuario.hidden = YES;
        }
    */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [self.imageCache getCachedImage:last.img];
        dispatch_async(dispatch_get_main_queue(), ^{
            CGSize size = CGSizeMake(50, 50);
            UIGraphicsBeginImageContext(size);
            [img drawInRect:CGRectMake(0, 0, 50, 50)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [cell.fotoUsuario setImage:scaledImage];
            [cell.fotoUsuario.layer setCornerRadius:6.0f];
            [cell.fotoUsuario.layer setMasksToBounds:YES];
        });
    });
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    LastsMessages *last = [self.ultimosMensajes objectAtIndex:indexPath.row];
    [self cargarChat:last];
    self.openUserId = [[NSString alloc] initWithFormat:@"%d", [ last.userId intValue]];;
    self.chatAbierto = YES;
    last.noRead = [[NSNumber alloc] initWithInt:0];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) cargarChat:(LastsMessages *)last {
    
    [self.chatViewController cerrarChat];
    self.ultimoMensaje = last;
    [NSTimer scheduledTimerWithTimeInterval:0.25f  target:self  selector:@selector(showNewChat:) userInfo:nil repeats:NO];
}


- (void) showNewChat:(NSTimer *) timer {
    
    [self performSegueWithIdentifier: @"chatSegue" sender: self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LastsMessages *last = [self.ultimosMensajes objectAtIndex:indexPath.row];
        [self.ultimosMensajes removeObjectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:last];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new data with error: %@", [error domain]);
        }
        [self recarga];
    }
}


- (void)enviaMensaje:(NSMutableDictionary *)datos {
    
    self.lastMessageId = [NSNumber numberWithFloat:([self.lastMessageId intValue] + 1)];
    ChatMessage *message = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.managedObjectContext];
    message.to = [[NSNumber alloc] initWithInt:[[datos objectForKey:@"to"]intValue]];
    message.tipo = [[NSNumber alloc] initWithInt:[[datos objectForKey:@"type"]intValue]];
    message.text = [datos objectForKey:@"text"];
    /*
    if ([[datos objectForKey:@"type"]intValue] != 2) {
        message.text = [datos objectForKey:@"text"];
    } else {
        // guardamos la img y guardamos su ruta.
        NSData *data = [NSData dataFromBase64String:[datos objectForKey:@"text"]];
        UIImage *image = [[UIImage alloc] initWithData:data];
        NSError *error;
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *image_id = [defaults objectForKey:@"id_image"];
        image_id = [[NSString alloc] initWithFormat:@"%i", [image_id intValue] + 1 ];
        
        [defaults setObject:image_id forKey:@"id_image"];
        
        NSString *imgPath = [NSString stringWithFormat:@"self_imagenes/image_%@.png", image_id];
        NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", docDir, imgPath];
        [UIImagePNGRepresentation(image) writeToFile:uniquePath options:NSDataWritingAtomic error:&error];
        message.text = imgPath;
    }
     */
    message.from = self.myId;
    message.fecha = [NSDate date];
    message.idMessage = self.lastMessageId;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    // lo guardamos en lastMessage
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId=%@", message.to]];
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"LastsMessages" withPredicate:itemPredicate andSortKey:@"userId" andSortAscending:false andContext:self.managedObjectContext];
    LastsMessages *last;
    if ([listaMensajes count] > 0) {
        last = [listaMensajes objectAtIndex:0];
    } else {
        last = (LastsMessages *)[NSEntityDescription insertNewObjectForEntityForName:@"LastsMessages" inManagedObjectContext:self.managedObjectContext];
        
        NSMutableDictionary *user_data = [[NSMutableDictionary alloc]init];
        [user_data setObject:message.to forKey:@"id"];
        [self.miSocket sendEvent:@"getUserInfo" withData:user_data];

    }
    last.tipo = message.tipo;
    last.text = message.text;
    last.userId = message.to;
    last.fecha = [NSDate date];
    NSString *strFrom = [self.myId stringValue];
    if ([strFrom isEqualToString:self.openUserId]) {
        [self.chatViewController recarga];
    } else {
        last.noRead = [[NSNumber alloc] initWithInt:0];
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    // Tengo que parsear la fecha a string con el formato correcto
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    NSString *strFecha = [dateFormat stringFromDate:message.fecha];
    [datos setObject:self.lastMessageId forKey:@"id"];
    [datos setObject:strFecha forKey:@"date"];
    
    [self.miSocket sendEvent:@"newMsg" withData:datos];
    [self.myTableView reloadData];
}


- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    
    NSDictionary *datos;
    if ([packet.name isEqualToString:@"login"]) {
        [self getLogin:packet.args];
    } else if ([packet.name isEqualToString:@"recMsg"]) {
        [self recMsg:packet.args];
    } else if ([packet.name isEqualToString:@"newMsg"]) {
        self.notifica = YES;
        datos = [packet.args objectAtIndex:0];
        [self newMsg:datos];
    } else if ([packet.name isEqualToString:@"readMsg"]) {
        datos = [packet.args objectAtIndex:0];
        [self readMsg:datos];
    } else if ([packet.name isEqualToString:@"getOldMsg"]) {
        self.notifica = NO;
        [self getOldMsg:packet.args];
    }else if ([packet.name isEqualToString:@"getUserInfo"]) {
        self.notifica = NO;
        [self getUserInfo:packet.args];
    }
}


- (void)getUserInfo:(NSArray *)data {
    NSLog(@"El user info");
    NSDictionary *usuario = [data objectAtIndex:0];
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId=%@", [usuario objectForKey:@"id"]]];
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"LastsMessages" withPredicate:itemPredicate andSortKey:@"userId" andSortAscending:false andContext:self.managedObjectContext];
    LastsMessages *last;
    if ([listaMensajes count] > 0) {
        last = [listaMensajes objectAtIndex:0];
    }
    last.userName = [usuario objectForKey:@"usuario"];
    
    last.img = [usuario objectForKey:@"imagen"];

    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    UIImage *img = [self.imageCache getCachedImage:last.img];
    UIImage *scaledImage = [ImageCache redimensionaImage:img maxWidth:50 andMaxHeight:50];
    if (self.notifica) {
        NSDictionary *userInfo = [[NSDictionary alloc]initWithObjects:[[NSArray alloc] initWithObjects:@"datos", @"chatOther", nil] forKeys:[[NSArray alloc] initWithObjects:@"data", @"type", nil]];
        [MPNotificationView notifyWithText:last.userName detail:last.text image:scaledImage andDuration:5.0f andUserInfo:userInfo];
    }
    [self.myTableView reloadData];
    

}


- (void)getLogin:(NSArray *)data {
    
    NSDictionary *datos = [data objectAtIndex:0];
    NSString *status = [datos objectForKey:@"status"];
    if ([status isEqualToString:@"ok"]) {
        self.myId = [[NSNumber alloc] initWithInt:[[datos objectForKey:@"userId"]intValue] ];
        
        [self recarga];
        // hemos hecho login, vamos a traernos los mensajes antiguos
        NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:nil andSortKey:@"serverId" andSortAscending:false andContext:self.managedObjectContext];
        NSString *lastMsg = @"0";
        if ([listaMensajes count] > 0) {
            ChatMessage *msg = [listaMensajes objectAtIndex:0];
            lastMsg = [[NSString alloc] initWithFormat:@"%@", msg.serverId];
        }
        NSArray *valores = [[NSArray alloc] initWithObjects:lastMsg, nil];
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"lastMsg", nil];
        NSDictionary *datos = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        [self.miSocket sendEvent:@"getOldMsg2" withData:datos];
    } else {
        NSLog(@"Error al hacer login");
    }
}


- (void)recMsg:(NSArray *)data {
    
    NSDictionary *datos = [data objectAtIndex:0];
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"idMessage=%@", [datos objectForKey:@"id" ]]];
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:itemPredicate andSortKey:@"idMessage" andSortAscending:false andContext:self.managedObjectContext];
    if ([listaMensajes count] > 0) {
        ChatMessage *msg = [listaMensajes objectAtIndex:0];
        msg.serverId = [datos objectForKey:@"serverId"];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new data with error: %@", [error domain]);
        }
    } else {
        NSLog(@"error, el server me dice que le he enviado un mensaje que realmente no he enviado");
    }
}


- (void)getOldMsg:(NSArray *)data {
    
    NSArray *messages = [[data objectAtIndex:0] objectForKey:@"newMsg"];
    for (NSDictionary *message in messages) {
        [self newMsg:message ];
    }
    NSArray *readsMessages = [[data objectAtIndex:0] objectForKey:@"readMsg"];
    for (NSDictionary *readMessage in readsMessages) {
        [self readMsg:readMessage ];
    }
    [self recarga];
    [self.chatViewController recarga];
    [self.chatViewController goFin];
}


- (void)newMsg:(NSDictionary *)datos {
    
    self.lastMessageId = [NSNumber numberWithFloat:([self.lastMessageId intValue] + 1)];
    ChatMessage *message = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.managedObjectContext];
    
    message.tipo = [[NSNumber alloc] initWithInt:[[datos objectForKey:@"type"]intValue]];
    
    if (message.tipo.intValue == 1) {
        
        message.text = [datos objectForKey:@"text"];
    }
    
    message.to = [[NSNumber alloc] initWithInt:[[datos objectForKey:@"destination"]intValue]];
    
    message.from =  [[NSNumber alloc] initWithInt:[[datos objectForKey:@"from"]intValue]];
    message.idMessage = self.lastMessageId;
    if ([[datos objectForKey:@"readed"]intValue] == 1) {
        message.fechaLeido = [NSDate date];
    }
    NSString *fecha = [datos objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    message.fecha =  [dateFormat dateFromString:fecha];
    message.serverId = [datos objectForKey:@"serverId"];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    // Lo añadimos tb a lastMEssages
    NSString *lastUserID;
    if ( [[datos objectForKey:@"from" ] isEqualToString: [self.myId stringValue]]){
        lastUserID = [datos objectForKey:@"destination" ];
    } else {
        lastUserID = [datos objectForKey:@"from"];
    }
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId=%@", lastUserID]];
    
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"LastsMessages" withPredicate:itemPredicate andSortKey:@"userId" andSortAscending:false andContext:self.managedObjectContext];
    LastsMessages *last;
    if ([listaMensajes count] > 0) {
        last = [listaMensajes objectAtIndex:0];
    } else {
        last = (LastsMessages *)[NSEntityDescription insertNewObjectForEntityForName:@"LastsMessages" inManagedObjectContext:self.managedObjectContext];
        NSMutableDictionary *user_data = [[NSMutableDictionary alloc]init];
        [user_data setObject:lastUserID forKey:@"id"];
        [self.miSocket sendEvent:@"getUserInfo" withData:user_data];
      
    }

    if (message.tipo.intValue ==1) {
        last.text = [datos objectForKey:@"text"];
        last.tipo = message.tipo;
        last.fecha = message.fecha;
    } else {
        if (message.tipo.intValue == 4) {
            last.bloqueado = @(1);
        } else if (message.tipo.intValue == 5){
            last.bloqueado = @(0);
        }
    }
    
    last.userId = [[NSNumber alloc] initWithInt:[lastUserID intValue]];
    
    
    NSString *strFrom = [datos objectForKey:@"from"];
    if (self.chatAbierto) {
        if ([strFrom isEqualToString:self.openUserId]) {
            [self.chatViewController recarga];
            [self.chatViewController goFin];
        } else {
            last.noRead = [[NSNumber alloc] initWithInt:([last.noRead intValue] + 1)];
            if ([listaMensajes count] > 0) {
                if (self.notifica) {
                    NSString *strMyId = [[NSString alloc] initWithFormat:@"%d", [self.myId intValue]];
                    if (![strMyId isEqualToString:[datos objectForKey:@"from"] ]) {
                        UIImage *img = [self.imageCache getCachedImage:last.img];
                        UIImage *scaledImage = [ImageCache redimensionaImage:img maxWidth:50 andMaxHeight:50];
                        NSDictionary *userInfo = [[NSDictionary alloc]initWithObjects:[[NSArray alloc] initWithObjects:@"datos", @"chatOther", [datos objectForKey:@"from"], nil] forKeys:[[NSArray alloc] initWithObjects:@"data", @"type", @"userId", nil]];
                        
                        [MPNotificationView notifyWithText:last.userName detail:last.text image:scaledImage andDuration:5.0f andUserInfo:userInfo];
                    }
                }
            }
        }
    } else {
        last.noRead = [[NSNumber alloc] initWithInt:([last.noRead intValue] + 1)];
        [self.myTableView reloadData];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    NSMutableDictionary *recDatos = [[NSMutableDictionary alloc] initWithObjects:nil forKeys:nil];
    [recDatos setObject:message.serverId forKey:@"serverId"];
    [self.miSocket sendEvent:@"recMsg" withData:recDatos];
}


- (void)readMsg:(NSDictionary *)datos {
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"serverId=%@", [datos objectForKey:@"serverId" ]]];
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:itemPredicate andSortKey:@"idMessage" andSortAscending:false andContext:self.managedObjectContext];
    if ([listaMensajes count] > 0) {
        ChatMessage *msg = [listaMensajes objectAtIndex:0];
        msg.fechaLeido = [NSDate date];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new data with error: %@", [error domain]);
        }
        NSMutableDictionary *readData = [[NSMutableDictionary alloc] initWithObjects:nil forKeys:nil];
        [readData setObject:msg.serverId forKey:@"serverId"];
        [self.miSocket sendEvent:@"readMsg" withData:readData];
        [self.chatViewController recarga];
        [self.chatViewController goFin];
        
    } else {
        NSLog(@"error, el server me dice que han leido un mensaje que realmente no he enviado");
    }
}


- (void)showChat:(NSTimer *)timer {
    
    [self performSegueWithIdentifier:@"chatSegue" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"chatSegue"]) {
        
        self.chatViewController = (ChatViewController *)[segue destinationViewController];
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSString *idUsuario = [defaults objectForKey:@"id"];
        self.chatViewController.myId = [self.myId stringValue];
        self.chatViewController.delegate = self;
        self.chatViewController.userId = [[NSString alloc]  initWithFormat:@"%@",self.ultimoMensaje.userId ];
        self.chatViewController.title =  self.ultimoMensaje.userName;
        self.chatViewController.ultimoMensaje = self.ultimoMensaje;
        
        
    }
}

- (void)bloquear:(NSNumber *)usuarioId estado:(NSNumber *)estado {

    self.lastMessageId = [NSNumber numberWithFloat:([self.lastMessageId intValue] + 1)];
    ChatMessage *message = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.managedObjectContext];
    message.to = usuarioId;
    if ([estado intValue]==0) {
        message.tipo = @(5) ; //Desbloquear

    } else {
        message.tipo = @(4); //Bloquear

    }
    message.text = @"";
    message.from = self.myId;
    message.fecha = [NSDate date];
    message.idMessage = self.lastMessageId;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    // lo guardamos en lastMessage
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId=%@", message.to]];
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"LastsMessages" withPredicate:itemPredicate andSortKey:@"userId" andSortAscending:false andContext:self.managedObjectContext];
    LastsMessages *last;
    if ([listaMensajes count] > 0) {
        last = [listaMensajes objectAtIndex:0];
    } else {
        last = (LastsMessages *)[NSEntityDescription insertNewObjectForEntityForName:@"LastsMessages" inManagedObjectContext:self.managedObjectContext];
        
        NSMutableDictionary *user_data = [[NSMutableDictionary alloc]init];
        [user_data setObject:message.to forKey:@"id"];
        [self.miSocket sendEvent:@"getUserInfo" withData:user_data];
        
    }
    last.tipo = message.tipo;
    last.userId = message.to;
    last.fecha = [NSDate date];
    NSString *strFrom = [self.myId stringValue];
    if ([strFrom isEqualToString:self.openUserId]) {
        [self.chatViewController recarga];
    } else {
        last.noRead = [[NSNumber alloc] initWithInt:0];
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new data with error: %@", [error domain]);
    }
    // Tengo que parsear la fecha a string con el formato correcto
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    NSString *strFecha = [dateFormat stringFromDate:message.fecha];
    
    
    NSArray *valores = [[NSArray alloc] initWithObjects:@"",usuarioId,message.tipo ,nil];
    NSArray *parametros = [[NSArray alloc] initWithObjects:@"text",@"to",@"type",nil];
    NSMutableDictionary *datos = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:parametros];
    
    
    [datos setObject:self.lastMessageId forKey:@"id"];
    [datos setObject:strFecha forKey:@"date"];
    
    [self.miSocket sendEvent:@"newMsg" withData:datos];
 
}

- (void) abrirChat:(NSDictionary *) usuario{
    
    NSLog(@"Abrimos chat: %@",usuario);
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId=%@",  [usuario objectForKey:@"id"]]];
    NSArray *listaMensajes = [CoreDataHelper searchObjectsForEntity:@"LastsMessages" withPredicate:itemPredicate andSortKey:@"userId" andSortAscending:false andContext:self.managedObjectContext];
    
    LastsMessages *last;
    
    
    if ([listaMensajes count]==0) {

        
        last = (LastsMessages *)[NSEntityDescription insertNewObjectForEntityForName:@"LastsMessages" inManagedObjectContext:self.managedObjectContext];
        last.userId = [usuario objectForKey:@"id"];
    } else {
        last = [listaMensajes objectAtIndex:0];
    }

    
    
    [self cargarChat:last];
    self.openUserId = [[NSString alloc] initWithFormat:@"%d", [ last.userId intValue]];;
    self.chatAbierto = YES;
    last.noRead = [[NSNumber alloc] initWithInt:0];
}









@end
