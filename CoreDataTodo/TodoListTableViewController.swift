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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        items = fetchItems()
        // Do any additional setup after loading the view.
    }

    var container : NSPersistentContainer{
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    private func saveContext(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    private func fetchItems(searchQuery: String? = nil) -> [Item]{
        let fetchRequest = Item.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(keyPath : \Item.title, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSPredicate(format : "%K contains[cd] %@", argumentArray: [#keyPath(Item.title),searchQuery])
            fetchRequest.predicate = predicate
        }
        
        
        do{
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    private func createItem(title: String, date: Date = Date()){
        let item = Item(context: container.viewContext)
        item.title = title
        item.date = date
        saveContext()
    }

    private func delete(item : Item){
        container.viewContext.delete(item)
        saveContext()
    }
    
    @IBAction func AddBarButtonItemAction(_ sender: UIBarButtonItem) {
    
        let alertController = UIAlertController(title: "nouvelle tahe", message: "ajouter tâche liste", preferredStyle: .alert)
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
            self.createItem(title: textField.text!)
            self.items = self.fetchItems()
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController,animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.accessoryType = item.isChecked ? .checkmark : .none
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: item.date!,                                                       dateStyle: .short,                                                       timeStyle: .short)
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer"){ [weak self] _, _,completion in
            guard let self = self else {
                return
            }
        
            self.delete(item: item)
            //self.items = self.fetchItems()
            self.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActionConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item  = items[indexPath.row]
        item.isChecked.toggle()
        saveContext()
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = item.isChecked ? .checkmark : .none
    }
    
}

extension TodoListTableViewController : UISearchResultsUpdating{
     
    func updateSearchResults(for seatchController : UISearchController){
        let searchQuery = seatchController.searchBar.text
        items = fetchItems(searchQuery: searchQuery)
        tableView.reloadData()
    }
}
