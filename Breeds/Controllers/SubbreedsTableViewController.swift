//
//  SubbreedsTableViewController.swift
//  Breeds
//
//  Created by Arden  on 16.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import UIKit

class SubbreedsTableViewController: UITableViewController {

    var subbreeds: [String] = []
    var breed: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = breed.capitalized
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subbreeds.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subbreedsCellIdentifier", for: indexPath)

        cell.textLabel?.text = subbreeds[indexPath.row].capitalized

        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotosFromSubbreeds"{
            let destinationVC = segue.destination as! PhotoGalleryViewController
           
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.currentBreed = breed
                destinationVC.currentSubbreed = subbreeds[indexPath.row]
            }
        }
    }

}
