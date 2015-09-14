var argscheck = require('cordova/argscheck'),
               exec = require('cordova/exec');
               
var touchIDKeychainPlugin = {
	isTouchIDAvailable: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "isTouchIDAvailable", []);
	},
	savePassword: function(password, group, key, successCallback, errorCallback) {
		exec(successCallback, errorCallback, "TouchIDKeychain", "savePasswordToKeychain", [password, group, key]);
	},
	getPassword: function(group, key, successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "getPasswordFromKeychain", [group, key]);
	},
	hasPasswordInKeychain: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "hasPasswordInKeychain", []);
	},
	deleteKeychainPassword: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "deleteKeychainPassword", []);
	},
	authorizeOperation: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "authorizeOperation", []);
	}
};

module.exports = touchIDKeychainPlugin;