//
//  LandmarksTableViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//

import UIKit
import CoreData

class LandmarksTableViewController: UITableViewController {
    var category : Category?
    var landmarks : [Landmark] = []
    
    var modificationDate = false
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Date of modification", handler: { (_) in
                self.modificationDate = true
                self.updateLandmarksSort()
            }),
            UIAction(title: "Date of creation", handler: { (_) in
                self.modificationDate = false
                self.updateLandmarksSort()
            })
        ]
    }

    var sortSelectionMenu: UIMenu {
        return UIMenu(title: "Sort with", image: nil, identifier: nil, options: [], children: menuItems)
    }

    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuBarButtonItem.menu = sortSelectionMenu
        title = category?.name
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        landmarks = fetchLandmarksOfCategory(category: category!)
        

        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
    var container : NSPersistentContainer{
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    private func updateLandmarksSort(){
        let fetchRequest = Landmark.fetchRequest()

        var sortDescriptorDate :  NSSortDescriptor?
        
        switch(modificationDate){
        
        case  true: print("Modif")
             sortDescriptorDate = NSSortDescriptor(keyPath : \Landmark.modificationDate, ascending: false)
        case false :print("Crea")
             sortDescriptorDate = NSSortDescriptor(keyPath : \Landmark.creationDate, ascending: true)

        }
    
        fetchRequest.sortDescriptors = [sortDescriptorDate!]
        fetchRequest.predicate = NSPredicate(format : "%K == %@" ,argumentArray: [#keyPath(Landmark.category), category])
    
        do{
            let result = try container.viewContext.fetch(fetchRequest)
            landmarks = result
            tableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    private func fetchLandmarksOfCategory(category : Category) -> [Landmark]{
        let fetchRequest = Landmark.fetchRequest()

        var sortDescriptorDate :  NSSortDescriptor?
        
        switch(modificationDate){
        
        case  true: print("Modif")
             sortDescriptorDate = NSSortDescriptor(keyPath : \Landmark.modificationDate, ascending: false)
        case false :print("Crea")
             sortDescriptorDate = NSSortDescriptor(keyPath : \Landmark.creationDate, ascending: true)

        }
    
        fetchRequest.sortDescriptors = [sortDescriptorDate!]
        fetchRequest.predicate = NSPredicate(format : "%K == %@" ,argumentArray: [#keyPath(Landmark.category), category])
    
        do{
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    private func fetchLandmarkByName(searchQuery: String? = nil) -> [Landmark]{
        let fetchRequest = Landmark.fetchRequest()
      
        
        let sortDescriptor = NSSortDescriptor(keyPath : \Landmark.title, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicates = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    NSPredicate(format : "%K contains[cd] %@", argumentArray: [#keyPath(Landmark.title),searchQuery]),
                    NSPredicate(format : "%K == %@" ,argumentArray: [#keyPath(Landmark.category), category])
                ]
            )
     
            fetchRequest.predicate = predicates
        }else{
            let predicates =  NSPredicate(format : "%K == %@" ,argumentArray: [#keyPath(Landmark.category), category])
            fetchRequest.predicate = predicates
        }
        
      
        do{
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    private func createLandmark(title: String, description: String = "", date: Date = Date()){
        let landmark = Landmark(context: container.viewContext)
        landmark.title = title
        landmark.creationDate = date
        landmark.modificationDate = date
        landmark.desc = description
        landmark.category = category
        saveContext()
    }

    
    private func delete(landmark : Landmark){
        container.viewContext.delete(landmark)
        saveContext()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let landmark = landmarks[indexPath.row]
        cell.textLabel?.text = landmark.title
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: landmark.creationDate!,
                                                                   dateStyle: .short,
                                                                   timeStyle: .short)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let landmark = landmarks[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer"){ [weak self] _, _,completion in
            guard let self = self else {
                return
            }
        
            self.delete(landmark: landmark)
            //self.items = self.fetchItems()
            self.landmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActionConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _  = landmarks[indexPath.row]
      
        saveContext()
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
     
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! AddEditLandmarkViewController
            destVC.delegate = self
            destVC.category = category
        }
        if segue.identifier == "edit" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! AddEditLandmarkViewController
            destVC.delegate = self
            let indexEditing = sender as! UITableViewCell
            destVC.landmarkToEdit = landmarks[tableView.indexPath(for: indexEditing)!.row]
        }
        if segue.identifier == "detail" , let destinationViewController = segue.destination as? DetailViewController{
            let indexEditing = sender as! UITableViewCell
            destinationViewController.category = self.category
            destinationViewController.landmark = landmarks[tableView.indexPath(for: indexEditing)!.row]
        }
    }
    
}

extension LandmarksTableViewController : UISearchResultsUpdating{
     
    func updateSearchResults(for seatchController : UISearchController){
        let searchQuery = seatchController.searchBar.text
        landmarks = fetchLandmarkByName(searchQuery: searchQuery)
        tableView.reloadData()
    }
}

extension LandmarksTableViewController : AddEditLandmarkViewControllerDelegate {
    func AddEditLandmarkViewControllerDidCancel(_ controller: AddEditLandmarkViewController) {
        self.dismiss(animated: true)
    }
    
    func AddEditLandmarkViewController(_ controller: AddEditLandmarkViewController, didFinishAddingItem item: Landmark) {
        landmarks.append(item)
        let indexPath = IndexPath(row: landmarks.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true)
        saveContext()
    }
    
    func AddEditLandmarkViewController(_ controller: AddEditLandmarkViewController, didFinishEditingItem item: Landmark) {
        let index = landmarks.firstIndex() { $0 === item }
        let indexPath = IndexPath(row: index!, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true)
        saveContext()
    }
}
