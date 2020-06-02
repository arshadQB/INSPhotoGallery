//
//  INSPhoto.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this library except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import UIKit
/*
 * This is marked as @objc because of Swift bug http://stackoverflow.com/questions/30100787/fatal-error-array-cannot-be-bridged-from-objective-c-why-are-you-even-trying when passing for example [INSPhoto] array
 * to INSPhotosViewController
 */


public protocol INSPhotoDisplayController: UIViewController  {
		var photo: INSPhotoViewable { get }
}

@objc public protocol INSPhotoViewable: class {
	
    var image: UIImage? { get }
    var thumbnailImage: UIImage? { get }
    var mimeType: Int { get }
    var fileURL: URL? { get }
    var thumbnailImageURL: URL? { get }

    @objc optional var isDeletable: Bool { get }
    
    @objc optional func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ())
    @objc optional func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ())
    @objc optional func loadDataWithCompletionHandler(_ completion: @escaping (_ fileURL: URL?,_ contentType: String?,  _ error: Error?) -> ())
    @objc optional func loadPlaceholderDataWithCompletionHandler(_ completion: @escaping (_ fileURL: URL?,  _ error: Error?) -> ())


    var attributedTitle: NSAttributedString? { get }
}



@objc open class INSPhoto: NSObject, INSPhotoViewable {
	
    @objc public var mimeType: Int = MimeType.image.rawValue
	
    @objc open var image: UIImage?
    @objc open var thumbnailImage: UIImage?
    @objc open var isDeletable: Bool
    
    public var fileURL: URL?
    public var thumbnailImageURL: URL?
    
    @objc open var attributedTitle: NSAttributedString?
    
    public init(image: UIImage?, thumbnailImage: UIImage?) {
        self.image = image
        self.thumbnailImage = thumbnailImage
        self.isDeletable = false
    }
    
    public init(imageURL: URL?, thumbnailImageURL: URL?) {
        self.fileURL = imageURL
        self.thumbnailImageURL = thumbnailImageURL
        self.isDeletable = false
    }
    
    public init (imageURL: URL?, thumbnailImage: UIImage?) {
        self.fileURL = imageURL
        self.thumbnailImage = thumbnailImage
        self.isDeletable = false
    }
    
    @objc open func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let image = image {
            completion(image, nil)
            return
        }
        loadImageWithURL(fileURL, completion: completion)
    }
    
    @objc open func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let thumbnailImage = thumbnailImage {
            completion(thumbnailImage, nil)
            return
        }
        loadImageWithURL(thumbnailImageURL, completion: completion)
    }
    
    open func loadImageWithURL(_ url: URL?, completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        if let imageURL = url {
            session.dataTask(with: imageURL, completionHandler: { (response, data, error) in
                DispatchQueue.main.async(execute: { () -> Void in
                    if error != nil {
                        completion(nil, error)
                    } else if let response = response, let image = UIImage(data: response) {
                        completion(image, nil)
                    } else {
                        completion(nil, NSError(domain: "INSPhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
                    }
                    session.finishTasksAndInvalidate()
                })
            }).resume()
        } else {
            completion(nil, NSError(domain: "INSPhotoDomain", code: -2, userInfo: [ NSLocalizedDescriptionKey: "Image URL not found."]))
        }
    }
}

public func ==<T: INSPhoto>(lhs: T, rhs: T) -> Bool {
    return lhs === rhs
}
