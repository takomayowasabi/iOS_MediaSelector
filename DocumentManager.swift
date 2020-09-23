//
//  DocumentManager.swift
//  DocumentPicker
//
//  Created by Jakob Tak on 2020. 09. 21..
//

import UIKit

let FILEPATHS = "selected_files"

typealias DocumentFetchCompletion = ((_ isFileSelected: Bool, _ fileName: String, _ fileExtension: String, _ filePath: String) -> Void)?

class DocumentManager: NSObject {
    
    //'DocumentManager.sharedInstance.함수명' 호출.
    static let sharedInstance = DocumentManager()
    
    private var documnetFetchCompletionHandler: DocumentFetchCompletion!
    
    //부모 뷰 설정.
    private var parentController: UIViewController?
    
    /// - 매개 변수:
    ///     - parentController
    ///             파일 저장소 띄우기전 뷰 지정해요.
    ///
    ///     - isFileSelected
    ///             파일이 지정되었는지 확인.
    ///
    ///     - fileName
    ///             클라우드에 지정된 파일 이름.
    ///
    ///     - fileExtension
    ///             파일의 확장명.
    ///     - filePath
    ///             캐시로 임의 저장된 파일의 경로.
    
    func showDocumentMenuController(_ parentController:  UIViewController, complitionhandler:@escaping (_ isFileSelected: Bool, _ fileName: String, _ fileExtension: String, _ filePath: String) -> Void) {
        self.documnetFetchCompletionHandler = complitionhandler
        self.parentController = parentController
        
        self.deleteFolderInCacheFolder()
        self.createFolderInCacheFolder()
        
        let documentPicker = UIDocumentPickerViewController.init(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .popover
        self.parentController?.present(documentPicker, animated: true, completion: nil)
    }
    
}

extension DocumentManager : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .import {
            let coordinator = NSFileCoordinator()
            
            coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: nil, byAccessor: { (url) in
                let fileName = url.deletingPathExtension().lastPathComponent
                let fileExtension = url.pathExtension
                let desinationPath = self.getSelectedFilesFolder()?.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
                let fileManager = FileManager.default
                do {
                    try fileManager.copyItem(at: url, to: desinationPath!)
                    if self.documnetFetchCompletionHandler != nil {
                        self.documnetFetchCompletionHandler!(true, fileName, fileExtension, desinationPath!.path)
                    }
                } catch {
                    if self.documnetFetchCompletionHandler != nil {
                        self.documnetFetchCompletionHandler!(false, "", "", "")
                    }
                }
            })
        }
    }
    
    //파일선택 취소시 초기화
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if self.documnetFetchCompletionHandler != nil {
            self.documnetFetchCompletionHandler!(false, "", "", "")
        }
    }
}

extension DocumentManager: UIDocumentMenuDelegate {
    //파일 목록 띄우기
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.parentController?.present(documentPicker, animated: true, completion: nil)
    }
}

extension DocumentManager {
    
    //캐시 전용 임시 폴더 생성
    private func createFolderInCacheFolder() {
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent(FILEPATHS)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Failed to create directory")
                }
            }
            print("saved as \(filePath)")
        }
    }
    
    //캐시 전용 임시 폴더 삭제
    private func deleteFolderInCacheFolder() {
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent(FILEPATHS)
            if fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.removeItem(at: filePath)
                } catch {
                    print("Failed to del directory")
                }
            }
        }
    }
    
    //URL 값 리턴
    private func getSelectedFilesFolder() -> URL? {
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent(FILEPATHS)
            return filePath
        }
        return nil
    }
    
}
