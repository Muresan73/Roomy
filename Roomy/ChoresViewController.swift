//
//  ChoresViewController.swift
//  Roomy
//
//  Created by Darius on 2015. 04. 10..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import UIKit
import CoreData
import Parse
import ParseUI

struct StoredChores {
    var choresSectionName : [String] = ["Active Chores","Done Chores"]
    var activeChores : [PFObject] = []
    var passiveChores : [PFObject] = []


    subscript(index : Int) -> [PFObject]{
        get{
            var returnValue : [PFObject]!
            if index == 0{
            returnValue = activeChores.filter({ $0["isDone"] as! Bool == false})
            }
            else{
                returnValue = activeChores.filter({ $0["isDone"] as! Bool == true})
            }
            return returnValue
        }
    }
}

class ChoresViewController: UITableViewController,PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate{
    

    var choreStore = StoredChores()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.dataSource = self
        
        fetchChoresFromLocalDatastore()
        
        actualizateData()

        fetchChores()
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshChoresList"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //fetchChoresFromLocalDatastore()
        //fetchChores()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return choreStore[section].count
//        if section == 0 {return choreStore.activeCount}
//            else {return choreStore.doneCount}

    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return choreStore.choresSectionName[section]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("choreItem", forIndexPath: indexPath) as! ChoresTableViewCell
        let chore = choreStore[indexPath.section][indexPath.row]
        cell.choreTitle?.text = (chore["title"] as! String)
        

        cell.choreButton.tag = (indexPath.section*10000) + indexPath.row
        
        if (chore["isDone"] as! Bool == true){
            cell.backgroundColor = UIColor.greenColor()
            cell.choreButton.setTitle("Reset", forState: UIControlState.Normal)
          
        }else{
            cell.backgroundColor = UIColor.orangeColor()
            cell.choreButton.setTitle("Done", forState: UIControlState.Normal)
        }
        
        return cell
    }


    
    func createChoreWithTitle(content: String)
    {
        let moc = AppDelegate.sharedAppDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("Chores",
            inManagedObjectContext:
            moc)
        
        
        let newChore = PFObject(className: "Chores")
        newChore["title"] = content
        newChore["isDone"] = false
        newChore["whoDoneIt"] = NSNull()
        
        actualizateData()
        newChore.saveInBackgroundWithBlock { (succes , error)  in
                if error == nil{
                        self.fetchChoresFromLocalDatastore()
                }
                else{self.choreStore.passiveChores.append(newChore);println("added")}
            }

        newChore.saveEventually()
        
        newChore.pinInBackgroundWithBlock { (bool,error)  in
            self.fetchChoresFromLocalDatastore()
        }

        AppDelegate.sharedAppDelegate.saveContext()
    }
    
    @IBAction func addChoreBarButtonTap(sender: AnyObject) {
        let createNoteAlert = UIAlertController(title: "Create Chore", message: "Enter the content", preferredStyle: .Alert)
        
        createNoteAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Chore todo"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        createNoteAlert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { action in
            let textField = createNoteAlert.textFields!.first! as! UITextField
            if textField.text == "sas" {
                action.enabled = false
            }else {action.enabled = true}
            self.createChoreWithTitle(textField.text)
        }
        
        createNoteAlert.addAction(createAction)
        
        presentViewController(createNoteAlert, animated: true, completion: nil)
        

        //self.tableView.reloadData()
  
    }
    
    func fetchChores() {
 
        if Reachability.isConnectedToNetwork(){
            PFObject.unpinAllInBackground(choreStore.activeChores)
            //PFObject.unpinAllObjectsInBackground()
        }
        var query = PFQuery(className:"Chores")
        //query.whereKey("isDone", equalTo: false)
        query.orderByDescending("createdAt")//.orderByAscending("isDone")
        //query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if let chores = objects as? [PFObject] {
                PFObject.pinAllInBackground(objects, block: nil)
                self.choreStore.activeChores = chores
                //self.fetchChoresFromLocalDatastore()
                self.tableView.reloadData()
            }
        }

    }
    
    func fetchChoresFromLocalDatastore() {
      
        var query = PFQuery(className:"Chores")
        
        query.fromLocalDatastore()
        query.orderByDescending("createdAt")//.orderByAscending("isDone")
        //query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let chores = objects as? [PFObject] {
                
                self.choreStore.activeChores = chores
                self.tableView.reloadData()
            }
        }
        PFObject.pinAllInBackground(self.choreStore.activeChores, block: nil)
    }
    
    @IBAction func choreButtonTap(sender: UIButton) {
        

        let chore = choreStore[sender.tag / 10000][sender.tag % 10000]
        
        var query = PFQuery(className:"Chores")
        
        chore["isDone"] = !(chore["isDone"] as! Bool)
        chore["whoDoneIt"] = PFUser.currentUser()
        
        chore.saveInBackgroundWithBlock { (succes , error)  in
            if error == nil{
                self.fetchChoresFromLocalDatastore()
            }
            else{self.choreStore.passiveChores.append(chore)}
        }
        
        //actualizateData()
        //chore.saveEventually()
        fetchChoresFromLocalDatastore()
        if actualizateData() {fetchChores()}
        //self.tableView.reloadData()
        
        }
   
    
    func actualizateData() -> Bool {
        
//        var succesed = false
//        if !choreStore.passiveChores.isEmpty  {
//            for storeData in choreStore.passiveChores
//            {
//                storeData.saveInBackgroundWithBlock { (succes , error)  in
//                    if(error == nil){
//                    self.fetchChoresFromLocalDatastore()
//                    self.choreStore.passiveChores.removeAll(keepCapacity: false)
//                    succesed = true
//                    }
//                }
//            }
//        }
//        return succesed
return true
    }

    func refreshChoresList(){
        actualizateData()
        fetchChores()
        refreshControl?.endRefreshing()
    }

}
