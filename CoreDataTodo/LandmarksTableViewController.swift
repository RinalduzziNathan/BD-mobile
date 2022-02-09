//
//  LandmarksTableViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//

import UIKit
import CoreData

class LandmarksTableViewController: UITableViewController {
    var landmarks : [Landmark] = []
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(text)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        landmarks = fetchLandmark()
        tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    var container : NSPersistentContainer{
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    private func saveContext(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    private func fetchLandmark(searchQuery: String? = nil) -> [Landmark]{
        let fetchRequest = Landmark.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(keyPath : \Landmark.title, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSPredicate(format : "%K contains[cd] %@", argumentArray: [#keyPath(Landmark.title),searchQuery])
            fetchRequest.predicate = predicate
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
        saveContext()
    }

    private func delete(landmark : Landmark){
        container.viewContext.delete(landmark)
        saveContext()
    }
    
    @IBAction func AddBarButtonItemAction(_ sender: UIBarButtonItem) {
    
        let alertController = UIAlertController(title: "nouveau lieu", message: "ajouter nouveau lieu", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Titre…"
        }
        
        let cancelAction = UIAlertAction(title : "Annuler",
                                         style: .cancel,
                                         handler: nil)
        
        let saveAction = UIAlertAction(title : "Sauvegarder",
                                   style: .default){[weak self] _ in
        
            guard let self = self, let textField = alertController.textFields?.first else{
                return
            }
            self.createLandmark(title: textField.text!)
            self.landmarks = self.fetchLandmark()
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController,animated: true)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let landmark = landmarks[indexPath.row]
       // cell.accessoryType = item.isChecked ? .checkmark : .none
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
        let landmark  = landmarks[indexPath.row]
       // category.isChecked.toggle()
        saveContext()
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
       // cell.accessoryType = category.isChecked ? .checkmark : .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryToLandmark" , let destinationViewController = segue.destination as? LandmarksTableViewController{
            destinationViewController.text = "Landmarks"
        }
    }
    
}

extension LandmarksTableViewController : UISearchResultsUpdating{
     
    func updateSearchResults(for seatchController : UISearchController){
        let searchQuery = seatchController.searchBar.text
        landmarks = fetchLandmark(searchQuery: searchQuery)
        tableView.reloadData()
    }
}


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


