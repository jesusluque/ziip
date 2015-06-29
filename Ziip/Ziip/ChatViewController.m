//
//  ChatViewController.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "ChatMessage.h"

//#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>


@implementation ChatViewController

#define MSG_POR_PAGINA 20


- (void) viewDidLoad{
    
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden=YES;
    self.num_paginas=1;
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.fondo.image = [UIImage imageNamed:@"chat_bg"];
    AppDelegate *delegado = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = delegado.managedObjectContext;
    UIDevice* thisDevice = [UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom== UIUserInterfaceIdiomPad) {
        self.is_ipad=true;
    } else {
        self.is_ipad=false;
        if ([[UIScreen mainScreen] bounds].size.height !=480 ) {
            self.is_iphone5=true;
        } else {
            self.is_iphone5=false;
        }
    }
    [self recarga];
    
    [self montaCabecera];
    [self goFin];
    /*
    NSArray *itemArray = [NSArray arrayWithObjects: @"Copy", @"Delete", nil];
    self.segmentedControl = [[UISegmentedControl alloc]  initWithItems:itemArray];
    self.segmentedControl.frame = CGRectMake(100, 0, 100, 20);
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.backgroundColor = [UIColor blackColor];
    
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self
                         action:@selector(pickOne:)
               forControlEvents:UIControlEventValueChanged];
    */
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(cambioAltoTeclado:)  name:@"UIKeyboardWillChangeFrameNotification" object:nil];
}

-(void) cambioAltoTeclado:(NSNotification *)notification{


    NSDictionary *userInfo = notification.userInfo;
    CGRect inicio = [[userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"]CGRectValue];
    CGRect fin = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];

    float diferencia = inicio.origin.y -fin.origin.y;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.myTableView.frame = CGRectMake(self.myTableView.frame.origin.x,self.myTableView.frame.origin.y,self.myTableView.frame.size.width,self.myTableView.frame.size.height-diferencia);
        self.texto.frame = CGRectMake(self.texto.frame.origin.x,self.texto.frame.origin.y-diferencia,self.texto.frame.size.width,self.texto.frame.size.height);
        self.btnMas.frame = CGRectMake(self.btnMas.frame.origin.x,self.btnMas.frame.origin.y-diferencia,self.btnMas.frame.size.width,self.btnMas.frame.size.height);
        self.btnEnviar.frame = CGRectMake(self.btnEnviar.frame.origin.x,self.btnEnviar.frame.origin.y-diferencia,self.btnEnviar.frame.size.width,self.btnEnviar.frame.size.height);
        self.fondoPie.frame = CGRectMake(self.fondoPie.frame.origin.x,self.fondoPie.frame.origin.y-diferencia,self.fondoPie.frame.size.width,self.fondoPie.frame.size.height);
    } completion:nil];
    


    [self goFin];
}


- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self recarga];
    [self goFin];
    
}


- (void) viewWillDisappear:(BOOL)animated {
    
    if ([self.texto isFirstResponder]){
        [self textFieldShouldReturn:self.texto];
    }
    [super viewWillDisappear:animated];
}


- (void) montaCabecera {
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    bool is_ios7;
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        is_ios7=YES;
    } else {
        is_ios7=NO;
    }
    
    UIView *vista = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 44)];
    CGRect imageFrame = CGRectMake(self.view.frame.size.width -110 ,5,34,34);
    UIButton *imgUsuario = [[UIButton alloc] init];
    imgUsuario.frame = imageFrame;
    imgUsuario.backgroundColor = [UIColor foregroundColor];
    
    [imgUsuario setImage:[self.imageCache getCachedImage:self.ultimoMensaje.img] forState:UIControlStateNormal];
    [imgUsuario.layer setCornerRadius:5.0f];
    [imgUsuario.layer setMasksToBounds:YES];
    [imgUsuario addTarget:self action:@selector(aPerfil) forControlEvents:UIControlEventTouchUpInside];
    

    int fontSize = 15;
    //UIFont *font = [UIFont systemFontOfSize:fontSize];
    UIFont *font = [UIFont  fontWithName:@"Futura-Medium" size:14.0f];
    CGSize size = [self.ultimoMensaje.userName sizeWithFont:font constrainedToSize:CGSizeMake(200, 2000)];
    while (size.height >25) {
        fontSize--;
        font = [UIFont  fontWithName:@"Futura-Medium" size:fontSize];
        size = [self.ultimoMensaje.userName sizeWithFont:font constrainedToSize:CGSizeMake(200, 2000)];
    }
    
    
    CGRect labelFrame = CGRectMake((vista.frame.size.width-200) /2,10,size.width,size.height);
    UILabel *nombre = [[UILabel alloc] initWithFrame:labelFrame];
    nombre.backgroundColor = [UIColor clearColor];
    nombre.font = font;
    if (is_ios7) {
        nombre.textColor = [UIColor blackColor];
    }else {
        nombre.textColor = [UIColor whiteColor];
    }
    nombre.text = self.ultimoMensaje.userName;
    nombre.numberOfLines = 0;
    
    [vista addSubview:imgUsuario];
    [vista addSubview:nombre];

    [self.navigationItem setTitleView:vista];
}

