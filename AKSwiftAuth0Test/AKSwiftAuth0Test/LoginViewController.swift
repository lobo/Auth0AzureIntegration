//
//  LoginViewController.swift
//  AKSwiftAuth0Test
//
//  Created by Iuliia Zhelem on 10.08.16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

class LoginViewController:UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func clickLoginButton(sender: AnyObject) {
        
        let success = { (profile: A0UserProfile, token: A0Token) in
            Auth0Keychain().storeToken(token, profile: profile)
            self.getDeligationToken()
        }
        let failure = { (error: NSError) in
            Auth0Alert().showMessage("\(error)", sender: self)
        }
        let lock = A0Lock.sharedLock()
        lock.identityProviderAuthenticator().authenticateWithConnectionName(kWindowsLiveConnectionName, parameters: nil, success: success, failure: failure)
    }
    
    func getDeligationToken() {
        let success = { (delegationToken: [NSObject : AnyObject]) in
            Auth0Keychain().storeDelegateToken(delegationToken["id_token"]as? String)
            self.openAzureMobileServices()
        }
        let failure = { (error: NSError) in
            Auth0Alert().showMessage("\(error)", sender: self)
        }
        
        let idToken:String = Auth0Keychain().retrieveIdToken()!
        let lock = A0Lock.sharedLock()
        let dictionary = [
            kIdTokenKeychainName: idToken,
            A0ParameterAPIType: "wams"]
        let parameters = A0AuthParameters.newWithDictionary(dictionary)
        
        lock.apiClient().fetchDelegationTokenWithParameters(parameters,
                                                            success:success, failure:failure);
        
    }
    
    func openAzureMobileServices() {
        performSegueWithIdentifier("AzureMobileServices", sender: self)
    }
    
}

class Auth0Alert {
    
    func showMessage(message: String, sender: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Auth0", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            sender.presentViewController(alert, animated: true, completion: nil)
        }
        print("\(message)")
    }
}

let kIdTokenKeychainName = "id_token"
let kDelegateTokenKeychainName = "delegate_token"
let kProfileKeychainName = "profile"
let kKeychainName = "Auth0"

class Auth0Keychain {
    
    func storeToken(token:A0Token?, profile:A0UserProfile?)
    {
        self.storeIdToken(token?.idToken)
        self.storeProfile(profile)
    }
    
    func storeIdToken(idToken:String?)
    {
        if let token = idToken {
            let keychain = A0SimpleKeychain(service: kKeychainName)
            keychain.setString(token, forKey: kIdTokenKeychainName)
        }
    }

    func storeDelegateToken(delegateToken:String?)
    {
        if let token = delegateToken {
            let keychain = A0SimpleKeychain(service: kKeychainName)
            keychain.setString(token, forKey: kDelegateTokenKeychainName)
        }
    }

    func storeProfile(profile:A0UserProfile?)
    {
        if let prof = profile {
            let keychain = A0SimpleKeychain(service: kKeychainName)
            keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(prof), forKey: kProfileKeychainName)
        }
    }
    
    func retrieveIdToken() -> String?
    {
        let keychain = A0SimpleKeychain(service: kKeychainName)
        let token = keychain.stringForKey(kIdTokenKeychainName);
        return token;
    }
    
    func retrieveDelegateToken() -> String?
    {
        let keychain = A0SimpleKeychain(service: kKeychainName)
        let token = keychain.stringForKey(kDelegateTokenKeychainName);
        return token;
    }
    
    func retrieveProfile() -> A0UserProfile?
    {
        let keychain = A0SimpleKeychain(service: kKeychainName)
        let data = keychain.dataForKey(kProfileKeychainName)
        let profile = NSKeyedUnarchiver.unarchiveObjectWithData(data!)
        return profile as? A0UserProfile;
    }
    
    func clearData()
    {
        let keychain = A0SimpleKeychain(service: kKeychainName)
        keychain.clearAll()
    }
}
