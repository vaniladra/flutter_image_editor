//
//  ExifKeeper.swift
//  image_editor
//
//  Created by Caijinglong on 2019/11/13.
//

import Foundation

class UIImageWrapper{
    var image:UIImage?
    var exifKeeper:ExifKeeper?
    
    init(image:UIImage?,exifKeeper:ExifKeeper?) {
        self.image = image
        self.exifKeeper = exifKeeper
    }
}

class ExifKeeper {
    
    var data:Data?
    
    init(data:Data?) {
        self.data = data
    }
    
    func saveExif(data:Data?) -> Data?{
        guard let mData = data else {
            return data
        }
        
        guard let cgImage = CGImageSourceCreateWithData(mData as CFData, nil) else {
            return data
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(cgImage, 0, nil) as Dictionary? else{
            return data
        }
        
        guard let exifDict = properties[kCGImagePropertyExifDictionary] else{
            return data
        }

        
        
        return mData
    }
    
    func saveExif(path:String){
        
    }
}
