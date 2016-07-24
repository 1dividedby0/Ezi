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
        let sentiment = tuple[1]
        
        //print(dict)
        //print("NEXT")
        return cell
    }
    
}
