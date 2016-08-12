# Auth0AzureIntegration

This sample explains how to integrate Auth0 into your Windows Azure application while authenticating with a Microsoft Account.

Actually, it is a Windows Azure Mobile App example, which you can download from the Azure portal, but that has been modified in order to use Auth0 authentication.


### Step 1: Create an Azure Mobile App
You need to create an Azure Mobile App as described [here](https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-ios-get-started/). Then as `Step III` from that tutorial explains, go ahead and download the Azure test application.


### Step 2: Configure a Microsoft Account
In the Auth0 Dashboard: configure a Microsoft Account as described [here](https://auth0.com/docs/connections/social/microsoft-account).
![Microsoft Account](/media/image1.png)

### Step 3: Set up Authentication on the Azure App Service

Log onto the Azure Portal, click on `All Resources`, then go to your `Azure Mobile App` application (the one from Step 1).  

Click on `All Settings`, then `Authentication / Authorization`. Now you are in the right place to start setting up the authentication.

Now we have to turn `App Service Authentication` on. Set the action you will take when the request is not authenticated to have the value `Allow request`.
In the `Advance Settings` section you may turn the `Token Store` to on.

Now click on your Microsoft Account. Cut and paste the `Client ID` and `Client Secret` from Step 2, and select the same boxes as you did in Step 2 – these are the claims you are requesting to be provided to you.
![Azure Portal](/media/image1.png)

### Step 4: Restrict permissions to authenticated users

In your Mobile App's Settings, click `Easy Tables` and select your table. Click `Change permissions`, select `Authenticated` access only for all permissions, then click `Save`. 
![](/media/image3.png)

### Step 5: Auth0: Enabling WAMS add-on for your client

In the Auth0 Dashboard, head to: `Clients` -> your client -> `Addons` -> `Microsoft Azure Mobile Services`

NOTE: With App Services/Mobile Apps, the master key is no longer used/required, that is why it is no longer available on the portal. You can just enter some symbols in the field `Master Key`.
![](image4.png)

Now you have to integrate Auth0 into your Azure application.

In your `Podfile` add the following:

```
pod 'Lock', '~> 1.26'
pod 'SimpleKeychain'
```

Add `Auth0ClientId` and `Auth0Domain` to your `Info.plist` file.

## Important snippets

Note: All these snippets are located in the `AppDelegate.swift`, `LoginViewController.swift` and `ToDoTableViewController.swift` files.

### 1. Register the authenticator 

```swift
    let windowslive = A0WebViewAuthenticator(connectionName: "windowslive", lock: A0Lock.sharedLock())
    A0Lock.sharedLock().registerAuthenticators([windowslive]);
```
### 2. Login to Microsoft Account 

```swift
    A0Lock.sharedLock().identityProviderAuthenticator().authenticateWithConnectionName("windowslive", 
	parameters: nil, success: success, failure: failure)
```
### 3. Get a delegation token for WAMS as described in https://auth0.com/docs/libraries/lock-ios/delegation-api 

```swift
  let idToken = ...
  let dictionary = [
            “id_token": idToken,
    A0ParameterAPIType: "wams"]
  let parameters = A0AuthParameters.newWithDictionary(dictionary)
        
  A0Lock.sharedLock().apiClient().fetchDelegationTokenWithParameters(parameters,
    success:success, failure:failure);
```
### 4. Use the delegation token for WAMS 

```swift
  let client = MSClient(applicationURLString: "https://<Your_Azure_Mobile_App_Name>.azurewebsites.net")
        
  let token = //delegation token
  let userId = //Microsoft Account user id
  let user:MSUser = MSUser(userId: userId)
  user.mobileServiceAuthenticationToken = token;        
  client.currentUser = user;
```

Before using the example please make sure that you change some keys in Info.plist with your data:
- Auth0ClientId
- Auth0Domain

For more iformation about integrating of auth0 with Azure Mobile Apps please see link

https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-migrating-from-mobile-services/

https://shellmonger.com/2016/03/22/integrating-auth0-with-azure-mobile-apps-javascript-client/ 

https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-how-to-configure-microsoft-authentication/

https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-ios-get-started-users/

https://azure.microsoft.com/en-us/documentation/articles/app-service-mobile-ios-how-to-use-client-library/

https://auth0.com/blog/Authenticate-Azure-Mobile-Services-apps-with-Everything-using-Auth0/

