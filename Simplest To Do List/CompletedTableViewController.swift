//
//  CompletedTableViewController.swift
//  Simplest To Do List
//
//  Created by 蓉蓉 邓 on 8/3/16.
//  Copyright © 2016 Fancy boy. All rights reserved.
//

import UIKit

class CompletedTableViewController: UITableViewController {
    
    var remainLists = [Lists]()

    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        rightButton.style = .done
        let alertAcion = UIAlertAction(title: "确定", style: .default) { (action) in
            self.remainLists = [Lists]()
            self.tableView.reloadData()
            self.savedeletedLists()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: "确定全部删除吗？", message: "所有已完成列表将删除", preferredStyle: .alert)
        alertController.addAction(alertAcion)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
//        let flag = !tableView.isEditing
//        tableView.setEditing(flag, animated: true)
        
        rightButton.isEnabled = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        if let savedLists = loaddeletedLists() {
            remainLists += savedLists
        } else {
            loaddeletedLists()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loaddeletedLists()
        ifRemainingListIsEmpty()
    }
    
    // MARK: NSCoding
    
    @discardableResult func loaddeletedLists() -> [Lists]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveDeletedListsURL.path) as? [Lists]
    }
    
    func savedeletedLists() {
        NSKeyedArchiver.archiveRootObject(remainLists, toFile: ArchiveDeletedListsURL.path)
        
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        loaddeletedLists()
        return remainLists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loaddeletedLists()
        let cell = tableView.dequeueReusableCell(withIdentifier: "completedIdentifier", for: indexPath)

        let list = remainLists[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = list.name

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            remainLists.append(completionLists[indexPath.row])
//            completionLists.removeAtIndex(indexPath.row)
            remainLists.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savedeletedLists()
        }
        ifRemainingListIsEmpty()
    }
    
    func ifRemainingListIsEmpty() {
        if remainLists.count == 0 {
            rightButton.isEnabled = false
        }
    }
    
}
