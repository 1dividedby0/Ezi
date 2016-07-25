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
import AFNetworking

class SearchViewController: UIViewController {
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "669494109637-lhu34loitr7lcltu444qhhsdvj2p4qr6.apps.googleusercontent.com"
    
    private let service = GTLServiceGmail()
    
    var arr:[NSArray] = []
    
    private let scopes = ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/prediction"]
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.layer.cornerRadius = 7
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.clearColor().CGColor
        
        locationTextField.borderStyle = UITextBorderStyle.None
        locationTextField.backgroundColor = UIColor.clearColor()
        locationTextField.textColor = UIColor.whiteColor()
        locationTextField.leftViewMode = .Always
        locationTextField.leftView = UIImageView(image: UIImage(named: "locationiconvector")!)
        
        searchField.borderStyle = UITextBorderStyle.None
        searchField.backgroundColor = UIColor.clearColor()
        searchField.textColor = UIColor.whiteColor()
        searchField.leftViewMode = .Always
        searchField.leftView = UIImageView(image: UIImage(named: "SearchIcon")!)
        
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view!.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: locationTextField.frame.size.height - width, width:  locationTextField.frame.size.width, height: locationTextField.frame.size.height)
        
        border.borderWidth = width
        locationTextField.layer.addSublayer(border)
        locationTextField.layer.masksToBounds = true
        
        locationTextField.attributedPlaceholder = NSAttributedString(string:"Location",
                                                                     attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        let border2 = CALayer()
        let width2 = CGFloat(2.0)
        border2.borderColor = UIColor.whiteColor().CGColor
        border2.frame = CGRect(x: 0, y: searchField.frame.size.height - width2, width:  searchField.frame.size.width, height: searchField.frame.size.height)
        
        border2.borderWidth = width2
        searchField.layer.addSublayer(border2)
        searchField.layer.masksToBounds = true
        
        searchField.attributedPlaceholder = NSAttributedString(string:"Job Title",
                                                               attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    override func viewDidAppear(animated: Bool) {
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        if NSUserDefaults.standardUserDefaults().valueForKey("RT") == nil {
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
    
    @IBAction func search(sender: AnyObject) {
        
        performSegueWithIdentifier("toList", sender: self)
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        //let nav = segue.destinationViewController as! UINavigationController
        let vc = segue.destinationViewController as! CompaniesViewController
        //vc.data = arr
        vc.query = searchField.text!
        vc.location = locationTextField.text!
     }
     
    
}