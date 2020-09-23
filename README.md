# iOS_MediaSelector

IOS 사진/동영상/파일 선택기

      아이폰 내부 저장소/iCloud의 파일을 외부로 내보내기 위해 만든 .swift 입니다.

      사진의 로컬 디렉토리/ UIImage 값 반환.
      동영상을 압축, 로컬 캐시 폴더로 저장. 새로 생성된 파일의 디렉토리 반환.
      FILES의 iOS 내부 로컬데이터/ iCloud를 앱의 로컬 캐시 폴더로 복사 후, 해당 파일의 디렉토리 반환.

      앨범 권한 부여를 위해 Privacy - Photo Library Usage Description 필요.


# 사용 법

      //아이폰 로컬 데이타/iCloud 파일 localPath 반환.
      DocumentManager.sharedInstance.showDocumentMenuController(self) { (isFileSelected, fileName, fileExtension, filePath) in
                  //code
              }

      //선택한 앨범 내부 사진 데이터(UIImage)반환.
      MediaManager.sharedInstance.getImagePreview(for: self) { (UIImage) in
                 //code
              }

      //선택한 앨범 내부 사진 localPath 반환.
      MediaManager.sharedInstance.getImageURL(for: self) { (URL) in
                 //code
              }

      //선택한 앨범 내부 동영상의 압축된 캐시 데이터의 localPath반환.
      MediaManager.sharedInstance.getVideoURL(for: self) { (URL) in
                  //code
              }
