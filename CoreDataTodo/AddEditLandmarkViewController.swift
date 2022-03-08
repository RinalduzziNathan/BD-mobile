//
//  AddEditLandmarkViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//

import UIKit
import CoreData
import PhotosUI

class AddEditLandmarkViewController: UIViewController {
    
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textFieldDesc: UITextView!
    @IBOutlet weak var textFieldLatitude: UITextField!
    @IBOutlet weak var textFieldLongitude: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    var container : NSPersistentContainer{
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    var category : Category?
    var landmarkToEdit : Landmark?
    var imageLandmark : Data?
    var delegate : AddEditLandmarkViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let landmarkToEdit = landmarkToEdit {
            //mode edition
            self.title = "Edit Landmark"
            textFieldTitle.text = landmarkToEdit.title
            textFieldDesc.text = landmarkToEdit.desc
            textFieldLatitude.text = landmarkToEdit.coordinate?.latitude.description
            textFieldLongitude.text = landmarkToEdit.coordinate?.longitude.description
            
            if landmarkToEdit.image != nil {
                imageView.image = UIImage(data: landmarkToEdit.image!)
            }
        }
        else {
            self.title = "Add Landmark"
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if let landmarkToEdit = landmarkToEdit {
            landmarkToEdit.title = textFieldTitle.text
            landmarkToEdit.desc = textFieldDesc.text
            landmarkToEdit.modificationDate = Date()
            
            if let latitude = Double(textFieldLatitude.text!) {
                landmarkToEdit.coordinate?.latitude = latitude
            }
            if let longitude = Double(textFieldLongitude.text!) {
                landmarkToEdit.coordinate?.longitude = longitude
            }
            
            if let imageLandmark = imageLandmark {
                landmarkToEdit.image = imageLandmark
            }
            
            delegate?.AddEditLandmarkViewController(self, didFinishEditingItem: landmarkToEdit)
        }
        else {
            let landmark = Landmark(context: container.viewContext)
            let coordinate = Coordinate(context: container.viewContext)
            if let latitude = Double(textFieldLatitude.text!) {
                coordinate.latitude = latitude
            }
            if let longitude = Double(textFieldLongitude.text!) {
                coordinate.longitude = longitude
            }
            landmark.coordinate = coordinate
            landmark.title = textFieldTitle.text
            landmark.creationDate = Date()
            landmark.modificationDate = Date()
            landmark.desc = textFieldDesc.text
            landmark.category = category
            landmark.image = imageLandmark
            
            delegate?.AddEditLandmarkViewController(self, didFinishAddingItem: landmark)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.AddEditLandmarkViewControllerDidCancel(self)
    }
    
    @IBAction func chooseImage(_ sender: UIButton) {
        let configuration = PHPickerConfiguration(photoLibrary: .shared())
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

protocol AddEditLandmarkViewControllerDelegate : AnyObject {
    func AddEditLandmarkViewControllerDidCancel(_ controller: AddEditLandmarkViewController)
    func AddEditLandmarkViewController(_ controller: AddEditLandmarkViewController, didFinishAddingItem item: Landmark)
    func AddEditLandmarkViewController(_  controller: AddEditLandmarkViewController, didFinishEditingItem item: Landmark)
}

extension AddEditLandmarkViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //Verif qu'on a bien 1 élément, et qu'on peut le charger en image
        guard let selectedResult = results.first, selectedResult.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        picker.dismiss(animated: true)
        //Charge l'image et gestion erreur
        selectedResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self else {
                return
            }
            if let error = error {
                //handle error
                print(error)
                return
            }
            //Cast result en image
            guard let image = image as? UIImage else {
                return
            }
            //Gestion du thread sur main
            DispatchQueue.main.async {
                self.imageLandmark = image.pngData() ?? image.jpegData(compressionQuality: 0.9)
                self.imageView.image = image
            }
        }
    }
}
