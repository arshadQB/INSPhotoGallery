//
//  MimeTypeManager.swift
//  Pods
//
//  Created by Arshad T P on 6/2/20.
//

import Foundation

public enum MimeType: Int {
    case image = 0
    case video
    case audio
    case pdf
    case csv
    case rtf
    case txt
    case excel
    case windowsDoc
    case html
    case other
}

public struct MimeTypeManager {
    
    public static let supportedVideoFormats:[String] = ["mp4","m4p", "qt", "quicktime", "mov", "mpeg", "gif", "gifv", "mpg"]
    public static let supportedAudioFormats: [String] = ["mp4", "m4p", "qt", "quicktime", "mp3", "wav", "mpeg", "mpg"]
    public static let unsupportedFileFormats: [String] = ["oasis.opendocument.text"]
    public static let htmlFormats: [String] = ["html", "htm"]
    public static let txtFormat: [String] = ["plain", "text"]
    public static let msExcelFormat: [String] = ["ms-excel", "spreadsheetml.sheet"]
    // refer https://stackoverflow.com/questions/4212861/what-is-a-correct-mime-type-for-docx-pptx-etc/4212908#4212908
    public static let microsoftOfficeFormat: [String] = ["msword", "officedocument", "ms-word", "ms-powerpoint", "ms-access"]
   
    /// Method auto detect MimeType from content type. If mimeType can't be detected from content type then  method use fileextension as fallback
    /// - Parameters:
    ///   - contentType: content type
    ///   - fileExtension: extension
    public static func getMimeTypeFrom(contentType: String?, fileExtension: String?) -> MimeType {
        
        var fileTypeBasedOnExtension: MimeType = .other
        if let fileExtension = fileExtension {
            fileTypeBasedOnExtension = getMimeTypeFrom(fileExtension: fileExtension)
        }
        
        guard let contentTypeStr = contentType?.lowercased() else {
            return fileTypeBasedOnExtension
        }
        
        if contentTypeStr.isUnsupportedContent { // Not supported
            return MimeType.other
        }
        
        if contentTypeStr.contains("image") {
            return MimeType.image
        }
        if contentTypeStr.contains("video") { // Limiting supported video formats
            if contentTypeStr.isSupportedVideoFormat {
                return MimeType.video
            }
            return MimeType.other
            
        }
        if contentTypeStr.contains("audio") { // Limiting supported audio formats
            if contentTypeStr.isSupportedAudioFormat {
                return MimeType.audio
            }
            return MimeType.other
        }
        
        if contentTypeStr.isHTMLContent {
            return MimeType.html
        }
        
        if contentTypeStr.contains("pdf") {
            return MimeType.pdf
        }
        //csv exported from ms-excel has content type "application/vnd.ms-excel". so checking extension also as a work-around
        if contentTypeStr.contains("csv") || fileTypeBasedOnExtension == MimeType.csv{
            
            return MimeType.csv
        }
        
        if contentTypeStr.contains("rtf") {
            return MimeType.rtf
        }
        if contentTypeStr.isTextContent {
            return MimeType.txt // txt
        }
        
        if contentTypeStr.isMSExcelContent {
            return MimeType.excel // application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        }
        
        
        if contentTypeStr.isMSOfficeContent
        {
            return MimeType.windowsDoc // Windows doc formats
            
        }
        // If contenttype is not recognzed then check file extension for type.
        // Work around to fix issues like eg: csv file imported from MS Excel has type application/xx-msxl-xx
        return fileTypeBasedOnExtension
    }
    
    private static func getMimeTypeFrom(fileExtension: String) -> MimeType {

        let type = fileExtension.lowercased()
        
        if type.isImageExtension {
            return MimeType.image
        }
        if type.isSupportedVideoFormat {
            return MimeType.video
        }
        if type.isSupportedAudioFormat {
            return MimeType.audio // txt
        }
        if type.contains("pdf") {
            return MimeType.pdf
        }
        if type.contains("csv") {
            return MimeType.csv
        }
        if type.contains("xls")  || type.contains("xlt") || type.contains("xla"){
            return MimeType.excel // application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        }
        if type.contains("rtf") {
            return MimeType.rtf
        }
        if type.contains("plain") {
            return MimeType.txt // txt
        }
        
        if type.contains("html") {
            return MimeType.html // txt
        }
        return MimeType.other
    }

}

fileprivate extension String {
    
    var isImageExtension: Bool {
        
        let imageExtensions = ["ANI","ANIM","APNG","ART","BMP","BPG","BSAVE","CAL","CIN","CPC",
                               "CPT","DDS","DPX","ECW","EXR","FITS","FLIC","FLIF","FPX","GIF",
                               "HDRi","HEVC","ICER","ICNS","ICO","CUR","ICS","ILBM",
                               "JBIG","JBIG2","JNG","JPEG","JPEG-LS","JPEG","JPEG",
                               "XR","JPEG","XT","JPEG-HDR","JPEG","XL","KRA","MNG",
                               "MIFF","NRRD","PAM","PBM","PGM","PPM","PNM","PCX",
                               "PGF","PICtor","PNG","PSD","PSB","PSP","QTVR","RAS",
                               "RGBE","Logluv","TIFF","SGI","TGA","TIFF","TIFF/EP"
            ,"TIFF/IT","UFO/","UFP","WBMP","WebP","XBM","XCF","XPM",
             "XWD","CIFF","DNG","Vector","AI","CDR","CGM","DXF",
             "EVA","EMF","EMF+",
             "Gerber","HVIF","IGES","PGML","SVG","VML","WMF",
             "Xar","Compound","CDF","DjVu","EPS","PDF","PICT","PS","SWF","XAML", "JPG"
        ]
        return imageExtensions.contains(self.uppercased())
    }
    
    var isSupportedVideoFormat: Bool {
        let result = MimeTypeManager.supportedVideoFormats.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }
    
    var isSupportedAudioFormat: Bool {
        
        let result = MimeTypeManager.supportedAudioFormats.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }

    var isUnsupportedContent: Bool {
        let result = MimeTypeManager.unsupportedFileFormats.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }
    
    var isHTMLContent: Bool {
        let result = MimeTypeManager.htmlFormats.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }
    
    var isTextContent: Bool {
        let result = MimeTypeManager.txtFormat.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }
    
    var isMSExcelContent: Bool {
        let result = MimeTypeManager.msExcelFormat.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }
    
    var isMSOfficeContent: Bool {
        let result = MimeTypeManager.microsoftOfficeFormat.filter {
            self.lowercased().contains($0)
        }
        return result.count > 0
    }
}