- (void) aPerfil {
    
    [self performSegueWithIdentifier:@"segue_profile" sender:nil];
}

-(UIImage *) generaDegradado {
    
    CGFloat colors [] = {
        0.6, 0.6, 0.6, 1,
        1.0, 1.0, 1.0, 1
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);

    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, 320   ,20, 8, 0, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipFirst);
    CGContextDrawLinearGradient(bitmapContext, gradient, CGPointMake(0.0f,0.0f), CGPointMake(0, 20.0f),0 );
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    return uiImage;
}


- (void) calcula_total_mensajes {
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(from=%@ or to=%@) and tipo=1",self.userId,self.userId]];
    self.listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:itemPredicate andSortKey:@"fecha" andSortAscending:false andContext:self.managedObjectContext];
    self.total_mensajes = [self.listaMensajes count];
}


- (void) mostrarMasMensajes {
    
    self.num_paginas++;
    [self recarga];
}


- (void) recarga{

    [self calcula_total_mensajes];
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(from=%@ or to=%@ ) and tipo=1",self.userId,self.userId]];
    self.listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:itemPredicate andSortKey:@"idMessage" andSortAscending:NO andContext:self.managedObjectContext andLimit:MSG_POR_PAGINA*self.num_paginas];

    //self.listaMensajes = [CoreDataHelper searchObjectsForEntity:@"ChatMessage" withPredicate:itemPredicate andSortKey:@"idMessage" andSortAscending:NO andContext:self.managedObjectContext];
    //NSLog(@"num_mensajes:%ul",[self.listaMensajes count]);
    
    NSString *fecha = @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    self.dias = [[NSMutableArray alloc] initWithObjects: nil];
    self.mensajes = [[NSMutableDictionary alloc] initWithObjects:nil forKeys:nil];
    for (ChatMessage *message in self.listaMensajes){

        if ([fecha isEqualToString:[dateFormat stringFromDate:message.fecha]]){
            NSMutableArray *mensajes_en_dia = [self.mensajes objectForKey:fecha];
            [mensajes_en_dia addObject:message];
            [self.mensajes setObject:mensajes_en_dia forKey:fecha];
        } else {
            fecha = [dateFormat stringFromDate:message.fecha];
            [self.dias addObject:fecha];
            NSMutableArray *mensajes_en_dia = [[NSMutableArray alloc] initWithObjects:message, nil];
            [self.mensajes setObject:mensajes_en_dia forKey:fecha];
        }
    }
    if (MSG_POR_PAGINA*self.num_paginas<self.total_mensajes){
        fecha = @"vermas";
        [self.dias addObject:fecha];
    }
    [self.myTableView reloadData];
}


- (IBAction) enviar {

    if (![self.texto.text isEqualToString:@""]){
        NSArray *valores = [[NSArray alloc] initWithObjects:self.texto.text,self.userId,@"1" ,nil];
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"text",@"to",@"type",nil];
        NSMutableDictionary *datos = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:parametros];
        [self.delegate enviaMensaje:datos];
        self.texto.text = @"";
        [self recarga];
    }
    
    [self goFin];
}


