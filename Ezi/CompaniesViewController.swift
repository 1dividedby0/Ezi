//
//  CompaniesViewController.swift
//  Ezi
//
//  Created by Dhruv Mangtani on 7/23/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit

class CompaniesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var data: [NSArray]!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        print(data)
        tableView.dataSource = self
        tableView.delegate = self
        for j in data{
            for i in 0 ..< data.count-1 {
                let tuple = data[i]
                let score = Int(tuple[2]["outputLabel"] as! String)
                let nextScore = Int(data[i+1][2]["outputLabel"] as! String)
                if score < nextScore {
                    let temp = tuple
                    data[i] = data[i+1]
                    data[i+1] = temp
                }
            }
        }
        tableView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        
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
        
        cell.percentLabel.text = score
        cell.nameLabel.text = companyName
        cell.companyLogoView.setImageWithURL(NSURL(string: squareLogo)!)
        
        if Int(score) != nil{
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
        }
        //print(dict)
        //print("NEXT")
        return cell
    }
    
}
