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

class CustomPhotoModel1: NSObject, INSPhotoViewable {
	
    var mimeType: Int = MimeType.video.rawValue

    var image: UIImage?
    var thumbnailImage: UIImage?
    var isDeletable: Bool {
        return false
    }
    
    var fileURL: URL?
    var thumbnailImageURL: URL?
    
    var attributedTitle: NSAttributedString? {
        #if swift(>=4.0)
        return NSAttributedString(string: "Example caption text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        #else
        return NSAttributedString(string: "Example caption text", attributes: [NSForegroundColorAttributeName: UIColor.white])
        #endif
    }
    
    init(image: UIImage?, thumbnailImage: UIImage?) {
        self.image = image
        self.thumbnailImage = thumbnailImage
    }
    
    init(imageURL: URL?, thumbnailImageURL: URL?) {
        self.fileURL = imageURL
        self.thumbnailImageURL = thumbnailImageURL
    }
    
    init (imageURL: URL?, thumbnailImage: UIImage) {
        self.fileURL = imageURL
        self.thumbnailImage = thumbnailImage
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
    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let thumbnailImage = thumbnailImage {
            completion(thumbnailImage, nil)
            return
        }
        if let url = thumbnailImageURL {
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
        } else {
            completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
}

class CustomPhotoModel: NSObject {
    
    var image: UIImage?
    var thumbnailImage: UIImage?
    
    var fileURL: URL?
    var thumbnailImageURL: URL?
    
    var mimeType: Int
    var contentType: String // eg: "video/mp4"
//    var contentType: String
    
//    private var fileExtension: String? {
//
//        guard let contentType = attachment.contentType  else {
//            return nil
//        }
//        let components = contentType.components(separatedBy: "/")
//        if components.count > 1 {
//            return components[1]
//        }
//        return nil
//    }
    
//    private var thumbNailDownloadName: String {
//
//        return fileDownloadName
//    }
    
//    private var fileDownloadName: String {
//        let name = "file" + "\(attachment.attachmentId ?? 0)"
//
//        guard let fileExtension = fileExtension else {
//            return name
//        }
//
//        return name + "." + fileExtension
//    }
    
    init(fileURL: URL?, thumbnailImageURL: URL?, mimeType: Int, contentType: String) {
        self.fileURL = fileURL
        self.thumbnailImageURL = thumbnailImageURL
        self.mimeType =  mimeType
        self.contentType = contentType
    }
    
}

extension CustomPhotoModel : INSPhotoViewable {
    
//    var fileURL: URL? {
//        if let url = attachment.contentUrl {
//            return URL.init(string: url)
//        }
//        return nil
//    }
    
//    var thumbnailImageURL: URL? {
//        if let thumbnailUrl = attachment.thumbnailUrl {
//            return URL.init(string: thumbnailUrl)
//        }
//        return nil
//    }
    var attributedTitle: NSAttributedString? {
        
        return NSAttributedString.init(string: "Filename", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    
//    var mimeType: Int  {
//
//        guard let contentType = attachment.contentType  else {
//            return MimeType.other.rawValue
//        }
//        if contentType.contains("image") {
//            return MimeType.image.rawValue
//        }
//        if contentType.contains("video") {
//            return MimeType.video.rawValue
//        }
//        if contentType.contains("pdf") {
//            return MimeType.pdf.rawValue
//        }
//        if contentType.contains("csv") {
//            return MimeType.csv.rawValue
//        }
//        if contentType.contains("rtf") {
//            return MimeType.rtf.rawValue
//        }
//        if contentType.contains("plain") {
//            return MimeType.other.rawValue // txt
//        }
//
//        if contentType.contains("html") {
//            return MimeType.html.rawValue // txt
//        }
//        if contentType.contains("audio") {
//                   return MimeType.audio.rawValue // txt
//               }
//        return MimeType.other.rawValue
//    }
    
    func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let url = fileURL {
            
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
        } else {
            completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
//    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
//    }

    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        
        switch MimeType.init(rawValue: mimeType) {
        case .image:
            completion(UIImage.init(named: "image"), nil)
        case .video:
            completion(UIImage.init(named: "video"), nil)
            return
        case .pdf:
            completion(UIImage.init(named: "pdf"), nil)
            return
        case .audio:
            completion(UIImage.init(named: "audio"), nil)
            return
        case .csv:
            completion(UIImage.init(named: "csv"), nil)
            return
        case .rtf:
            completion(UIImage.init(named: "text"), nil)
            return
        case .html:
            completion(UIImage.init(named: "doc"), nil)
            return
        default:
            completion(UIImage.init(named: "unsupported"), nil)
            return
        }
        /// Thumbnail doesn't have data, so loading full image
        if let url = fileURL {
            
            if let thumbnailImage = thumbnailImage {
                completion(thumbnailImage, nil)
                return
            }
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
//
//            if let url = thumbnailImageURL {
//            } else {
//                completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
//            }

//            IssuesManager.downloadFile(url: url.absoluteString, fileName: thumbNailDownloadName) { [weak self](response) in
//                switch response {
//                case .Success(let url):
//                    if let url = url, let data = try? Data.init(contentsOf: url) {
//
//                        let image = UIImage.init(data: data)
//                        self?.thumbnailImage = image
//                        completion(image, nil)
//                    } else {
//                        completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
//                    }
//                case .Failure(let error):
//                    completion(nil, error)
//                }
//            }
        } else {
            completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
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
