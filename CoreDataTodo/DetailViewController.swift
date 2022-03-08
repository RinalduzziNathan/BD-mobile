//
//  DetailViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 16/02/2022.
//

import UIKit
import CoreData
import Foundation

class DetailViewController : UIViewController {
    
    var category : Category?
    var landmark : Landmark?
    
    @IBOutlet weak var imageLandmark: UIImageView!
    @IBOutlet weak var desciption: UITextView!
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var dateEdit: UIDatePicker!
    @IBOutlet weak var dateCreation: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let landmark = landmark {
            title = landmark.title
            
            if let imageData = landmark.image{
                imageLandmark.image = UIImage(data: imageData)
            }
        

            desciption.text = landmark.desc
            latitude.text = landmark.coordinate?.latitude.description
            longitude.text = landmark.coordinate?.longitude.description
            dateEdit.date = landmark.modificationDate!
            dateCreation.date = landmark.creationDate!
        }
    }
}
