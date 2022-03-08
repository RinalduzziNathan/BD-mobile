//
//  DetailViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 16/02/2022.
//

import UIKit
import CoreData
import Foundation
import MapKit

class DetailViewController : UIViewController {
    
    var category : Category?
    var landmark : Landmark?
    
    @IBOutlet weak var imageLandmark: UIImageView!
    @IBOutlet weak var desciption: UITextView!
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var dateEdition: UILabel!
    @IBOutlet weak var dateCreation: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
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
            dateEdition.text = landmark.modificationDate!.toLocalizedString()
            dateCreation.text = landmark.creationDate!.toLocalizedString()
            let location = CLLocation(latitude: landmark.coordinate?.latitude ?? 0, longitude: landmark.coordinate?.longitude ?? 0)
            mapView.centerToLocation(location, regionRadius: 1000.0)
            let place = Place(title: landmark.title ?? "", coordinate: CLLocationCoordinate2D(latitude: landmark.coordinate?.latitude ?? 0, longitude: landmark.coordinate?.longitude ?? 0), info: landmark.desc ?? "")
            mapView.addAnnotation(place)
        }
    }
}

extension Date {
    func toLocalizedString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
}
