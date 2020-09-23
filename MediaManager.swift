//
//  MediaManager.swift
//  IOS_upload_protocol
//
//  Created by Jakob Tak on 2020. 09. 21..
//

import UIKit
import MobileCoreServices

class MediaManager : NSObject{
    
    //쓰기편하라고 만든거에요.
    private struct ezMediaType {
        static let image = kUTTypeImage as String
        static let video = kUTTypeMovie as String
    }
    
    //'MediaManager.sharedInstance.함수명' 호출.
    static let sharedInstance = MediaManager()
    
    //부모 뷰 설정.
    private var parentController : UIViewController?
    private var getPreview : ((UIImage) -> ())?
    private var getMovieURL : ((URL) -> ())?
    private var getImageURL : ((URL) -> ())?
    
    ///- 매개변수 :
    ///     - parentController :
    ///         부모뷰에요.
    ///     - getURL :
    ///         URL값을 리턴.
    ///     - getPreview :
    ///         UIImage를 리턴.
    
    private func getPickerController(sourceType : UIImagePickerController.SourceType, mediaType : String) -> UIImagePickerController{
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = [mediaType]
        pickerController.sourceType = sourceType
        return pickerController
    }
    
    func getVideoURL(for controller : UIViewController, completion : @escaping ((URL) -> ())){
        self.parentController = controller
        self.getMovieURL = completion
        let picker = self.getPickerController(sourceType: .savedPhotosAlbum, mediaType: ezMediaType.video)
        self.parentController?.present(picker, animated : true)
    }
    
    func getImageURL(for controller : UIViewController, completion : @escaping ((URL) -> ())){
        self.parentController = controller
        let picker = self.getPickerController(sourceType: .savedPhotosAlbum, mediaType: ezMediaType.image)
        self.parentController?.present(picker, animated : true)
    }
    
    func getImagePreview(for controller : UIViewController, completion : @escaping ((UIImage) -> ())){
        self.parentController = controller
        self.getPreview = completion
        let picker = self.getPickerController(sourceType: .savedPhotosAlbum, mediaType: ezMediaType.image)
        self.parentController?.present(picker, animated : true)
    }
    
}

extension MediaManager : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    //취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.parentController?.dismiss(animated: true, completion: nil)
    }

    //완료
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        //이미지 미리 띄울라면 쓰세요
        if let preview = info[.originalImage] as? UIImage {
            self.parentController?.dismiss(animated: true, completion: {
                self.getPreview?(preview)
            })
        }
        
        //동영상 경로 가져오기
        else if let url = info[.mediaURL] as? URL{
            self.parentController?.dismiss(animated: true, completion: {
                self.getMovieURL?(url)
            })
        }
        
        else if let url = info[.imageURL] as? URL{
            self.parentController?.dismiss(animated: true, completion: {
                self.getImageURL?(url)
            })
        }
        
    }
}
