//
//  MainTableViewController.swift
//  trash-panda
//
//  Created by Pivotal on 2017-05-10.
//
//

import UIKit
import Firebase

class MainTableViewController: UITableViewController {
    
    let trashRef = FIRDatabase.database().reference().child("trash")
    var trash = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchName()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trash.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        // Configure the cell...
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = trash[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let cell = self.tableView.cellForRow(at: indexPath)
            let value = cell?.textLabel?.text
            
            removeEntryFromDatabaseWith(value!)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Feed") { (action, indexPath) in
        // can change to image -> read here: http://stackoverflow.com/questions/29421894/uitableviewrowaction-image-for-title
            let cell = self.tableView.cellForRow(at: indexPath)
            let value = cell?.textLabel?.text
            
            self.removeEntryFromDatabaseWith(value!)
        }
        return [delete]
    }
    
    // MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if sender.source is AddTaskViewController {
            // populate data
        }
    }
    
    // MARK: Listener
    func fetchName() {
        trashRef.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let task = Task()
                task.name = dictionary["name"] as! String?
                self.trash.append(task)
                self.tableView.reloadData()
            }
            
        })
        
        trashRef.observe(.childRemoved, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                self.removeElementInTrashMatching((dictionary["name"] as! String?)!)
                self.tableView.reloadData()
            }
            
        })
    }
    
    // MARK: Helper Methods
    func removeElementInTrashMatching(_ name: String) {
        for index in 0...self.trash.count-1 {
            if name == self.trash[index].name {
                trash.remove(at: index)
                break
            }
        }
    }
    
    func removeEntryFromDatabaseWith(_ name: String) {
        let queryRef = trashRef.queryOrdered(byChild: "name")
            .queryEqual(toValue: name)
        
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var check: Bool = true
            for snap in snapshot.children {
                if check {
                    let userSnap = snap as! FIRDataSnapshot
                    let uid = userSnap.key
                    self.trashRef.child(uid).removeValue()
                    check = false
                }
            }
        })
    }

}
