//
//  ViewController.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSPhotoGallery

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var useCustomOverlay = false
    
    lazy var photos: [CustomPhotoModel] = {
			
        var rtfPath = Bundle.main.url(forResource: "Father Consent", withExtension: "rtf")
        var mp3Path = Bundle.main.url(forResource: "file_example_MP3_1MG", withExtension: "mp3")

        return [
            CustomPhotoModel.init(fileURL:
                URL(string:"http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"),
                                  thumbnailImageURL: URL(string:"http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"),
                                  mimeType: MimeType.image.rawValue,
                                  contentType: "image/jpg"),
            CustomPhotoModel.init(fileURL:
                mp3Path,
                                  thumbnailImageURL: nil,
                                  mimeType: MimeType.audio.rawValue,
                                  contentType: "audio/mp3"),
            CustomPhotoModel.init(fileURL:
                rtfPath,
                                  thumbnailImageURL:nil,
                                  mimeType: MimeType.rtf.rawValue,
                                  contentType: "text/rtf"),
            CustomPhotoModel.init(fileURL:
                URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"),
                                  thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"),
                                  mimeType: MimeType.image.rawValue,
                                  contentType: "image/jpg")
            
        ]
			
    
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
			for photoItem in photos.enumerated() {
				if let photo = photoItem.element as? INSPhoto {
                #if swift(>=4.0)
                    photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                #else
                    photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSForegroundColorAttributeName: UIColor.white])
                #endif
					if photoItem.offset == 3{
									 
										photo.mimeType = MimeType.video.rawValue
								}
					if photoItem.offset == 2  {
						 
							photo.mimeType = MimeType.other.rawValue
					}
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            galleryPreview.overlayView = CustomOverlayView(frame: CGRect.zero)
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
}
