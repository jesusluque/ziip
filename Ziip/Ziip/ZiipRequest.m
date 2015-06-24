//
//  ZiipRequest.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipRequest.h"
#import "Define.h"
#import "Reachability.h"
#import "JSONKit.h"


@implementation ZiipRequest



- (void) send:(NSString *)action tipo_peticion:(NSString* )tipo_peticion withParams:(NSMutableArray *)parametros andValues:(NSMutableArray *)valores enviarToken:(bool)enviarToken {
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus =  [internetReachable currentReachabilityStatus];
    
    if (internetStatus != NotReachable){
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *completeUrl = [[[NSString alloc] initWithFormat:@"%@%@",CONEXION_URL,action]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (parametros == nil) {

            parametros = [[NSMutableArray alloc] init];
            valores = [[NSMutableArray alloc] init];
            
        }
        if ([parametros count] ==[valores count]) {
            if ([action rangeOfString:@"status"].location != NSNotFound) {
                if ([defaults objectForKey:@"fechaUltimoMensaje"]) {
                    [parametros addObject:@"lastMessage"];
                    [valores addObject:[defaults objectForKey:@"fechaUltimoMensaje"]];
                }
            }
            
            NSString *parametros_procesados = [self procesa_parametros:parametros conValores:valores ];

            NSMutableURLRequest *request;
            if ([tipo_peticion isEqualToString:@"GET"]) {
                completeUrl = [[[NSString alloc] initWithFormat:@"%@?%@",completeUrl,parametros_procesados]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString:completeUrl]];
            } else {
                request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString:completeUrl]];
                [request setHTTPBody:[parametros_procesados dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [request setHTTPMethod:tipo_peticion];
            
            [request setValue:[NSString stringWithFormat:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"] forHTTPHeaderField:@"Accept"];
            
            if (enviarToken){
                
                if ([defaults objectForKey:@"api_auth_token"]){
                    [request setValue:[defaults objectForKey:@"api_auth_token"] forHTTPHeaderField:@"X-Auth-Token"];
                    
                }
            }
            [self.delegate showLoading];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                [self.delegate hideLoading];
                NSString *str_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"str_Data: %@",str_data);
                if (error == nil) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                    NSLog(@"resultado: %@",result);

                    [self.delegate recibeDatos:result];
                } else {
                    
                    //NSLog(@"%@",error);
                    [self.delegate muestra_fallo_red];
                }
            }];
            
        }
    } else {
        //no hay CONEXION_URL
        [self.delegate muestra_fallo_red];
    }
}



- (void) send:(NSString *)action tipo_peticion:(NSString* )tipo_peticion withParams:(NSMutableArray *)parametros andValues:(NSMutableArray *)valores imagenes:(NSArray *)imagenes enviarToken:(bool)enviarToken {
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus =  [internetReachable currentReachabilityStatus];
    
    if (internetStatus != NotReachable){
        
        
        NSString *completeUrl = [[[NSString alloc] initWithFormat:@"%@%@",CONEXION_URL,action]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",completeUrl);
        if ([parametros count] ==[valores count]) {
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString:completeUrl]];
            [request setHTTPMethod:tipo_peticion];
            
            
            NSString *boundary = @"0xKhTmLbOuNdArY"; // This is important! //NSURLConnection is very sensitive to format.
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            
            for (UIImage *imagen in imagenes ){
                NSLog(@"enviando imagen");
                
                NSData* fileData = UIImageJPEGRepresentation (imagen,1);
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"imagen\"; filename=\"image.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:fileData]];
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            int i=0;
            NSString *parametros_procesados = [self procesa_parametros:parametros conValores:valores ];
            NSLog(@"parametros:%@",parametros_procesados);
            unsigned long numItems=parametros.count;
            for (i=0;i<numItems; i++) {
                
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",[parametros objectAtIndex:i ] ] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[valores objectAtIndex:i ] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            [request setHTTPBody:body];
            
            if (enviarToken){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults objectForKey:@"api_auth_token"]){
                    [request setValue:[defaults objectForKey:@"api_auth_token"] forHTTPHeaderField:@"X-Auth-Token"];
                }
            }
            
            
            [self.delegate showLoading];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                //NSLog(@"%@",data);
                [self.delegate hideLoading];
                if (error == nil) {
                    
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
                    
                    //NSDictionary *result=[data objectFromJSONDataWithParseOptions:JKSerializeOptionEscapeUnicode];
                    
                    //NSLog(@"%@",result);
                    [self.delegate recibeDatos:result];
                } else {
                    NSLog(@"%@",error);
                    [self.delegate muestra_fallo_red];
                }
            }];
            
        }
    } else {
        //no hay CONEXION_URL
        [self.delegate muestra_fallo_red];
    }
}


- (NSString *) procesa_parametros: (NSArray *) parametros conValores: (NSArray *) valores {
    
    NSString *cadena=[[NSString alloc]init];
    NSUInteger i;
    unsigned long numItems=parametros.count;
    
    if (numItems >0) {
        cadena = [NSString stringWithFormat:@"%@=%@",[parametros objectAtIndex:0],[valores objectAtIndex:0]];
    }
    for (i=1;i<numItems; i++) {
        cadena = [NSString stringWithFormat:@"%@&%@=%@",cadena,[parametros objectAtIndex:i],[valores objectAtIndex:i]];
    }
    return [cadena stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}





@end
