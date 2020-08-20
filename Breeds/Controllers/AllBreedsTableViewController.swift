//
//  TableViewController.swift
//  Breeds
//
//  Created by Arden  on 16.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import UIKit

class AllBreedsTableViewController: UITableViewController {
    
    var breedsManager = BreedsManager()
    var breeds = [Breed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        breedsManager.delegate = self
        breedsManager.fetchAllBreeds()
        
        customizingView()
        
    }
    
    func customizingView(){
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0.8745098039, green: 0.9019607843, blue: 0.9137254902, alpha: 1)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 0.8745098039, green: 0.9019607843, blue: 0.9137254902, alpha: 1)]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.8392156863, green: 0.1882352941, blue: 0.1921568627, alpha: 1)
        
        if let navigationBar = self.navigationController?.navigationBar{
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationBar.tintColor = #colorLiteral(red: 0.8745098039, green: 0.9019607843, blue: 0.9137254902, alpha: 1)
        }
        
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.8392156863, green: 0.1882352941, blue: 0.1921568627, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allBreedsCellIdentifier", for: indexPath) as? AllBreedsTableViewCell else {
            fatalError("AllBreedsTableViewCell not found")
        }
        
        cell.titleTextLabel.text = breeds[indexPath.row].breed.capitalized
        
        let numberOfSubbreeds = breeds[indexPath.row].subbreeds.count
        if numberOfSubbreeds != 0{
            cell.descriptionTextLabel.text = "(\(numberOfSubbreeds) subbreeds)"
        }else{
            cell.descriptionTextLabel.text = nil
        }
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if breeds[indexPath.row].subbreeds.count == 0{
            performSegue(withIdentifier: "showPhotosFromBreeds", sender: indexPath.row)
        }else{
            performSegue(withIdentifier: "showSubbreeds", sender: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubbreeds"{
            let destinationVC = segue.destination as! SubbreedsTableViewController
            
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.subbreeds = breeds[indexPath.row].subbreeds
                destinationVC.breed = breeds[indexPath.row].breed
            }
        }else if segue.identifier == "showPhotosFromBreeds"{
            let destinationVC = segue.destination as! PhotoGalleryViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.currentBreed = breeds[indexPath.row].breed
            }
        }
    }
}

 //MARK: - Webservice delegate

extension AllBreedsTableViewController: BreedsManagerDelegate{
    
    func didUpdateBreeds(_ breedsManager: BreedsManager, breedsList: [Breed]) {
        DispatchQueue.main.async {
            self.breeds = breedsList
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        let alert = UIAlertController(title: "Some server error", message: "Try connect later", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
