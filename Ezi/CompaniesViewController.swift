//
//  CompaniesViewController.swift
//  Ezi
//
//  Created by Dhruv Mangtani on 7/23/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Alamofire
import GoogleAPIClient
import GTMOAuth2

class CompaniesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var data: [NSArray] = []
    var query: String!
    var location: String!
    
    private let kKeychainItemName = "Gmail API"
    private let kClientID = "669494109637-lhu34loitr7lcltu444qhhsdvj2p4qr6.apps.googleusercontent.com"
    
    private let service = GTLServiceGmail()
    
    private let scopes = ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/prediction"]
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar
        
        var barButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back Button"), style: .Plain, target: self, action: #selector(self.goBack))
        self.navigationItem.leftBarButtonItem = barButtonItem
        //navigationController?.navigationBar.barTintColor = UIColor.purpleColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        searchTextField.layer.cornerRadius =  5
        searchTextField.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fullQuery(location, query: query) { (input) in
            
        }
        
        
        tableView.reloadData()
        
        
    }
    
    func goBack(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        data = []
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if data.count == 0{
            let title = UILabel()
            title.font = UIFont(name: "Futura", size: 38)!
            title.textColor = UIColor.lightGrayColor()
            title.text = "Error 404... No Ratings Found"
            
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font=title.font
            header.textLabel?.textColor=title.textColor
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("companyCell") as! CompanyCell
        let tuple = data[indexPath.row]
        let review = tuple[0]
        let employer = tuple[1]
        let sentiment = tuple[2]
        let score = sentiment["outputLabel"] as! String
        
        let squareLogo = employer["squareLogo"] as! String
        let companyName = employer["name"] as! String
        
        
        cell.nameLabel.text = companyName
        cell.companyLogoView.setImageWithURL(NSURL(string: squareLogo)!)
        
        if Int(score) != nil{
            cell.percentLabel.text = "\(Int(score)! * 10)%"
            let val = Int(score)!
            
            switch(val){
            case let n where n < 2 :
                cell.pigView.image = UIImage(named: "pig-1")
                
            case let n where n<4 && n>=2 :
                cell.pigView.image = UIImage(named: "pig-2")
                
            case let n where n<6 && n>=4 :
                cell.pigView.image = UIImage(named: "pig-3")
                
            case let n where n<8 && n>=6 :
                cell.pigView.image = UIImage(named: "pig-4")
                
            case let n where n<=10 && n>=8 :
                cell.pigView.image = UIImage(named: "pig-5")
                
            default:
                //cell.pigView.image = UIImage(named: "")
                print()
            }
        }else{
            data.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
        //print(dict)
        //print("NEXT")
        return cell
    }
    
    func fullQuery(location: String, query: String, completion: (input: String) -> Void){
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
                
                dispatch_semaphore_signal(sem)
                
                
                // if null pointer exception then check if there are any spaces in the url
                Alamofire.request(.GET, "http://api.glassdoor.com/api/api.htm?t.p=80904&t.k=kCh3z3ITn3Y&userip=0.0.0.0&useragent=&format=json&v=1&action=employers&q=\(query)&city=\(location)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).responseJSON { (response) in
                    if let value = response.result.value as? [String: AnyObject] {
                        let employers = value["response"]!["employers"]!! as! NSArray
                        dispatch_semaphore_signal(sem)
                        //print(employers.count)
                        for i in 0 ..< employers.count {
                            if let review = employers[i]["featuredReview"]! {
                                let q = [
                                    "csvInstance": [
                                        "\(review["pros"]!!) \(review["cons"]!!)"
                                    ]
                                ]
                                
                                parameters.updateValue(q, forKey: "input")
                            
                                print("New Query")
                                self.syncQuery(parameters, accessToken: accessToken, semaphore: sem, employer: employers[i] as! NSDictionary)
                            }
                        }
                        
                    }
                    
                }
                
            }else{
                dispatch_semaphore_signal(sem)
                dispatch_semaphore_signal(sem)
            }
        }
        //NSThread.sleepForTimeInterval(15)
        
        //dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
    }
    
    func syncQuery(parameters: [String:AnyObject], accessToken: String, semaphore: dispatch_semaphore_t, employer: NSDictionary){
        var running = true
        request(.POST, "https://www.googleapis.com/prediction/v1.6/projects/mailanalysis-1378/trainedmodels/GlassdoorContemporaryTrainingData/predict", parameters: parameters, encoding: .JSON, headers: ["Authorization":"Bearer \(accessToken)"])
            .responseJSON { (response) in
                dispatch_semaphore_signal(semaphore)
                if let JSON = response.result.value {
                    print("JSON: \(response)")
                    print(parameters)
                    //print("refresh token = " + auth.accessToken)
                    //completion(input: "we finished!")
                    self.data.append(
                        [
                            parameters,
                            employer,
                            JSON as! NSDictionary
                        ]
                    )
                    
                }
                for _ in self.data{
                    for i in 0 ..< self.data.count-1 {
                        let tuple = self.data[i]
                        let score = Int(tuple[2]["outputLabel"] as! String)
                        if(self.data[i+1].count == 3){
                            let nextScore = Int(self.data[i+1][2]["outputLabel"] as! String)
                            if score < nextScore {
                                let temp = tuple
                                self.data[i] = self.data[i+1]
                                self.data[i+1] = temp
                            }
                        }
                    }
                }
                self.tableView.reloadData()
                running = false
                
        }
        
        //NSThread.sleepForTimeInterval(0.4)
    }
    
}
