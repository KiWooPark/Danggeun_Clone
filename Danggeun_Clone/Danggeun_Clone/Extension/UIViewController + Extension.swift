//
//  Preview.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/05.
//

import Foundation
import BSImagePicker
import UIKit
import Photos

extension UIViewController {
    func bsImagePicker(max: Int, totalCount: Int = 0, completion: @escaping ([PHAsset]) -> ()) {
        let imagePicker = ImagePickerController()
        var count = totalCount

        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.settings.selection.max = max
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.theme.selectionFillColor = .black
        imagePicker.doneButton.tintColor = .black
        imagePicker.doneButtonTitle = "확인"
        imagePicker.cancelButton.tintColor = .black
        
        presentImagePicker(imagePicker) { asset in
            if max == 10 {
                if count == 10 {
                    imagePicker.deselect(asset: asset)
                    let storyboard = UIStoryboard(name: "PhotoPopup", bundle: nil)
                    guard let vc = storyboard.instantiateViewController(withIdentifier: "photoPopupView") as? PhotoPopupViewController else { return }
                    vc.photoCount = 10 - totalCount
                    vc.modalPresentationStyle = .overFullScreen
                    imagePicker.present(vc, animated: false)
                } else {
                    count += 1
                }
            }
        } deselect: { asset in
            print("선택 해제")
            count -= 1
        } cancel: { assets in
            print("취소")
        } finish: { assets in
            print("완료")
            completion(assets)
        }
    }
    
    func convertAssetToImages(assetArr: [PHAsset]) -> [UIImage] {
        
        var images = [UIImage]()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.deliveryMode = .opportunistic
        
        if !assetArr.isEmpty {
            for asset in assetArr {
                imageManager.requestImage(for: asset,
                                          targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                          contentMode: .aspectFill,
                                          options: option) { image, info in
                    if let data = image?.jpegData(compressionQuality:0.8) {
                        if let newImage = UIImage(data: data) {
                            images.append(newImage)
                        }
                    }
                }
            }
        }
        return images
    }
}



