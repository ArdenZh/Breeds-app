//
//  FavouriteBreedsTableViewController.swift
//  Breeds
//
//  Created by Arden  on 18.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import UIKit
import RealmSwift

class FavouriteBreedsTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var breedsArray: Results<FavouriteBreed>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        loadBreeds()
    }
    
    func loadBreeds(){
        breedsArray = realm.objects(FavouriteBreed.self)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breedsArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteBreedsCellIdentifier", for: indexPath) as? FavouriteBreedsTableViewCell else {
                   fatalError("AllBreedsTableViewCell not found")
               }

        cell.titleTextLabel.text = breedsArray?[indexPath.row].name.capitalized
        if let numberOfPhotos = breedsArray?[indexPath.row].favouriteImages.count{
            cell.numberOfPhotosTextLabel.text = "(\(numberOfPhotos) photos)"
        }
        return cell
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotosFromFavourites"{
            let destinationVC = segue.destination as! PhotoGalleryViewController
            
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.favouritePhotosFromFavouriteVC = breedsArray?[indexPath.row].favouriteImages
                destinationVC.isSegueFromFavouriteVC = true
                 if let name = breedsArray?[indexPath.row].name{
                    destinationVC.currentBreed = name
                }
            }
        }
    }
}
