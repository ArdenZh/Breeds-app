//
//  PhotoManager.swift
//  Breeds
//
//  Created by Arden  on 16.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol PhotoManagerDelegate {
    func didUpdatePhotos(_ photoManager: PhotoManager, photosInStringArray: [String])
    func didFailWithError(error: Error)
}

struct PhotoManager {
    
    var delegate : PhotoManagerDelegate?
    
    func fetchAllPhotos(for breed: String, with subbreed: String?){

        let URLString: String
        
        if subbreed != nil{
            URLString = "https://dog.ceo/api/breed/\(breed)/\(subbreed!)/images"
        }else{
            URLString = "https://dog.ceo/api/breed/\(breed)/images"
        }
        
        AF.request(URLString, method: .get).validate().responseJSON { (response) in
            
            switch response.result {
            case.success(let value):
                
                let json = JSON(value)
                let arrayOfImageURLinString = json["message"].arrayValue.map{ $0.stringValue }
                
                self.delegate?.didUpdatePhotos(self, photosInStringArray: arrayOfImageURLinString)
            
            case.failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
}

