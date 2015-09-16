/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "TouchIDKeychain.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <Cordova/CDV.h>

@implementation TouchIDKeychain

- (void)isTouchIDAvailable:(CDVInvokedUrlCommand*)command{
    self.laContext = [[LAContext alloc] init];
    BOOL touchIDAvailable = [self.laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if(touchIDAvailable){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"TouchID no se encuentra en este dispositivo o no está activado"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)hasPasswordInKeychain:(CDVInvokedUrlCommand*)command{
    NSString* service = (NSString*)[command.arguments objectAtIndex:0];
    NSString* group = (NSString*)[command.arguments objectAtIndex:1];
    NSString* key = (NSString*)[command.arguments objectAtIndex:2];

    self.MyKeychainWrapper = [[KeychainWrapper alloc] initWithService:service withGroup:group withKey:key];
    
    NSString *password = [self.MyKeychainWrapper getPassword];
    

//    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:gro create:YES];
//    NSData * data = [pasteboard dataForPasteboardType:(NSString*)kUTTypeText];
//    NSString *hasPasswordInKeychain =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if(password != nil){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"No hay password almacenado en keychain"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)savePasswordToKeychain:(CDVInvokedUrlCommand*)command{
    NSString* service = (NSString*)[command.arguments objectAtIndex:0];
    NSString* group = (NSString*)[command.arguments objectAtIndex:1];
    NSString* key = (NSString*)[command.arguments objectAtIndex:2];
    NSString* password = (NSString*)[command.arguments objectAtIndex:3];

    @try {
        self.MyKeychainWrapper = [[KeychainWrapper alloc] initWithService:service withGroup:group withKey:key];
        [self.MyKeychainWrapper insertPassword:password];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch(NSException *exception){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"No se puede guardar la contraseña en el Keychain"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)deleteKeychainPassword:(CDVInvokedUrlCommand*)command{
    NSString* service = (NSString*)[command.arguments objectAtIndex:0];
    NSString* group = (NSString*)[command.arguments objectAtIndex:1];
    NSString* key = (NSString*)[command.arguments objectAtIndex:2];
    @try {
        self.MyKeychainWrapper = [[KeychainWrapper alloc] initWithService:service withGroup:group withKey:key];
        [self.MyKeychainWrapper removePassword];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch(NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Error al eliminar el flag en deleteKeychainPassword"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    
}

-(void)getPasswordFromKeychain:(CDVInvokedUrlCommand*)command{
    self.laContext = [[LAContext alloc] init];
    NSString* service = (NSString*)[command.arguments objectAtIndex:0];
    NSString* group = (NSString*)[command.arguments objectAtIndex:1];
    NSString* key = (NSString*)[command.arguments objectAtIndex:2];

    self.MyKeychainWrapper = [[KeychainWrapper alloc] initWithService:service withGroup:group withKey:key];
    
    NSData *passwordData = [self.MyKeychainWrapper getPassword];
    NSString* password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];

    if(password != nil){
        
        BOOL touchIDAvailable = [self.laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
        
        if(touchIDAvailable){
            [self.laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Ingrese su huella para iniciar sesión automáticamente" reply:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(success){
                        NSMutableDictionary* retorno = [NSMutableDictionary dictionaryWithCapacity:1];
                        [retorno setObject:password forKey:@"password"];
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:retorno];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    if(error != nil) {
                        NSString *message = @"No se puede verificar su identidad. Por favor, ingrese su Pin";

                        UIAlertView * alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alerta show];
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: message];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                
                });
            }];
            
        }
        else{
            // UIAlertView * alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Su dispositivo no cuenta con TouchID" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            // [alerta show];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Su dispositivo no cuenta con TouchID"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
    else{
        UIAlertView * alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No se ha encontrado una contraseña guardada. Para guardar la contraseña enrolese nuevamente en la aplicación." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alerta show];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"No se ha encontrado una contraseña guardada. Para guardar la contraseña enrolese nuevamente en la aplicación."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void) authorizeOperation:(CDVInvokedUrlCommand*)command{
    self.laContext = [[LAContext alloc] init];
    
    BOOL touchIDAvailable = [self.laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    
    if(touchIDAvailable){
        [self.laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Ingrese su huella para autorizar la operación" reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success){
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
                if(error != nil) {
                    NSString *message = @"No se puede verificar su identidad. No se realizarán cambios";
                    //Retorna error
                    UIAlertView * alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alerta show];
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: message];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            });
        }];
        
    }
    else{
        // UIAlertView * alerta = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Su dispositivo no cuenta con TouchID" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        // [alerta show];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Su dispositivo no cuenta con TouchID"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

@end