- (void) goFin {
    
    [self.myTableView setContentOffset:CGPointMake(0, self.myTableView.contentSize.height-self.myTableView.frame.size.height )];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.editing) {
        [textField resignFirstResponder];
    }
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.dias count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *fecha = [self.dias objectAtIndex:([self.dias count]-1 )-section];
    if ([fecha isEqualToString:@"vermas"]) {
        return 1;
    } else {
        NSMutableArray *mensajes_en_dia = [self.mensajes objectForKey:fecha];
        return [mensajes_en_dia count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *fecha = [self.dias objectAtIndex:([self.dias count]-indexPath.section)-1];
    if ([fecha isEqualToString:@"vermas"]){
        MensajesAntiguosCell *cell;
        static NSString *CellIdentifier = @"mensajesAntiguosCell";
        cell = (MensajesAntiguosCell *)[self.myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        return cell;
    } else {
        ChatCell *cell;
        static NSString *CellIdentifier;
        CellIdentifier = @"chatCell";
        cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        cell.delegate = self;
   
        NSMutableArray *mensajes_en_dia = [self.mensajes objectForKey:fecha];
        ChatMessage *msg = [mensajes_en_dia objectAtIndex:([mensajes_en_dia count ]-1)-indexPath.row];
        cell.message = msg;
        cell.myId = self.myId;
        return cell;
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    NSString *fecha = [self.dias objectAtIndex:([self.dias count]-indexPath.section)-1];
    if ([fecha isEqualToString:@"vermas"]){
        return 38;
    } else {
        NSMutableArray *mensajes_en_dia = [self.mensajes objectForKey:fecha];
        ChatMessage *msg = [mensajes_en_dia objectAtIndex:([mensajes_en_dia count ]-1)-indexPath.row];

        CGSize size;
        float alto = 0;
        if ([msg.tipo intValue] == 1) {
            NSString *strTexto = msg.text;
            UIFont *font = [UIFont systemFontOfSize:17.0f];
            size = [strTexto sizeWithFont:font constrainedToSize:CGSizeMake(MAX_WIDTH, 2000)];
            alto = size.height + TOP_MARGIN+15;
        } else if ([msg.tipo intValue] == 2) {
            alto = 60+20;
            
        } else if ([msg.tipo intValue] == 3) {
            alto = 39 + 10;
        }
        return alto;
    }
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *fecha = [self.dias objectAtIndex:([self.dias count]-section)-1];
    if ([fecha isEqualToString:@"vermas"]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,0, 0)];
        return view;
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setLocale:[NSLocale systemLocale]];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        NSString *hoy = [dateFormat stringFromDate:[NSDate date]];
        
        if ([hoy isEqualToString:fecha]) {
            fecha = @"Hoy";
        } else {
            NSDate *dateAyer = [[NSDate date] dateByAddingTimeInterval:60*60*24*(-1)];
            NSString *ayer = [dateFormat stringFromDate:dateAyer];
            if ([ayer isEqualToString:fecha]) {
                fecha = @"Ayer";
            } else {
                NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
                NSDate *date2 = [dateFormat dateFromString:fecha];
                [dateFormat2 setDateFormat:@"d MMMM EEEE , YYYY"];
                fecha = [dateFormat2 stringFromDate:date2];
            }
        }
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 120)];
        view.backgroundColor = [UIColor clearColor];
        UIFont *dateFont = [UIFont systemFontOfSize:13.0f];
        CGSize sizeFecha = [fecha sizeWithFont:dateFont constrainedToSize:CGSizeMake(320, 2000)];
        UILabel *lblFecha = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-sizeFecha.width) /2,0,sizeFecha.width+20,sizeFecha.height)];
        lblFecha.backgroundColor = [UIColor clearColor];
        lblFecha.textColor = [UIColor foregroundColor];
        lblFecha.font = dateFont;
        lblFecha.text = fecha;
        lblFecha.textAlignment = NSTextAlignmentCenter;
        CGRect frame = lblFecha.frame;
        
        /*
        CGRect frameFondoFecha = CGRectMake(frame.origin.x, frame.origin.y-1, frame.size.width, frame.size.height+2);
         UIView *fondoFecha = [[UIView alloc] initWithFrame:frameFondoFecha];
        [fondoFecha.layer setCornerRadius:3.0f];
        [fondoFecha.layer setMasksToBounds:YES];
        fondoFecha.layer.borderColor = [UIColor lightGrayColor].CGColor;
        fondoFecha.layer.borderWidth = 1.0f;
        [fondoFecha setBackgroundColor:[UIColor colorWithPatternImage:[self generaDegradado]]];
        [fondoFecha.layer setCornerRadius:5.0f];
        [fondoFecha.layer setMasksToBounds:YES];
        fondoFecha.layer.borderColor = [UIColor lightGrayColor].CGColor;
        fondoFecha.layer.borderWidth = 1.0f;
        */
        CGRect frameFondoFecha = CGRectMake(frame.origin.x, frame.origin.y-2, sizeFecha.width+20, 20);
        UIImageView *fondoFecha = [[UIImageView alloc] initWithFrame:frameFondoFecha];
        [fondoFecha setImage:[UIImage imageNamed:@"fecha.png"]];
        
        
        
        [view addSubview:fondoFecha];
        [view addSubview:lblFecha];
        
        return view;
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *fecha = [self.dias objectAtIndex:([self.dias count]-section)-1];
    if ([fecha isEqualToString:@"vermas"]) {
        return 3;
    } else {
        return 15;
    }
}


