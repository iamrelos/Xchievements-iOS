//
//  AchievementsVC.swift
//  xchievements
//
//  Created by Christian Soler on 11/26/15.
//  Copyright © 2015 Christian Soler. All rights reserved.
//

import UIKit
import Parse

class AchievementsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var game: PFObject!
    var achievements = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getAchievements()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        
        let data = self.achievements[indexPath.row]
        let bannerIV = cell.viewWithTag(1) as! UIImageView
        let titleLB = cell.viewWithTag(2) as! UILabel
        let descriptionLB = cell.viewWithTag(3) as! UILabel
        
        bannerIV.af_setImageWithURL(NSURL(string: data["imageUrl"] as! String)!, placeholderImage: UIImage(named:"Xchievements-Logo")!)
        titleLB.text = data["title"] as? String
        descriptionLB.text = data["description"] as? String
        
        self.removeDividerPadding(cell)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.achievements.count
    }
    
    private func getAchievements(){
        let query = PFQuery(className:"Achievements")
        query.whereKey("gameId", equalTo: self.game["gameId"] as! String)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.achievements = objects!
                self.tableView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    private func removeDividerPadding(cell: UITableViewCell){
        // Remove seperator inset
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
}
