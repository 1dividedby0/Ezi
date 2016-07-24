//
//  SearchViewController.swift
//  MailAnalysis
//
//  Created by Dhruv Mangtani on 7/23/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2
import Alamofire

class SearchViewController: UIViewController {
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "669494109637-lhu34loitr7lcltu444qhhsdvj2p4qr6.apps.googleusercontent.com"
    
    private let service = GTLServiceGmail()
    
    private let scopes = ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/prediction"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundHomeScreen")!)
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey("RT") != nil {
            
            fullQuery { (input) in
                print("")
            }
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fullQuery( completion: (input: String) -> Void){
        var parameters:[String:AnyObject] = [
            "access_token" : "ya29.Ci8oA9Bp2i8EsyDFZoZ7sOvt7JdVTKitgHFJRLtx_Qp-_rVmkXWpWOMh96tzNAyfEA",
            "input": [
                "csvInstance": [
                    "Sont des mots"
                ]
            ],
            "Content-Type": "application/JSON"
        ]
        
        let url = "https://www.googleapis.com/oauth2/v4/token"
        
        let refresh_token = NSUserDefaults.standardUserDefaults().objectForKey("RT") as! String
        
        print(refresh_token)
        let atparams = [
            "client_id": kClientID,
            "refresh_token": refresh_token,
            "grant_type": "refresh_token"
        ]
        let headers = [:]
        
        let sem = dispatch_semaphore_create(0)
        Alamofire.request(.POST, url, parameters: atparams, encoding: .URL, headers: headers as! [String : String]).responseJSON { (response) in
            var accessToken = ""
            if let validResponse = response.result.value as? [String : AnyObject] {
                if let access_token = validResponse["access_token"]{
                    parameters["access_token"] = access_token as! String
                    print(access_token)
                    accessToken = access_token as! String
                }
            }
            
            if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
                self.kKeychainItemName,
                clientID: self.kClientID,
                clientSecret: nil) {
                self.service.authorizer = auth
                print(self.service.authorizer.canAuthorize)
                //Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders?.updateValue("application/json", forKey: "Content-Type")
                
                dispatch_semaphore_signal(sem)
                
                Alamofire.request(.GET, "http://api.glassdoor.com/api/api.htm?t.p=80904&t.k=kCh3z3ITn3Y&userip=0.0.0.0&useragent=&format=json&v=1&action=employers").responseJSON { (response) in
                    if let value = response.result.value as? [String: AnyObject] {
                        let employers = value["response"]!["employers"]!! as! NSArray
                        dispatch_semaphore_signal(sem)
                        //print(employers.count)
                        for i in 0 ..< employers.count {
                            let q = [
                                "csvInstance": [
                                    "\(employers[i]["featuredReview"]!!["pros"]!!)"
                                ]
                            ]
                            parameters.updateValue(q, forKey: "input")
                            print("New Query")
                            self.syncQuery(parameters, accessToken: accessToken, semaphore: sem)
                        }
                    }
                }
            }else{
                dispatch_semaphore_signal(sem)
                dispatch_semaphore_signal(sem)
            }
        }
        
        while dispatch_semaphore_wait(sem, DISPATCH_TIME_NOW) != 0{
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 10))
        }
        while dispatch_semaphore_wait(sem, DISPATCH_TIME_NOW) != 0{
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 10))
        }
        while dispatch_semaphore_wait(sem, DISPATCH_TIME_NOW) != 0{
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 10))
        }
        
    }
    
    func syncQuery(parameters: [String:AnyObject], accessToken: String, semaphore: dispatch_semaphore_t){
        request(.POST, "https://www.googleapis.com/prediction/v1.6/projects/mailanalysis-1378/trainedmodels/SentimentAnalysisDataset/predict", parameters: parameters, encoding: .JSON, headers: ["Authorization":"Bearer \(accessToken)"])
            .responseJSON { (response) in
                dispatch_semaphore_signal(semaphore)
                //if let JSON = response.result.value {
                print("JSON: \(response)")
                //print("refresh token = " + auth.accessToken)
                //completion(input: "we finished!")
                //}
        }
    }
    
    // Creates the auth controller for authorizing access to Gmail API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    // Handle completion of the authorization process, and update the Gmail API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
            
        }
        var mutableReq = NSMutableURLRequest()
        
        authResult.authorizeRequest(mutableReq) { (error) in
            if error == nil{
                // request has been authorized
                
            }
        }
        GTMOAuth2ViewControllerTouch.saveParamsToKeychainForName(kKeychainItemName, authentication: authResult)
        service.authorizer = authResult
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(authResult.refreshToken, forKey: "RT")
        dismissViewControllerAnimated(true, completion: nil)
        fullQuery { (input) in
            
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
