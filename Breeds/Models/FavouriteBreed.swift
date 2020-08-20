//
//  FavouriteBreed.swift
//  Breeds
//
//  Created by Arden  on 17.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import Foundation
import RealmSwift

class FavouriteBreed: Object{
    @objc dynamic var name: String = ""
    let favouriteImages = List<FavouriteImage>()
}
