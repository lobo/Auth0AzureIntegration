# Auth0AzureIntegration

This sample exposes how to integrate Auth0 into your Windows Azure application for authentication with Microsoft Account.

Actually it is Windows Azure Mobile App example which you can download from Azure portal with changes for integration of Auth0 authentication

I. You need to create Azure Mobile Apps as described [here](https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-ios-get-started/),then you can download the Azure test application.

II. Auth0: Configure Microsoft Account as described in [here](https://auth0.com/docs/connections/social/microsoft-account)

![Microsoft Account](https://cloud.githubusercontent.com/assets/5472858/17613278/104f879e-6064-11e6-8d91-eab521076591.png)

III. Set up Authentication on Azure App Service

Log onto the Azure Portal, click on `All Resources`, then in your Azure Mobile Apps application (from Step 1).  

Click on `All Settings`, then `Authentication / Authorization`. Now you are in the right place to start setting up the authentication.

Turn `App Service Authentication` on

Set the action to take when the request is not authenticated to `Allow request`

Turn the `Token Store` to on (under `Advanced Settings`).

Now click on Microsoft Account. Cut and paste the `Client ID` and `Client Secret` from Step 2, and select the same boxes as you did in Step 2 – these are the claims you are requesting to be provided to you.
![Azure Portal](https://cloud.githubusercontent.com/assets/5472858/17613279/1053348e-6064-11e6-9361-a585b7015b12.png)

IV. Restrict permissions to authenticated users

In your Mobile App's Settings, click Easy Tables and select your table. Click `Change permissions`, select Authenticated access only for all permissions, then click `Save`. 
![](https://cloud.githubusercontent.com/assets/5472858/17613280/105a99f4-6064-11e6-80e9-5d62b75689b1.png)

V. Auth0: Enabling WAMS add-on for your client

Clients -> your client -> Addons -> Microsoft Azure Mobile Services

NOTE: With App Services/Mobile Apps, the master key is no longer used/required, that is why it is no longer available on the portal. You can just enter some symbols in the field “Master Key”.
![](https://cloud.githubusercontent.com/assets/5472858/17613281/1061ddae-6064-11e6-8925-0282199a2fbe.png)

Then you can integrate Auth0 into your Azure applocation. 
For this you need to add 
```
pod 'Lock', '~> 1.26'
pod 'SimpleKeychain'
```
to your pod-file

And `Auth0ClientId` and `Auth0Domain` to your Info.plist

#### Important Snippets

Note: All these snippets are located in the `AppDelegate.swift`, `LoginViewController.swift` and `ToDoTableViewController.swift` files.

##### 1. Register the authenticator 
```swift
    let windowslive = A0WebViewAuthenticator(connectionName: "windowslive", lock: A0Lock.sharedLock())
    A0Lock.sharedLock().registerAuthenticators([windowslive]);
```
##### 2. Login to Microsoft Account 
```swift
    A0Lock.sharedLock().identityProviderAuthenticator().authenticateWithConnectionName("windowslive", 
	parameters: nil, success: success, failure: failure)
```
##### 3. Get a delegation token for WAMS as described in https://auth0.com/docs/libraries/lock-ios/delegation-api 
```swift
  let idToken = ...
  let dictionary = [
            “id_token": idToken,
    A0ParameterAPIType: "wams"]
  let parameters = A0AuthParameters.newWithDictionary(dictionary)
        
  A0Lock.sharedLock().apiClient().fetchDelegationTokenWithParameters(parameters,
    success:success, failure:failure);
```
##### 4. Use the delegation token for WAMS 
```swift
  let client = MSClient(applicationURLString: "https://<Your_Azure_Mobile_App_Name>.azurewebsites.net")
        
  let token = //delegation token
  let userId = //Microsoft Account user id
  let user:MSUser = MSUser(userId: userId)
  user.mobileServiceAuthenticationToken = token;        
  client.currentUser = user;
```
Before using the example please make sure that you change some keys in the `Info.plist` file with your data:
- Auth0ClientId
- Auth0Domain

For more information about how to integrate Auth0 with Azure Mobile Apps please see the following links:

* [Link 1](https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-migrating-from-mobile-services/)

* [Link 2](https://shellmonger.com/2016/03/22/integrating-auth0-with-azure-mobile-apps-javascript-client/)

* [Link 3](https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-how-to-configure-microsoft-authentication/)

* [Link 4](https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-ios-get-started-users/)

* [Link 5](https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-ios-how-to-use-client-library/)

* [Link 6](https://auth0.com/blog/Authenticate-Azure-Mobile-Services-apps-with-Everything-using-Auth0/)