- (IBAction) masAcciones {
    
    [self textFieldShouldReturn:self.texto];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.is_ipad) {
        } else {
            if (self.is_iphone5) {
                self.menuInferior.frame = CGRectMake(0, 268  , 320, 240);
            } else {
                self.menuInferior.frame = CGRectMake(0, 190  ,320, 240);
            }
        }
        }completion:^(BOOL finished){
    }];
}

/*
- (IBAction) doFoto {
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (IBAction) selectFoto {
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (IBAction) selectVideo {

    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [self presentViewController:imagePicker animated:YES completion:nil];
}



- (IBAction) enviaLoc {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *latitud = [[NSString alloc] initWithFormat:@"%f", appDelegate.latitudActual];
    NSString *longitud = [[NSString alloc] initWithFormat:@"%f", appDelegate.longitudActual];
    NSString *loc_text = [[NSString alloc] initWithFormat:@"%@,%@",latitud,longitud];
    NSArray *valores = [[NSArray alloc] initWithObjects:loc_text,self.userId,@"3" ,nil];
    NSArray *parametros = [[NSArray alloc] initWithObjects:@"text",@"to",@"type",nil];
    NSMutableDictionary *datos = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:parametros];
    [self.delegate enviaMensaje:datos];
    self.texto.text = @"";
    [self recarga];
    [self cerrarMenu];
}
*/

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.segmentedOpen){
        [self.segmentedControl removeFromSuperview];
        self.segmentedOpen = NO;
        self.selCell.segmentedControl = NULL;
        [self.selCell setNeedsLayout ];
    }
    if (self.texto.editing) {
        [self textFieldShouldReturn:self.texto];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction) cerrarMenu {
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.is_ipad) {
            
        } else {
            if (self.is_iphone5) {
                self.menuInferior.frame = CGRectMake(0, 568  , 320, 240);
            } else {
                self.menuInferior.frame = CGRectMake(0, 460  ,320, 240);
            }
        }
    }completion:^(BOOL finished){
    }];
}

