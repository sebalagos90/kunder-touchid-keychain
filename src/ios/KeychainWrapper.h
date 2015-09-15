//
//  KeychainWrapper.h
//  Apple's Keychain Services Programming Guide
//
//  Created by Tim Mitra on 11/17/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface KeychainWrapper : NSObject
{
	NSString * service;
    NSString * group;
    NSString * key;
}
-(id) initWithService:(NSString *) service_ withGroup:(NSString*)group_ withKey:(NSString *)key_;
-(BOOL) insertPassword: (NSString *)password;
-(BOOL) updatePassword: (NSString *) password;
-(BOOL) removePassword;
-(NSString *) getPassword;

@end
