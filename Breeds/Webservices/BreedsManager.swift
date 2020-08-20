//
//  BreedsManager.swift
//  Breeds
//
//  Created by Arden  on 16.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import Foundation


import Foundation
import Alamofire
import SwiftyJSON

protocol BreedsManagerDelegate {
    func didUpdateBreeds(_ breedsManager: BreedsManager, breedsList: [Breed])
    func didFailWithError(error: Error)
}

struct BreedsManager {
    
    var delegate: BreedsManagerDelegate?
    
    func fetchAllBreeds() {
        
        AF.request("https://dog.ceo/api/breeds/list/all", method: .get).validate().responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                
                let listOfBreeds = self.parseAllBreedsJSON(JSON(value))
                
                self.delegate?.didUpdateBreeds(self, breedsList: listOfBreeds)
                
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    
    func parseAllBreedsJSON(_ allBreedsJSON: JSON ) -> [Breed] {
        
        var listOfBreeds = [Breed]()
        
        for (breed,subbreed):(String, JSON) in allBreedsJSON["message"]{
            
            let subbreedsArray = subbreed.arrayValue.map{ $0.stringValue }
            listOfBreeds.append(Breed(breed: breed, subbreeds: subbreedsArray.map({$0})))
        }
        
        let sortedListOfBreeds = listOfBreeds.sorted {
            $0.breed < $1.breed
        }
        return sortedListOfBreeds
    }
    
    
}

