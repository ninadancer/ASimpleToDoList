//
//  PresentListViewController.swift
//  Simplest To Do List
//
//  Created by 蓉蓉 邓 on 7/31/16.
//  Copyright © 2016 Fancy boy. All rights reserved.
//

import UIKit

class PresentListViewController: UIViewController {
    
    var lists = [Lists]()
    var deletedLists = [Lists]()
    var isLongPressed = false
    var theOne: Lists?
    var theLinkIndexPath: IndexPath?
    var dict: [String:String] = [:]

    @IBOutlet weak var bottomHCons: NSLayoutConstraint!
    @IBOutlet weak var addList: YZInputView!
    @IBOutlet weak var completedLists: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressToDo(_:)))
            longPressGesture.minimumPressDuration = 1.0
            tableView.addGestureRecognizer(longPressGesture)
        }
    }

    @IBAction func editList(_ sender: UIButton) {
        if !addList.isFirstResponder {
            let flag = !tableView.isEditing
            tableView.setEditing(flag, animated: true)
            editButton.isSelected = flag
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        addList.yz_textHeightChangeBlock = {(text: String?, textHeight: CGFloat) -> Void in
            self.bottomHCons.constant = textHeight + 17
        }
        addList.text = "＋请输入List"
        addList.textColor = UIColor.lightGray
        
        addList.maxNumberOfLines = 4

        addList.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        if let savedLists = loadLists() {
            lists += savedLists
        } else {
            loadSampleList()
        }
        
        self.view.bringSubview(toFront: completedLists)
        tableView.separatorInset = UIEdgeInsets.zero

    }
    
    func keyboardWillChangeFrame(_ note: Notification) {
        let duration = (note as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        }) 
    }

    func loadSampleList() {
        let list01 = Lists(name: "第一条List，就是介么简单")!
        let list02 = Lists(name: "咔咔，第二条")!
        lists += [list01, list02]
    }
    
    func longPressToDo(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            
            let point = gesture.location(in: tableView)
            let longPressedIndexPath = tableView.indexPathForRow(at: point)
            if longPressedIndexPath != nil {
                addList.becomeFirstResponder()
                addList.text = tableView.cellForRow(at: longPressedIndexPath!)?.textLabel?.text
                if tableView.isFirstResponder {
                    addList.resignFirstResponder()
                    editButton.setImage(nil, for: UIControlState())
                    
                    return
                }
                isLongPressed = true
                
//                lists.remove(at: ((longPressedIndexPath as NSIndexPath?)?.row)!)
                theLinkIndexPath = longPressedIndexPath
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
  
    // MARK: NSCoding
        
    func saveLists() {
        NSKeyedArchiver.archiveRootObject(lists, toFile: ArchiveURL.path)
        
    }
    
    @discardableResult func loadLists() -> [Lists]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Lists]
    }
    
    @discardableResult func loaddeletedLists() -> [Lists]? {
        deletedLists += (NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveDeletedListsURL.path) as? [Lists])!
        return deletedLists
    }
    
    func savedeletedLists() {
        NSKeyedArchiver.archiveRootObject(deletedLists, toFile: ArchiveDeletedListsURL.path)
        
    }

}

extension PresentListViewController: UITextViewDelegate {
    
    // MARK: - UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        textView.text = ""
        textView.textColor = UIColor.darkText
        editButton.setImage(UIImage(named: "0_btn_clear.png"), for: UIControlState())
        if view.becomeFirstResponder() || tableView.becomeFirstResponder() {
            addList.resignFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        editButton.setImage(UIImage(named: "0_btn_edit.png"), for: UIControlState())
        if isLongPressed {
            let textLong = textView.text ?? ""
            if !textLong.isEmpty {
                let list2 = Lists(name: textLong)
//                theOne = list2
                if list2 != lists[(theLinkIndexPath! as IndexPath).row] {
                    lists.remove(at: ((theLinkIndexPath as NSIndexPath?)?.row)!)
                    lists.insert(list2!, at: ((theLinkIndexPath! as NSIndexPath).row))
                    
                }
                
            }
        } else {
            let text = textView.text ?? ""
            if !text.isEmpty {
                let list1 = Lists(name: text)
                lists.insert(list1!, at: 0)
            }
        }
        
        tableView.reloadData()
        textView.text = "＋请输入List"
        textView.textColor = UIColor.lightGray

    }
}


extension PresentListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadLists()
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadLists()
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        let list = lists[(indexPath as NSIndexPath).row]
        cell.aList.text = list.name
//        if dict[String(indexPath.row)] == "0" {
//            cell.aList.numberOfLines = 0
//        } else {
//            cell.aList.numberOfLines = 1
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deletedLists = [Lists]()
            deletedLists.append(lists[(indexPath as NSIndexPath).row])
            lists.remove(at: (indexPath as NSIndexPath).row)
            saveLists()
            loaddeletedLists()
            savedeletedLists()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addList.resignFirstResponder()
//        tableView.becomeFirstResponder()
//        tableView.beginUpdates()
//        let cell = tableView.cellForRow(at: indexPath)
//        if let label = cell?.contentView.viewWithTag(10) as? UILabel {
//            if label.text == "" {
//                addList.resignFirstResponder()
//                return
//            }
//            if label.numberOfLines == 0 {
//                label.numberOfLines = 1
//                dict[String(indexPath.row)] = "1"
//            } else {
//                label.numberOfLines = 0
//                dict[String(indexPath.row)] = "0"
//            }
//
//        }
//        
//        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let good = lists[(sourceIndexPath as NSIndexPath).row]
        lists.remove(at: (sourceIndexPath as NSIndexPath).row)
        lists.insert(good, at: (destinationIndexPath as NSIndexPath).row)
        saveLists()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCompletedLists" {
            let completedController = segue.destination as! UINavigationController
            if let _ = completedController.visibleViewController as? CompletedTableViewController {
                if (sender as? UIButton) != nil {
                    print("yeah")
                }
            }
        }
    }
    
}

