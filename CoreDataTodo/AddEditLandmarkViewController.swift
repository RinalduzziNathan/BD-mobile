//
//  AddEditLandmarkViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//

import UIKit
import CoreData

class AddEditLandmarkViewController: UIViewController {
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textFieldDesc: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    var container : NSPersistentContainer{
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    var category : Category?
    var landmarkToEdit : Landmark?
    var delegate : AddEditLandmarkViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let landmarkToEdit = landmarkToEdit {
            //mode edition
            self.title = "Edit Landmark"
            textFieldTitle.text = landmarkToEdit.title
            textFieldDesc.text = landmarkToEdit.desc
        }
        else {
            self.title = "Add Landmark"
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if let landmarkToEdit = landmarkToEdit {
            landmarkToEdit.title = textFieldTitle.text
            landmarkToEdit.desc = textFieldDesc.text
            
            delegate?.AddEditLandmarkViewController(self, didFinishEditingItem: landmarkToEdit)
        }
        else {
            let landmark = Landmark(context: container.viewContext)
            landmark.title = textFieldTitle.text
            landmark.creationDate = Date()
            landmark.modificationDate = Date()
            landmark.desc = textFieldDesc.text
            landmark.category = category
            
            delegate?.AddEditLandmarkViewController(self, didFinishAddingItem: landmark)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.AddEditLandmarkViewControllerDidCancel(self)
    }
    
    @IBAction func chooseImage(_ sender: UIButton) {
        
    }
}

protocol AddEditLandmarkViewControllerDelegate : AnyObject {
    func AddEditLandmarkViewControllerDidCancel(_ controller: AddEditLandmarkViewController)
    func AddEditLandmarkViewController(_ controller: AddEditLandmarkViewController, didFinishAddingItem item: Landmark)
    func AddEditLandmarkViewController(_  controller: AddEditLandmarkViewController, didFinishEditingItem item: Landmark)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
}
