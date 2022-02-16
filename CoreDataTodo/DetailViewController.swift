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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = landmark?.title
        
        
    }
    
}
