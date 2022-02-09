//
//  AddEditLandmarkViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//

import UIKit

class AddEditLandmarkViewController: UIViewController {
    
    var landmarkToEdit : Landmark?
    var delegate : AddEditLandmarkViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let landmarkToEdit = landmarkToEdit {
            //mode edition
            self.title = "Edit Item"
            //textItem.text = itemToEdit.text
        }
        else {
            //Mode creation
        }
    }
    
    

}

protocol AddEditLandmarkViewControllerDelegate : AnyObject {
    func AddEditLandmarkViewControllerDidCancel(_ controller: AddEditLandmarkViewController)
    func AddEditLandmarkViewController(_ controller: AddEditLandmarkViewController, didFinishAddingItem item: Landmark)
    func AddEditLandmarkViewController(_  controller: AddEditLandmarkViewController, didFinishEditingItem item: Landmark)
}
