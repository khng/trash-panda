//
//  LandfillViewController.swift
//  trash-panda
//
//  Created by Pivotal on 2017-05-12.
//
//

import UIKit
import Firebase

class LandfillViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var trash = [Task]()
    let landfillRef = FIRDatabase.database().reference().child("landfill")

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        updateLandfillTable()
    }
    
    // MARK: Tableview datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trash.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        // Configure the cell...
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = trash[indexPath.row].name
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Listener
    func updateLandfillTable() {
        landfillRef.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let task = Task()
                task.name = dictionary["name"] as! String?
                self.trash.append(task)
                self.tableView.reloadData()
            }
            
        })
        
        landfillRef.observe(.childRemoved, with: { (snapshot) in
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
}
