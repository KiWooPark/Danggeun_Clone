//
//  ProductRegistraionViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/05/17.
//

import UIKit
import BSImagePicker
import Firebase
import FirebaseFirestore
import Photos

class ProductRegistraionViewController: UIViewController {

    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var photosCollectionView: UICollectionView!
    @IBOutlet var productTitleTextField: UITextField!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var contentPlaceholderLabel: UILabel!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    let imagePicker = ImagePickerController()
    let db = Firestore.firestore()
    
    var selectedImages = [UIImage]()
    
    var imagesURL = [String]()
    
    var accessType = AccessType.registraionVC
    
    var productData: ProductRegistrationModel?
    var userData: UserModel?
    var isFirst = false
    var vcType = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainScrollView.keyboardDismissMode = .onDrag
        contentTextView.isScrollEnabled = false
        
        userData = UserModel.getUserData()
        
        productTitleTextField.text = "제목"
        categoryLabel.text = "디지털기기"
        priceTextField.text = "1111"
        contentTextView.text = "123123"
        
        configData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        // 리턴값 사용 안함
        //_ = checkAuthAddress()
    }
    
    func checkAuthAddress() -> Bool {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "addressAuthPopupVC") as? AddressAuthPopupViewController else { return false }
        vc.rootView = self
        vc.addressName = userData?.selectedAddress ?? ""
        
        // 인증되어 있지 않으면
        // 동네인증VC갔다가 오면 true <<
        if userData?.selectedAddress == userData?.address1 { // 선택한 동네가 첫번째면
            if userData?.authAddress1 == false {
                if accessType == .registraionVC {
                    if isFirst == false {
                        isFirst = true
                        vc.isFirst = isFirst
                        self.present(vc, animated: false)
                    }
                } else if accessType == .doneButton {
                    self.present(vc, animated: false)
                }
                return false
            } else {
                return true
            }
        } else { // 선택한 동네가 두번째면
            if userData?.authAddress2 == false {
                if accessType == .registraionVC {
                    if isFirst == false {
                        isFirst = true
                        vc.isFirst = isFirst
                        self.present(vc, animated: false)
                    }
                } else if accessType == .doneButton {
                    self.present(vc, animated: false)
                }
                return false
            } else {
                return true
            }
        }
    }
    
    func configData() {
        if vcType == "edit" {
            productTitleTextField.text = productData?.title
            categoryLabel.text = productData?.category
            priceTextField.text = productData?.price
            contentTextView.text = productData?.content
            
            FirebaseManager.shared.downloadImages(urls: productData?.imagesURL ?? []) { images in
                self.selectedImages = images
                
                DispatchQueue.main.async {
                    self.photosCollectionView.reloadData()
                }
            }
        } else {
            contentPlaceholderLabel.text = "\(self.userData?.selectedAddress ?? "")에 올릴 게시글 내용을 작성해주세요.(가품 및 판매금지품목은 게시가 제한될 수 있어요.)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "category" {
            guard let vc = segue.destination as? CategoryViewController else { return }
            vc.delegate = self
            vc.selectedCategory = categoryLabel.text ?? ""
        }
    }
    
    
    @IBAction func tapBackButton(_ sender: Any) {
        if vcType == "edit" {
            self.navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {

        accessType = .doneButton
        
//        let id = db.collection("게시글").document().documentID
        
//        Task {
//            do {
//                try await FirebaseManager.shared.checkAddressDocument(address: userData?.selectedAddress ?? "")
//
//                if selectedImages.isEmpty {
//                    // 상품 업로드
//                    addDocument(id: id)
//                } else {
//                    FirebaseManager.shared.uploadImage(images: selectedImages, uploadType: .addProductImage, documentID: id, phoneNumber: userData?.phoneNumber ?? "") { urls in
//                        self.imagesURL = urls
//
//                        // 상품 업로드
//                        self.addDocument(id: id)
//                    }
//                }
//            } catch {
//                // 에러처리
//            }
//        }
        
        
//        if !checkAuthAddress() {
//            doneButton.isEnabled = false
//        } else {
            // 입력 상태 체크 추가 필요
            // 서버에 상품 데이터 추가하기
            // 유저별로 상품 이미지 저장할 폴더(유저이름, 게시물 이름) 생성 및 저장

            if productTitleTextField.text != "" && categoryLabel.text != "카테고리 선택" && contentTextView.text != "" {
                // 파이어베이스에 컬렉션 있는지 확인
                let id = db.collection("게시글").document().documentID

                Task {
                    do {
                        try await FirebaseManager.shared.checkAddressDocument(address: userData?.selectedAddress ?? "")

                        // 이미지 없을때
                        if selectedImages.isEmpty {
                            // 상품 업로드
                            addDocument(id: id)
                        } else {
                            FirebaseManager.shared.uploadImages(images: selectedImages, uploadType: .productsImage, documentID: id, phoneNumber: userData?.phoneNumber ?? "") { urls in
                                self.imagesURL = urls

                                // 상품 업로드
                                self.addDocument(id: id)
                            }
                        }
                    } catch {
                        // 에러처리
                    }
                }
            } else {
                // 경고 팝업 조건
                // 팝업 추가 필요
                let checkTextList = [productTitleTextField.text != "", categoryLabel.text != "카테고리 선택", contentTextView.text != ""]
                var resultStrs = [String]()

                for i in 0..<checkTextList.count {
                    if checkTextList[i] == false {
                        switch i {
                        case 0:
                            resultStrs.append("제목")
                        case 1:
                            resultStrs.append("카테고리")
                        case 2:
                            resultStrs.append("내용")
                        default:
                            break
                        }
                    }
                }
            }
//        }
    }
    
    
    func addDocument(id: String) {
        guard let productTitle = productTitleTextField.text else { return }
        guard let category = categoryLabel.text else { return }
        guard let price = priceTextField.text else { return }
        guard let content = contentTextView.text else { return }
        
        guard let separationAddress = userData?.selectedAddress.components(separatedBy: " ") else { return }
        
        
        
        var finishedQuery: DocumentReference?
        
        switch separationAddress.count {
        case 2:
            finishedQuery = db.collection("게시글").document("행정구역").collection(separationAddress[0]).document(separationAddress[1]).collection("상품").document(id)
        case 3:
            finishedQuery = db.collection("게시글").document("행정구역").collection(separationAddress[0]).document(separationAddress[1]).collection("행정동").document(separationAddress[2]).collection("상품").document(id)
        case 4:
            finishedQuery = db.collection("게시글").document("행정구역").collection(separationAddress[0]).document(separationAddress[1]).collection("행정구").document(separationAddress[2]).collection("행정동").document(separationAddress[3]).collection("상품").document(id)
        default:
            break
        }
    
        if vcType == "edit" {
            finishedQuery?.updateData(["title": productTitle,
                                      "contents": content,
                                      "price": price,
                                      "category": category,
                                      "phoneNumber": userData?.phoneNumber ?? "",
                                      "photos": imagesURL,
                                      "address": userData?.selectedAddress ?? "",
                                      "update": Date(),
                                      "productId": productData?.productId ?? "",
                                      "status": productData?.status ?? ""]) { error in
                if let error = error {
                    print("게시글 수정 실패", error)
                }
            }
        } else {
            finishedQuery?.setData([
                "title": productTitle,
                "contents": content,
                "price": price,
                "category": category,
                "phoneNumber": self.userData?.phoneNumber ?? "",
                "photos": imagesURL,
                "address": self.userData?.selectedAddress ?? "",
                "update": Date(),
                "productId": id,
                "status": ProductStatusType.onSale.rawValue,
                "reservation": false
            ], completion: { error in
                if let error = error {
                    print("상품 데이터 생성 실패", error)
                } else {
                    //이부분에서 문서번호 유저정보에 추가해주기
                    // 저장할 이름에 지역정보 넣어줘서 검색하도록
                    let productsData = id + "/" + (self.userData?.selectedAddress ?? "")
                    self.db.collection("유저정보").document(self.userData?.phoneNumber ?? "").updateData(["products": FieldValue.arrayUnion([productsData])])
                    self.dismiss(animated: true)
                    
                    // 테이블뷰 리로드 필요
                    NotificationCenter.default.post(name: .reloadProductListTableView, object: nil)
                }
            })
        }
    }
}



extension ProductRegistraionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        contentPlaceholderLabel.isHidden = textView.text?.count ?? 0 > 0 ? true : false
    }
}

