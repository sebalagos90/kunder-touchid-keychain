var argscheck = require('cordova/argscheck'),
               exec = require('cordova/exec');
               
var touchIDKeychainPlugin = {
	isTouchIDAvailable: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "isTouchIDAvailable", []);
	},
	savePassword: function(service, group, key, password, successCallback, errorCallback) {
		exec(successCallback, errorCallback, "TouchIDKeychain", "savePasswordToKeychain", [service, group, key, password]);
	},
	getPassword: function(service, group, key, successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "getPasswordFromKeychain", [service, group, key]);
	},
	hasPasswordInKeychain: function(service, group, key, successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "hasPasswordInKeychain", [service, group, key]);
	},
	deleteKeychainPassword: function(service, group, key, successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "deleteKeychainPassword", [service, group, key]);
	},
	authorizeOperation: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "TouchIDKeychain", "authorizeOperation", []);
	}
};

module.exports = touchIDKeychainPlugin;