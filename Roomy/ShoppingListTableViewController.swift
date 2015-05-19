//
//  ShoppingListTableViewController.swift
//  Roomy
//
//  Created by Darius on 2015. 05. 17..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import UIKit
import Parse
import CoreData

struct StoredShoppingList {
    var SectionName : [String] = ["Things to Buy","Pending"]
    var activeShoppingList : [PFObject] = []
    var passiveShoppingList : [PFObject] = []
    var pendingShoppingList : [PFObject] = []

    
    var sectionCount:Int{
        get{
            if passiveShoppingList.isEmpty{return 1}
            else{return 2}
        }
    }
    subscript(index : Int) -> [PFObject]{
        get{
            var returnValue : [PFObject]!
            if index == 0{
                returnValue = activeShoppingList.filter({ $0["isPaid"] as! Bool == false})
            }
            else{
                returnValue = activeShoppingList.filter({ $0["isPaid"] as! Bool == true})
            }
            return returnValue
        }
    }
}


class ShoppingListTableViewController: UITableViewController {
    
    var shoppingList = StoredShoppingList()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchShoppingListFromLocalDatastore()
        actualizateData()
        fetchShoppingList()
        
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshShoppingList"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return shoppingList.sectionCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return shoppingList[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shoppingList.SectionName[section]
    }

    
    
    
    func createShoppingListItemWithTitle(content: String)
    {
        let moc = AppDelegate.sharedAppDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("ShoppingList",
            inManagedObjectContext:
            moc)
        
        
        let newShoppingListItem = PFObject(className: "ShoppingList")
        newShoppingListItem["title"] = content
        newShoppingListItem["isPaid"] = false
        newShoppingListItem["whoPaid"] = NSNull()
        newShoppingListItem["cost"] = NSNull()
        
        actualizateData()
        newShoppingListItem.saveInBackgroundWithBlock { (succes , error)  in
            if error == nil{
                self.fetchShoppingListFromLocalDatastore()
            }
            else{self.shoppingList.passiveShoppingList.append(newShoppingListItem);println("added")}
        }
        
        newShoppingListItem.pinInBackgroundWithBlock { (bool,error)  in
            self.fetchShoppingListFromLocalDatastore()
        }
        
        AppDelegate.sharedAppDelegate.saveContext()
    }
    
    
    @IBAction func addShoppingListItemBarButtonTap(sender: AnyObject) {
        let createNoteAlert = UIAlertController(title: "Something to Buy", message: "Enter the content", preferredStyle: .Alert)
        
        createNoteAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Thing to Buy"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        createNoteAlert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { action in
            let textField = createNoteAlert.textFields!.first! as! UITextField
            self.createShoppingListItemWithTitle(textField.text)
        }
        
        createNoteAlert.addAction(createAction)
        
        presentViewController(createNoteAlert, animated: true, completion: nil)
        
    }
    
    func paidShoppingListItemAtRow(position : Int, cost: Int){
        shoppingList.activeShoppingList[position]["isPaid"] = true
        shoppingList.activeShoppingList[position]["whoPaid"] = PFUser.currentUser()
    }
    
    @IBAction func paidShoppingListItemBarButtonTap(sender: UIButton) {
        let createNoteAlert = UIAlertController(title: "Bought Something", message: "Enter the content", preferredStyle: .Alert)
        
        createNoteAlert.addTextFieldWithConfigurationHandler { textField in
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.placeholder = "Cost"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        createNoteAlert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Paid", style: .Default) { action in
            let textField = createNoteAlert.textFields!.first! as! UITextField
            if textField.text.toInt() == nil { action.enabled = false } else {action.enabled = true}
            self.paidShoppingListItemAtRow(sender.tag, cost : textField.text.toInt()!)
        }
        
        createNoteAlert.addAction(createAction)
        
        presentViewController(createNoteAlert, animated: true, completion: nil)
        
    }
    
    func fetchShoppingList() {
        
        if Reachability.isConnectedToNetwork(){
            PFObject.unpinAllInBackground(shoppingList.activeShoppingList)
            //PFObject.unpinAllObjectsInBackground()
        }
        var query = PFQuery(className:"ShoppingList")
        query.whereKey("isPaid", equalTo: false)
        query.orderByDescending("createdAt")//.orderByAscending("isPaid")
        //query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if let shoppingListItems = objects as? [PFObject] {
                PFObject.pinAllInBackground(objects, block: nil)
                self.shoppingList.activeShoppingList = shoppingListItems
                self.tableView.reloadData()
            }
        }
        
    }
    
    func fetchShoppingListFromLocalDatastore() {
        
        var query = PFQuery(className:"ShoppingList")
        query.fromLocalDatastore()
        query.whereKey("isPaid", equalTo: false)
        query.orderByDescending("createdAt")//.orderByAscending("isPaid")
        //query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let shoppingListItems = objects as? [PFObject] {
                
                self.shoppingList.activeShoppingList = shoppingListItems
                self.tableView.reloadData()
            }
        }
        PFObject.pinAllInBackground(self.shoppingList.activeShoppingList, block: nil)
    }
    
    
    func actualizateData() -> Bool {
        
        var succesed = false
        if !shoppingList.passiveShoppingList.isEmpty  {
            for storeData in shoppingList.passiveShoppingList
            {
                storeData.saveInBackgroundWithBlock { (succes , error)  in
                    if(error == nil){
                        self.fetchShoppingListFromLocalDatastore()
                        self.shoppingList.passiveShoppingList.removeAll(keepCapacity: false)
                        succesed = true
                    }
                }
            }
        }
        return succesed
    }
    
    func refreshShoppingList(){
        actualizateData()
        fetchShoppingList()
        refreshControl?.endRefreshing()
    }
}
