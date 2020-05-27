//
//  VideoPlayerHelper.swift
//  INSPhotoGallery
//
//  Created by Arshad T P on 5/21/20.
//

import Foundation
import UIKit

class WebViewHelper {
	
    private static func getHTMLFile(name: String) -> String {
		if let bundlePath = Bundle(for:self).path(forResource: "INSPhotoGallery", ofType: "bundle") {
			let bundle = Bundle(path: bundlePath)
			guard let filePath = bundle?.url(forResource: name, withExtension: "html") else {
				fatalError("Can't find the VideoPage.html in bundle")
			}
			if let html = try? String.init(contentsOf: filePath, encoding: String.Encoding.utf8) {
				return html
			}
		}
		fatalError("Couldn't load video page")
	}
	
	static func createVideoHTML(forVideoAtPath path: String, and type: String) -> String {
		
		let html = getHTMLFile(name: "VideoPage")
		return String(format: html, path, type)
		
	}
    
    static func createTemplateHTML(forImagePath path: String) -> String {
        
        let html = getHTMLFile(name: "TemplatePage")
        return String(format: html, path)
    }
    
    static func createAudioHTML(forAudioAtPath path: String, and type: String) -> String {
        
        let html = getHTMLFile(name: "AudioPage")
        return String(format: html, path, type)
        
    }
	
}
