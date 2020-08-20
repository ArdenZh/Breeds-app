//
//  PhotoGalleryViewController.swift
//  Breeds
//
//  Created by Arden  on 16.08.2020.
//  Copyright © 2020 Arden Zhakhin. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ImageSlideshow
import RealmSwift

class PhotoGalleryViewController: UIViewController{
    
    let realm = try! Realm()
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    var currentBreed : String = ""
    var currentSubbreed : String?
    var commonName : String {
        if currentSubbreed == nil{
            return currentBreed
        }else{
            return currentSubbreed!
        }
    }
    
    var isSegueFromFavouriteVC : Bool = false
    var photoManager = PhotoManager()
    var favouriteBreed : FavouriteBreed?
    var favouritePhotosFromFavouriteVC : List<FavouriteImage>?
    var photosUrlStringArray: [String] = []
    var likedPhotos: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        photoManager.delegate = self
        setupSlideshow()
        self.navigationItem.title = commonName.capitalized
        
        if isSegueFromFavouriteVC{
            showPhotosFromFavouriteVC()
        }else{
            photoManager.fetchAllPhotos(for: currentBreed, with: currentSubbreed)
        }
    }
    
    func setupSlideshow(){
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.circular = false
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.pageIndicator = .none
        slideshow.delegate = self
    }
    
    
    //MARK: - Load and show photos
    
    //load liked photos from realm
    func loadLikedPhotos() {
        
        favouriteBreed = realm.objects(FavouriteBreed.self).filter("name = %@", commonName).first
        
        if let favouriteImages = favouriteBreed?.favouriteImages.sorted(byKeyPath: "imageUrlString", ascending: true){
            for img in favouriteImages{
                likedPhotos.append(img.imageUrlString)
            }
        }
    }
    

    func showPhotosFromFavouriteVC(){
        if let favouritePhotos = favouritePhotosFromFavouriteVC{
            for img in favouritePhotos{
                likedPhotos.append(img.imageUrlString)
                photosUrlStringArray.append(img.imageUrlString)
            }
            showPhotosFromStringArray(photos: photosUrlStringArray)
        }
    }
    
    //download and show photos on string
    func showPhotosFromStringArray(photos photosInStringArray: [String]){
        
        photosUrlStringArray = photosInStringArray
        
        var images: [SDWebImageSource] = []
        
        for photoURLString in photosInStringArray{
            if let sdWebImage = SDWebImageSource(urlString: photoURLString){
                images.append(sdWebImage)
            }
        }
        self.slideshow.setImageInputs(images)
        self.changeLikeButtonIfNeeded(pageNumber: 0)
    }
    
    
    //MARK: - Share
    
    @IBAction func didShareButtonPressed(_ sender: Any) {
        
        if let image = slideshow.currentSlideshowItem?.imageView.image{
             let itemForShare : [UIImage] = [image]
            
            let shareController = UIActivityViewController(activityItems: itemForShare, applicationActivities: nil)
            
            present(shareController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Like button methods
    
    @IBAction func didLikeButtonPressed(_ sender: Any) {
        
        let currentImageUrlString = photosUrlStringArray[slideshow.currentPage]
        
        favouriteBreed = realm.objects(FavouriteBreed.self).filter("name = %@", commonName).first
        
        //if photo is already liked
        if likedPhotos.contains(currentImageUrlString){
            
            likeButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
            
            if let index = likedPhotos.firstIndex(of: currentImageUrlString){
                likedPhotos.remove(at: index)
            }
            
            let image = realm.objects(FavouriteImage.self).filter("imageUrlString = %@", currentImageUrlString)
            
            //if there was only one photo in this breed, delete the entire breed from realm
            if favouriteBreed?.favouriteImages.count == 1 {
                do{
                    try realm.write{
                        realm.delete(image.first!)
                        realm.delete(favouriteBreed!)
                    }
                }catch{
                    print("Error removing image from Realm: \(error)")
                }
            //if there was several photos in this breed, then delete only this photo
            }else{
                do{
                    try realm.write{
                        realm.delete(image.first!)
                    }
                }catch{
                    print("Error removing image from Realm: \(error)")
                }
            }
            
        //if the photo hasn't been liked yet
        }else{
            likeButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            likedPhotos.append(currentImageUrlString)
            
            let newImage = FavouriteImage()
            newImage.imageUrlString = currentImageUrlString
            
            //if the breed is not yet in the database then add
            if favouriteBreed == nil{
                let newBreed = FavouriteBreed()
                newBreed.name = commonName
                newBreed.favouriteImages.append(newImage)
                do{
                    try realm.write {
                        realm.add(newImage)
                        realm.add(newBreed)
                    }
                }catch{
                    print("Error saving new breed: \(error)")
                }
            }else{
                do{
                    try realm.write {
                        favouriteBreed!.favouriteImages.append(newImage)
                    }
                }catch{
                    print("Error saving new breed: \(error)")
                }
            }
        }
    }
    

    func changeLikeButtonIfNeeded(pageNumber: Int) {
        
        if likedPhotos.contains(photosUrlStringArray[pageNumber]){
            likeButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            likeButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}


extension PhotoGalleryViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        changeLikeButtonIfNeeded(pageNumber: page)
    }

}

//MARK: - Webservice delegate

extension PhotoGalleryViewController: PhotoManagerDelegate {
    func didUpdatePhotos(_ photoManager: PhotoManager, photosInStringArray: [String]) {
          DispatchQueue.main.async {
            self.loadLikedPhotos()
            self.showPhotosFromStringArray(photos: photosInStringArray)
        }
    }
    
    func didFailWithError(error: Error) {
        let alert = UIAlertController(title: "Some server error", message: "Try connect later", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
