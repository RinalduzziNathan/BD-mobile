//
//  ViewController.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//

import UIKit
import CoreData

class TodoListTableViewController: UITableViewController {
    var items : [Item] = []
    var categories : [Category] = []
    override func viewDidLoad() {
        super.viewDidLoad()


        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        categories = fetchCategory()
        // Do any additional setup after loading the view.
    }

    var container : NSPersistentContainer{
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }

    private func saveContext(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    private func fetchCategory(searchQuery: String? = nil) -> [Category]{
        let fetchRequest = Category.fetchRequest()

        let sortDescriptor = NSSortDescriptor(keyPath : \Category.name, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSPredicate(format : "%K contains[cd] %@", argumentArray: [#keyPath(Category.name),searchQuery])
            fetchRequest.predicate = predicate
        }


        do{
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    private func fetchLandmarksOfCategory(category : Category) -> [Landmark]{
        let fetchRequest = Landmark.fetchRequest()

      //  let sortDescriptor = NSSortDescriptor(keyPath : \Landmark.category, ascending: true)
        let sortDescriptor = NSSortDescriptor(keyPath : \Landmark.creationDate, ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format : "%K == %@" ,argumentArray: [#keyPath(Landmark.category), category])
    
        do{
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    private func createCategory(name: String, date: Date = Date()){
       
     
        let category = Category(context: container.viewContext)
        category.name = name
        category.creationDate = date
        category.modificationDate = date
        saveContext()
    
        
    }
    
   
    
    private func editCategory(name: String, category : Category){
        category.name = name
        category.modificationDate = Date()
        saveContext()
    }

    private func delete(category : Category){
        container.viewContext.delete(category)
        saveContext()
    }

   
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Editer catégorie", message: "Editer la catégorie", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Nouveau nom…"
        }

        let cancelAction = UIAlertAction(title : "Annuler",
                                         style: .cancel,
                                         handler: nil)

        let saveAction = UIAlertAction(title : "Sauvegarder",
                                       style: .default){[weak self] _ in

            guard let self = self, let textField = alertController.textFields?.first else{
                return
            }

            let category = self.categories[indexPath.row]
            self.editCategory(name: textField.text!, category:category)
            self.categories = self.fetchCategory()
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController,animated: true)
    }

    @IBAction func AddBarButtonItemAction(_ sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "nouvelle catégorie", message: "ajouter nouvelle catégorie", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Nom…"
        }

        let cancelAction = UIAlertAction(title : "Annuler",
                                         style: .cancel,
                                         handler: nil)

        let saveAction = UIAlertAction(title : "Sauvegarder",
                                       style: .default){[weak self] _ in

            guard let self = self, let textField = alertController.textFields?.first else{
                return
            }
            self.createCategory(name: textField.text!)
            self.categories = self.fetchCategory()
            self.tableView.reloadData()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController,animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categories[indexPath.row]
        // cell.accessoryType = item.isChecked ? .checkmark : .none
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: category.creationDate!,
                                                                   dateStyle: .short,
                                                                   timeStyle: .short)


        return cell

    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = categories[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer"){ [weak self] _, _,completion in
            guard let self = self else {
                return
            }

            self.delete(category: category)
            //self.items = self.fetchItems()
            self.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActionConfiguration
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category  = categories[indexPath.row]
        // category.isChecked.toggle()
        saveContext()
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        // cell.accessoryType = category.isChecked ? .checkmark : .none
    }

    //override func tab

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryToLandmark" , let destinationViewController = segue.destination as? LandmarksTableViewController{
            let indexEditing = sender as! UITableViewCell
            destinationViewController.category = categories[tableView.indexPath(for: indexEditing)!.row]
        }
    }
}

extension TodoListTableViewController : UISearchResultsUpdating{

    func updateSearchResults(for seatchController : UISearchController){
        let searchQuery = seatchController.searchBar.text
        categories = fetchCategory(searchQuery: searchQuery)
        tableView.reloadData()
    }
}