extension ProductRegistraionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return selectedImages.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPhotoCell", for: indexPath) as? AddPhotosCollectionViewCell else { return UICollectionViewCell() }
            cell.countLabel.text = "\(selectedImages.count)"
            
            if selectedImages.count > 0 {
                cell.countLabel.textColor = UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1)
            } else {
                cell.countLabel.textColor = .black
            }
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as? PhotosCollectionViewCell else { return UICollectionViewCell() }
            cell.delegate = self
            cell.deleteButton.tag = indexPath.row
            cell.selectedImageView.image = selectedImages[indexPath.row].resizeThumbnailTo()
            cell.representativeLabel.isHidden = indexPath.row == 0 ? false : true
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension ProductRegistraionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            if selectedImages.count == 10 {
                let alert = UIAlertController(title: "알림", message: "이미지는 최대 10까지 첨부할 수 있어요", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "닫기", style: .cancel)
                alert.addAction(cancel)
                present(alert, animated: true)
            } else {
                let totalCount = selectedImages.count
                bsImagePicker(max: 10, totalCount: totalCount) { assets in
                    self.selectedImages += self.convertAssetToImages(assetArr: assets)
                    self.photosCollectionView.reloadData()
                }
            }
        }
    }
}

extension ProductRegistraionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        case 1:
            return UIEdgeInsets(top: 0, left: -10, bottom: 10, right: 20)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.height * 0.1
        let height = width
        
        return CGSize(width: width, height: height)
    }
}

extension ProductRegistraionViewController: PhotosCollectionViewDelegate, CategoryViewDelegate {
    func changeCategoryName(categoryName: String) {
        categoryLabel.text = categoryName
    }
    
    func deletePhoto(index: Int) {
        selectedImages.remove(at: index)
        photosCollectionView.reloadData()
    }
}