/*
- (void) verLocalizacion:(ChatMessage *)msg {
    
    if ([msg.tipo intValue] == 3){
        self.showLoc = msg;
        [self performSegueWithIdentifier: @"mapSegue" sender: self];
        
    } else if ([msg.tipo intValue] == 2) {
        UIStoryboard *socialStoryboard = [UIStoryboard storyboardWithName:@"SocialStoryboard" bundle: nil];
        imgChatViewController = (ImgChatViewController *)[socialStoryboard instantiateViewControllerWithIdentifier:@"ImgChatViewController"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [imageCache getChatCachedImage:msg.text];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img2 = [ImageCache redimensionaImage:img maxWidth:320 andMaxHeight:480];
                float alto;
                float ancho;
                if (self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft ||self.interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
                    alto = 320;
                    ancho = 480;
                } else {
                    alto = 480;
                    ancho = 320;
                }
                float pos_x = (ancho-img2.size.width)/2;
                float pos_y = (alto-img2.size.height)/2;
                CGRect frame = CGRectMake(pos_x, pos_y,img2.size.width,img2.size.height);
                self.imgChatViewController.imagen.frame = frame;
                [self.imgChatViewController.imagen setImage:img2];
                self.imgChatViewController.originalImagen = img;
            });
        });
        [self presentViewController:imgChatViewController animated:YES completion:nil];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"mapSegue"]) {
        MapaViewController *mapViewController = (MapaViewController *)[segue destinationViewController];
        mapViewController.locToShow = self.showLoc;
    } else if ([[segue identifier] isEqualToString:@"segue_profile"]) {
        ProfileUsersViewController *profileViewController = (ProfileUsersViewController *)[segue destinationViewController];
        profileViewController.idUser = self.userId;
        profileViewController.ocultar = YES;
    }
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"segue_profile"]) {
        PerfilUsuarioViewController *perfilViewController = (PerfilUsuarioViewController *)[segue destinationViewController];
        perfilViewController.ultimoMensaje = self.ultimoMensaje;
        perfilViewController.delegate = self;
    }
}


#pragma mark - Image Picker Delegate Methods

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    NSLog(@"IMAGE PICKER finish");
    
    [imagePicker dismissModalViewControllerAnimated:YES];
    [self cerrarMenu];
    image = [self fixrotation:image];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
        NSString *imgStr = [imageData base64EncodedString];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *valores = [[NSArray alloc] initWithObjects:imgStr,self.userId,@"2" ,nil];
            NSArray *parametros = [[NSArray alloc] initWithObjects:@"text",@"to",@"type",nil];
            NSMutableDictionary *datos = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:parametros];
            [self.delegate enviaMensaje:datos];
            self.texto.text = @"";
            [self recarga];
        });
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString: (NSString *) kUTTypeImage ]) {
        //Foto
        
        UIImage *image = [self fixrotation:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
            NSString *imgStr = [imageData base64EncodedString];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *valores = [[NSArray alloc] initWithObjects:imgStr,self.userId,@"2" ,nil];
                NSArray *parametros = [[NSArray alloc] initWithObjects:@"text",@"to",@"type",nil];
                NSMutableDictionary *datos = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:parametros];
                [self.delegate enviaMensaje:datos];
                self.texto.text = @"";
                [self recarga];
            });
        });

    } else {
        //Video
        NSURL *videoUrl = [info objectForKey:@"UIImagePickerControllerMediaURL"];

        NSString *nombreVideo = @"video.mov";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
            NSString *imgStr = [videoData base64EncodedString];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *valores = [[NSArray alloc] initWithObjects:imgStr,self.userId,@"4",nombreVideo ,nil];
                NSArray *parametros = [[NSArray alloc] initWithObjects:@"text",@"to",@"type",@"videoName",nil];
                NSMutableDictionary *datos = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:parametros];
                [self.delegate enviaMensaje:datos];
                self.texto.text = @"";
                [self recarga];
            });
        });
        
    }
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self cerrarMenu];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self cerrarMenu];
}
*/

- (void) cerrarChat {

    [self.navigationController popViewControllerAnimated:NO];
}


- (void)optionsMensaje:(ChatCell *)cell {

    NSLog(@"En el delegate, optionsMensaje");
    if (self.segmentedOpen == YES){
        self.selCell.segmentedControl=NULL;
        [self.selCell setNeedsLayout];

    }

    self.selCell = cell;
    self.deleteMSg = cell.message;
    //Para ios 7 va bien, pero no en ios 8
    //[cell addSubview:segmentedControl];
    
    
    cell.segmentedControl=self.segmentedControl;
    [cell setNeedsLayout];
    self.segmentedOpen = YES;

}


- (void) deleteMensaje {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete MSG"
                                                    message:@"Do you like to delete message?."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}


- (void) activaBotonSend {
    
    [self.btnEnviar setEnabled:YES];
    
}


- (void) desactivaBotonSend{
    
    NSLog(@"desconectamos el boton, enabled false");
    [self.btnEnviar setEnabled:NO];
    
}


- (void) pickOne:(id)sender{
    
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        [self copiarMensaje];
    } else {
        [self deleteMensaje];
    }
    //[segmentedControl removeFromSuperview];
    self.selCell.segmentedControl = NULL;
    [self.selCell setNeedsLayout ];
    
    self.segmentedOpen = NO;
    
    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
}


- (void) copiarMensaje {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.deleteMSg.text;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self.managedObjectContext deleteObject:self.deleteMSg];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new data with error: %@", [error domain]);
        }
        [self.myTableView reloadData];
    }
}


- (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)bloquear:(NSNumber *)usuarioId estado:(NSNumber *)estado {
    
    [self.delegate bloquear:usuarioId estado:estado];
}





@end
