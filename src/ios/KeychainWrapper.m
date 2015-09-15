//
//  KeychainWrapper.h
//  Apple's Keychain Services Programming Guide
//
//  Created by Tim Mitra on 11/17/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "KeychainWrapper.h"

@implementation KeychainWrapper

-(id) initWithService:(NSString *) service_ withGroup:(NSString*)group_ withKey:(NSString *)key_
{
    self =[super init];
    if(self)
    {
        service = [NSString stringWithString:service_];
        key = key_;
        if(group_){
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier]];
            group = [NSString stringWithFormat: @"%@.%@", bundleIdentifier, group_]; 
            NSLog(@"Group ID: %@", group);
        }
            
    }
    
    return  self;
}
-(NSMutableDictionary*) prepareDict
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    [dict setObject:encodedKey forKey:(__bridge id)kSecAttrGeneric];
    [dict setObject:encodedKey forKey:(__bridge id)kSecAttrAccount];
    [dict setObject:service forKey:(__bridge id)kSecAttrService];
    [dict setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    //This is for sharing data across apps
    if(group != nil)
        [dict setObject:group forKey:(__bridge id)kSecAttrAccessGroup];

    return  dict;

}
-(BOOL) insertPassword:(NSString *) password
{
    NSMutableDictionary * dict =[self prepareDict:key];
    [dict setObject:password forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
    if(errSecSuccess != status) {
        NSLog(@"Unable add item with key =%@ error:%ld",key,status);
    }
    return (errSecSuccess == status);
}
-(NSString *) getPassword
{
    NSMutableDictionary *dict = [self prepareDict:key];
    [dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [dict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dict,&result);
    
    if( status != errSecSuccess) {
        NSLog(@"Unable to fetch item for key %@ with error:%ld",key,status);
        return nil;
    }
    
    return (__bridge NSData *)result;
}

-(BOOL) updatePassword:(NSString*) password
{
    NSMutableDictionary * dictKey =[self prepareDict:key];

    NSMutableDictionary * dictUpdate =[[NSMutableDictionary alloc] init];
    [dictUpdate setObject:password forKey:(__bridge id)kSecValueData];

    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)dictKey, (__bridge CFDictionaryRef)dictUpdate);
    if(errSecSuccess != status) {
        NSLog(@"Unable add update with key =%@ error:%ld",key,status);
    }
    return (errSecSuccess == status);

    
    return YES;
    
}
-(BOOL) removePassword
{
    NSMutableDictionary *dict = [self prepareDict:key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dict);
    if( status != errSecSuccess) {
        NSLog(@"Unable to remove item for key %@ with error:%ld",key,status);
        return NO;
    }
    return  YES;
}


@end
