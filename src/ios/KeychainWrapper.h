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
	NSString * groupID;
	NSString * key;
}
- (id)initWithGroup:(NSString *)groupID_ withKey:(NSString *)key_;
- (void)mySetObject:(id)inObject forKey:(id)key_;
- (id)myObjectForKey:(id)key_;
- (void)writeToKeychain;

@end
