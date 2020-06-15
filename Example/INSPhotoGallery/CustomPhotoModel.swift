//
//  CustomPhotoModel.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import Kingfisher
import INSPhotoGallery

class CustomPhotoModel: NSObject {
    
    var image: UIImage?
    var thumbnailImage: UIImage?
    
    var fileURL: URL?
    var thumbnailImageURL: URL?
    
    var mimeType: Int
    var contentType: String // eg: "video/mp4"
    init(fileURL: URL?, thumbnailImageURL: URL?, mimeType: Int, contentType: String) {
        self.fileURL = fileURL
        self.thumbnailImageURL = thumbnailImageURL
        self.mimeType =  mimeType
        self.contentType = contentType
    }
    
}

extension CustomPhotoModel : INSPhotoViewable {
    
    var attributedTitle: NSAttributedString? {
        
        return NSAttributedString.init(string: "*****************- Filename.ext -*******************", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    
    
    func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let url = fileURL {
            
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
        } else {
            completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }

    func loadThumbnailImageWithCompletionHandler(_ placeholderCompletion: @escaping (UIImage?) -> (), downloadCompletion: @escaping (UIImage?, Error?) -> ()) {
        
        switch MimeType.init(rawValue: mimeType) {
        case .image:
            placeholderCompletion(UIImage.init(named: "image"))
        case .video:
            placeholderCompletion(UIImage.init(named: "video"))
            return
        case .pdf:
            placeholderCompletion(UIImage.init(named: "pdf"))
            return
        case .audio:
            placeholderCompletion(UIImage.init(named: "audio"))
            return
        case .csv:
            placeholderCompletion(UIImage.init(named: "csv"))
            return
        case .rtf:
            placeholderCompletion(UIImage.init(named: "text"))
            return
        case .html:
            placeholderCompletion(UIImage.init(named: "doc"))
            return
        default:
            placeholderCompletion(UIImage.init(named: "unsupported"))
            return
        }
        /// Thumbnail doesn't have data, so loading full image
        if let url = fileURL {
            
            if let thumbnailImage = thumbnailImage {
                downloadCompletion(thumbnailImage, nil)
                return
            }
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                downloadCompletion(image, error)
            })
        } else {
            downloadCompletion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
        
    }
    
    func loadDataWithCompletionHandler(_ completion: @escaping (_ fileURL: URL?,_ contentType: String?,  _ error: Error?) -> ()) {
        if let url = fileURL {
            completion(url,self.contentType, nil)
        } else {
            completion(nil,self.contentType ?? "", NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
    
    func loadPlaceholderDataWithCompletionHandler(_ completion: @escaping (_ fileURL: URL?,  _ error: Error?) -> ()) {
        
        let resourcePath = "file://" + Bundle.main.resourcePath!
        switch MimeType.init(rawValue: mimeType) {
        case .image:
            let imgName = "image.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)
        case .video:
            let imgName = "video.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        case .pdf:
            let imgName = "pdf.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        case .audio:
            let imgName = "audio.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        case .csv:
            let imgName = "csv.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        case .rtf:
            let imgName = "text.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        case .html:
            let imgName = "doc.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        default:
            let imgName = "unsupported.png"
            let file = resourcePath + "/" + imgName

            completion(URL.init(string: file), nil)

        }

    }
    
}
