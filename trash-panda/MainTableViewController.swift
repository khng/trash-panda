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
    
    var trash = [Task]()
    let trashRef = FIRDatabase.database().reference().child("trash")
    let landfillRef = FIRDatabase.database().reference().child("landfill")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTasks()
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
    func fetchTasks() {
        trashRef.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let task = Task()
                task.name = dictionary["name"] as! String?
                task.timeStamp = dictionary["timestamp"] as! Int?
                self.trash.append(task)
                self.tableView.reloadData()
            }
            
        })
        
        trashRef.observe(.childRemoved, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let taskName = dictionary["name"] as? String ?? ""
                let taskTimestamp = dictionary["timestamp"] as? Int ?? 0
                self.removeElementInTrashMatching(taskName, taskTimestamp)
                self.tableView.reloadData()
            }
            
        })
    }
    
    // MARK: Helper Methods
    func removeElementInTrashMatching(_ name: String, _ timestamp: Int) {
        for index in 0...self.trash.count-1 {
            if name == self.trash[index].name && timestamp == self.trash[index].timeStamp {
                trash.remove(at: index)
                return
            }
        }
    }
    
    func removeEntryFromDatabaseWith(_ name: String) {
        self.addEntryToLandfillWith(name: name)
        
        let queryRef = trashRef.queryOrdered(byChild: "name")
            .queryEqual(toValue: name)
            .queryLimited(toFirst: 1)
        
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let trashElement = snapshot.children.nextObject() as! FIRDataSnapshot
            self.trashRef.child(trashElement.key).removeValue()
        })
    }
    
    func addEntryToLandfillWith(name text: String) {
        self.landfillRef.childByAutoId().setValue(["name": "\(text)", "timestamp": Int(Date().timeIntervalSince1970)])
    }
}
