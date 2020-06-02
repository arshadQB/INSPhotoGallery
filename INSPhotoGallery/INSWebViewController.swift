//
//  INSPhotoViewController.swift
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

import UIKit
import WebKit

open class INSWebViewController: UIViewController, INSPhotoDisplayController, UIGestureRecognizerDelegate {
    
    enum ViewState {
        case placeholder
        case loading
        case unsuppportedType
        case failed
        case retry
        case dataLoaded
    }
    
    public var photo: INSPhotoViewable
    var url: URL? = nil
    
    lazy private(set) var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        return activityIndicator
    }()
    
    lazy private(set) var placeholderImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.zero)
        imageView.contentMode = .center
        return imageView
    }()
    
    lazy private(set) var button: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.backgroundColor = .clear
        button.imageView?.contentMode  = .center
        button.contentMode = .center
        return button
    }()
    
    lazy private(set) var webView: WKWebView = {
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .black
        return webView
    }()
    
    private var viewState: ViewState = .placeholder {
        didSet {
           updateView()
        }
    }
    
    public init(photo: INSPhotoViewable) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        webView.isHidden = true
                
        view.addSubview(button)
        button.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.isUserInteractionEnabled = false

        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        activityIndicator.sizeToFit()
        updateView()
        loadThumbnailImage()
        loadData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if photo.mimeType == MimeType.audio.rawValue {
            pauseAudio()
        } else if  photo.mimeType == MimeType.video.rawValue {
           pauseVideo()
        }
        
    }
    
    
    @objc func buttonAction() {
        loadData()
    }
    
    private func pauseVideo() {
        let script = "var vids = document.getElementsByTagName('video'); for( var i = 0; i < vids.length; i++ ){vids.item(i).pause()}"
        self.webView.evaluateJavaScript(script, completionHandler:nil)
    }
    
    private func pauseAudio() {
           let script = "var vids = document.getElementsByTagName('audio'); for( var i = 0; i < vids.length; i++ ){vids.item(i).pause()}"
           self.webView.evaluateJavaScript(script, completionHandler:nil)
       }
    func updateView() {
        switch viewState {
        case .placeholder, .unsuppportedType:
            button.isUserInteractionEnabled = false
            button.setTitle(nil, for: .normal)
            button.isHidden = false
            activityIndicator.stopAnimating()
            webView.isHidden = true
        case .dataLoaded:
            button.isHidden = true
            activityIndicator.stopAnimating()
            webView.isHidden = false
        case .loading, .retry:
            button.isUserInteractionEnabled = false
            button.setTitle(nil, for: .normal)
            button.isHidden = false
            activityIndicator.startAnimating()
            webView.isHidden = true
        case .failed:
            button.isUserInteractionEnabled = true
//            button.setTitle("Retry", for: .normal)
            if let bundlePath = Bundle(for: type(of: self)).path(forResource: "INSPhotoGallery", ofType: "bundle") {
                let bundle = Bundle(path: bundlePath)
                let image = UIImage(named: "retry", in: bundle, compatibleWith: nil)
                button.setImage(image, for: .normal)
            }
//            self.button.centerVertically(padding: 50)
            self.button.sizeToFit()
            self.button.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            button.isHidden = false
            
            activityIndicator.stopAnimating()
            webView.isHidden = true
        }
        
        
    }
        
    func reloadData() {
        webView.reload()
    }
    
    private func canLoadData() -> Bool {
        if photo.mimeType == MimeType.other.rawValue {
            return false
        }
        return true
    }
    
    private func loadData()  {
        if !canLoadData() {
            return
        }
        view.bringSubviewToFront(activityIndicator)
        viewState = .loading
        photo.loadDataWithCompletionHandler?({ [weak self] (url, contentType, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    self?.viewState = .failed
                } else {
                    self?.viewState = .dataLoaded
                    if let url = url, let contentType = contentType {
                        self?.url = url
                        if url.scheme == "file" as String {
                            self?.loadDataInWebView(url: url, contentType: contentType)
                        }
                        else {
                            let request = URLRequest.init(url: url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:60)
                            self?.webView.load(request)
                        }
                    }
                }

            }
        })
    }
    
    private func loadDataInWebView(url: URL, contentType: String) {
        switch MimeType.init(rawValue: photo.mimeType) {
        case .csv:
            loadDoc(url: url, contentType: "text/csv")
        case .txt:
            loadDoc(url: url, contentType: "text/plain")
        case .excel, .windowsDoc:
            loadDoc(url: url, contentType: contentType)
        case .image, .pdf, .html, .rtf:
            if #available(iOS 9.0, *) {
                self.webView.loadFileURL(url, allowingReadAccessTo: url)
            } else {
                // Fallback on earlier versions
            }
        case .video:
            loadVideo(url: url, contentType: contentType)
        case .audio:
            loadAudio(url: url, contentType: contentType)
            break
        default:
            break
        }
        
    }
        
    private func loadDoc(url: URL, contentType: String) {
        do {
            let docContents = try Data(contentsOf: url)
            let urlStr = "data:\(contentType);base64," + docContents.base64EncodedString()
            let url = URL(string: urlStr)!
            let request = URLRequest(url: url)
            self.webView.load(request)
        } catch {
            print("Failed to load data")
        }
    }
    private func loadVideo(url: URL, contentType: String) {
        let html = WebViewHelper.createVideoHTML(forVideoAtPath: "\(url.absoluteString + "#t=0.1")", and: contentType)
        self.webView.loadHTMLString(html, baseURL: url)
    }
    
    private func loadAudio(url: URL, contentType: String) {
        let html = WebViewHelper.createAudioHTML(forAudioAtPath: "\(url.absoluteString)", and: contentType)
        self.webView.loadHTMLString(html, baseURL: url)
    }
    
    private func loadThumbnailImage() {
        photo.loadThumbnailImageWithCompletionHandler? { [weak self] (image, error) -> () in
            guard let self = self else {return}
            self.button.setImage(image, for: .normal)

//            if self.photo.mimeType == MimeType.other.rawValue {
//                self.button.setTitle("Not Supported", for: .normal)
//                self.button.centerVertically(padding: 50)
//            }
            self.button.sizeToFit()
            self.button.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            
        }
    }
    
    
    // MARK:- UIScrollViewDelegate
    
    //    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    //        return scalingImageView.imageView
    //    }
    
    //    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    //        scrollView.panGestureRecognizer.isEnabled = true
    //    }
    //
    //    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    //        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
    //        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
    //        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
    //            scrollView.panGestureRecognizer.isEnabled = false;
    //        }
    //    }
}

fileprivate extension UIButton {

    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            var titleLabelSize = self.titleLabel?.frame.size else {
            return
        }

        if  let titleStr = self.titleLabel?.text, titleLabelSize.width == 0 {
            let width = titleStr.width(constrainedBy: titleLabelSize.height, with: self.titleLabel?.font ?? UIFont.boldSystemFont(ofSize: 12))
            titleLabelSize = CGSize.init(width: width, height: titleLabelSize.height)
        }
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding

        self.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left:  titleLabelSize.width/2+imageViewSize.width/2,
            bottom: 0.0,
            right: 0
        )

        self.titleEdgeInsets = UIEdgeInsets(
            top: totalHeight,
            left: 0,
            bottom: 0,
            right: 0.0
        )

        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: imageViewSize.height,
            right: imageViewSize.width
        )
    }

}

fileprivate extension String {
    func height(constrainedBy width: CGFloat, with font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }

    func width(constrainedBy height: CGFloat, with font: UIFont) -> CGFloat {
        let constrainedRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constrainedRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.width
    }
}
