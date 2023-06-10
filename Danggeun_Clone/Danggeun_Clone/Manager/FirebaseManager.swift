//
//  FirebaseManager.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/13.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import UIKit

// MARK: [Class or Struct] ----------
class FirebaseManager {
    
    // MARK: [Let Or Var] ----------
    static let shared = FirebaseManager()
    private init() {}
    
    let db = Firestore.firestore()
    
    // 마지막 문서 체크 배열
    var lastProductDocuments = [String: QueryDocumentSnapshot]()
    var lastCategoryProductDocuments = [String: QueryDocumentSnapshot]()
    var lastAllOtherProductDocument: DocumentSnapshot?
    var lastTradingOtherProductDocument: DocumentSnapshot?
    var lastCompletedOtherProductDocument: DocumentSnapshot?
    var lastHiddenOtherProductDocument: DocumentSnapshot?
    var lastLikeProductDocument: DocumentSnapshot?

    // 현재 가지고온 데이터외에 다른 데이터가 더 있는지 체크하는 변수
    var productsHasNextPage = false
    var categoryProductsHasNextPage = false
    var allOtherProductHasNextPage = false
    var tradingOtherProductHasNextPage = false
    var completedOtherProductHasNextPage = false
    var hiddenOtherProductHasNextPage = false
    var likeProductsHaseNextPage = false
    
    // 지역 이름 나눈 카운트별로 만들 쿼리 변수 (페이징 처리할때 사용)
    var productFinalQuery: CollectionReference?
    var categoryProductFinalQuery: CollectionReference?
    var allOtherProductFinalQuery: CollectionReference?
    var tradingOtherProductFinalQuery : CollectionReference?
    var completedOtherProductFinalQuery : CollectionReference?
    var hiddenOtherProductFinalQuery: CollectionReference?

    // MARK: [Function] ---------- 유저 정보 관련 ----------
    /// 유저 정보 가져오기
    /// - Parameters:
    ///   - phoneNumber: 핸드폰 번호
    ///   - completion: 응답 처리
    func fetchUserData(phoneNumber: String, completion: @escaping (Result<UserModel,FirebaseError>) -> ()) {
        db.collection("유저정보").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { snapShot, error in
            if let error = error {
                completion(.failure(.getUserDataError(error)))
            }
            
            guard let userDocument = snapShot?.documents.first?.data() else { return completion(.failure(.emptyUserDataError))}
            
            completion(.success(UserModel(data: userDocument)))
        }
    }

    /// 서버에 저장된 유저 정보 가져오기
    /// - Parameters:
    ///   - userPhoneNumber: 핸드폰 번호
    ///   - completion: 응답 처리
    func getUserData(userPhoneNumber: String, completion: @escaping (UserModel?) -> ()) {
        db.collection("유저정보").whereField("phoneNumber", isEqualTo: userPhoneNumber).getDocuments { snapShot, error in
            if let error = error {
                print("FirebaseManager - \(#function) = 유저정보 가져오기 실패")
            }

            guard let userDocument = snapShot?.documents.first?.data() else {
                completion(nil)
                return
            }

            completion(UserModel(data: userDocument))
        }
    }
    
    /// 프로필 데이터 수정 (이미지, 닉네임)
    /// - Parameters:
    ///   - phoneNumber: 핸드폰 번호
    ///   - nickname: 변경할 닉네임 (동일하면 nil)
    ///   - profileImage: 변경할 프로필 이미지 (동일하면 nil)
    ///   - completion: 응답 처리
    func updateProfileData(phoneNumber: String, nickname: String?, profileImage: UIImage?, completion: @escaping (UserModel) -> ()) {

        var loginUserData = UserModel.getUserData()
        
        if nickname != nil && profileImage != nil {
            deleteStoregeInProductAndProfileImages(id: "", phoneNumber: phoneNumber, process: "ProfileImage") {
                
                self.uploadImages(documentId: "", phoneNumber: phoneNumber, images: [profileImage!], uploadType: .profileImage) { result in
                    switch result {
                    case .success(let url):
                        self.db.collection("유저정보").document(phoneNumber).updateData(["nickname": nickname ?? "", "profileImageUrl": url[0]]) { _ in
                            
                            loginUserData?.nickname = nickname
                            loginUserData?.profileImageUrl = url[0]
                            
                            if let loginUserData = loginUserData {
                                completion(loginUserData)
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else if nickname == nil && profileImage != nil {
            deleteStoregeInProductAndProfileImages(id: "", phoneNumber: phoneNumber, process: "ProfileImage") {
                
                self.uploadImages(documentId: "", phoneNumber: phoneNumber, images: [profileImage!], uploadType: .profileImage) { result in
                    switch result {
                    case .success(let url):
                        self.db.collection("유저정보").document(phoneNumber).updateData(["profileImageUrl": url[0]]) { _ in
                            
                            loginUserData?.profileImageUrl = url[0]
                            
                            if let loginUserData = loginUserData {
                                completion(loginUserData)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else if nickname != nil && profileImage == nil {
            self.db.collection("유저정보").document(phoneNumber).updateData(["nickname": nickname ?? ""]) { _ in
                
                loginUserData?.nickname = nickname

                if let loginUserData = loginUserData {
                    completion(loginUserData)
                }
            }
        }
    }
    
    // MARK: [Function] ---------- 상품 카운트 관련 ----------
    /// 상품 카운트 가져오기
    /// - Parameters:
    ///   - phoneNumber: 유저 핸드폰 번호
    ///   - completion: 응답 처리
    func getProductsCount(phoneNumber: String, completion: @escaping (Result<[String: Int]?, FirebaseError>) -> ()) {
        
        db.collection("유저정보").document(phoneNumber).getDocument { snapShot, error in
            if let error = error {
                completion(.failure(.urlError))
            } else {
                let productsCount = snapShot?.data()?["productsCount"] as? [String: Int]
                completion(.success(productsCount))
            }
        }
    }
    
    /// 전체, 거래중, 거래완료 카운트 가져오기
    /// - Parameters:
    ///   - phoneNumber: 핸드폰 번호
    ///   - completion: 응답 처리
    func fetchOtherProductsCount(phoneNumber: String, completion: @escaping (Result<[String: Int]?, FirebaseError>) -> ()) {
        
        db.collection("유저정보").document(phoneNumber).getDocument { snapShot, error in
            if let error = error {
                print(error)
            }
      
            guard let counts = snapShot?.data()?["productsCount"] as? [String:Int] else { return completion(.success(nil)) }
        
            completion(.success(counts))
        }
    }
    
    // MARK: [Function] ---------- 관심 상품 관련 ----------
    /// 관심 목록에 등록된 상품 가져오기
    /// - Parameter completion: 응답 처리
    func fetchLikeProducts(completion: @escaping (Result<[ProductRegistrationModel?],FirebaseError>) -> ()) {
        
        let group = DispatchGroup()
        
        let loginUserData = UserModel.getUserData()
        
        // 관심상품 10개씩 가지고오기
        db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("관심목록").order(by: "update", descending:     true).limit(to: 10).getDocuments { snapShot, error in
            if let error = error {
                completion(.failure(.urlError))
            } else {
                var productList = Array<ProductRegistrationModel?>(repeating: nil, count: snapShot?.count ?? 0)
                
                if let documents = snapShot?.documents {
                    for (index, productData) in documents.enumerated() {
                        group.enter()
                        guard let productSemiData = productData.data()["address"] as? String else { return completion(.failure(.urlError))}
                        let separatedAddress = productSemiData.components(separatedBy: " ")
                        
                        var finishedQuery: CollectionReference?
                        
                        switch separatedAddress.count {
                        case 2:
                            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
                        case 3:
                            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
                        case 4:
                            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
                        default:
                            print("fetchLikeProduct - addProduct - default")
                        }
                        
                        guard let productId = productData["id"] as? String else { return }
                        finishedQuery?.document(productId).getDocument(completion: { snapShot, error in
                            if let error = error {
                                print(error)
                            } else {
                                if let document = snapShot {
                                    productList.remove(at: index)
                                    productList.insert(ProductRegistrationModel(singleData: document), at: index)
                                    group.leave()
                                }
                            }
                        })
                    }
                }
                
                group.notify(queue: .main) {
                    self.likeProductsHaseNextPage = snapShot?.documents.count == 0 ? false : true
                    self.lastLikeProductDocument = snapShot?.documents.last
                    completion(.success(productList))
                }
            }
        }
    }
    
    /// 관심상품 페이징 처리
    /// - Parameter completion: 응답 처리
    func pagingLikeProducts(completion: @escaping (Result<[ProductRegistrationModel?],FirebaseError>) -> ()) {
        
        let group = DispatchGroup()
        
        let loginUserData = UserModel.getUserData()
        
        if let lastDocument = lastLikeProductDocument {
            db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("관심목록").order(by: "update", descending: true).start(afterDocument: lastDocument).limit(to: 10).getDocuments { snapShot, error in
                if let error = error {
                    completion(.failure(.urlError))
                } else {
                    
                    var productList = Array<ProductRegistrationModel?>(repeating: nil, count: snapShot?.count ?? 0)
                    
                    if let documents = snapShot?.documents {
                        for (index, productData) in documents.enumerated() {
                            group.enter()
                            guard let productSemiData = productData.data()["address"] as? String else { return completion(.failure(.urlError))}
                            let separatedAddress = productSemiData.components(separatedBy: " ")
                            
                            var finishedQuery: CollectionReference?
                            
                            switch separatedAddress.count {
                            case 2:
                                finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
                            case 3:
                                finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
                            case 4:
                                finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
                            default:
                                print("fetchLikeProduct - addProduct - default")
                            }
                            
                            guard let productId = productData["id"] as? String else { return }
                            finishedQuery?.document(productId).getDocument(completion: { snapShot, error in
                                if let error = error {
                                    print(error)
                                } else {
                                    if let document = snapShot {
                                        productList.remove(at: index)
                                        productList.insert(ProductRegistrationModel(singleData: document), at: index)
                                        group.leave()
                                    }
                                }
                            })
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.lastLikeProductDocument = snapShot?.documents.last
                        self.likeProductsHaseNextPage = snapShot?.documents.count == 10 ? true : false
                        completion(.success(productList))
                    }
                }
            }
        }
    }
    
    /// 관심 목록에 등록한 상품 카운트 가져오기
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - completion: 응답 처리
    func fetchLikeCount(id: String, address: String, completion: @escaping (Int) -> ()) {
        
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        var finalQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("fetchLikeCount - default")
        }
        
        finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).collection("관심목록").getDocuments(completion: { snapShot, error in
            if let error = error {
                print(error)
            }
            
            let count = snapShot?.documents.count ?? 0
            
            completion(count)
        })
    }
    
    /// 상품 디테일 화면으로 진입시 해당 상품이 내 관심목록에 등록됬는지 체크
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - completion: 응답 처리
    func fetchIsLike(id: String, address: String, completion: @escaping (Bool) -> ()) {
        
        let loginUserData = UserModel.getUserData()
        
        db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("관심목록").document(id).getDocument { snapShot, error in
            if let error = error {
                print(error)
            }
            
            let isLike = snapShot?.data() == nil ? false : true
            
            completion(isLike)
        }
    }
    
    /// 관심 상품에 추가한 상품 업데이트
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - isLike: 현재 관심 상태 (등록된 상태: true, 해제된 상태: false)
    ///   - completion: 응답 처리
    func updateLike(id: String, address: String, isLike: Bool, completion: @escaping (Bool, Int) -> ()) {
        
        // 상품에도 관심 등록
        let group = DispatchGroup()
        
        let loginUserData = UserModel.getUserData()
        
        var resultIsLike = false
        var resultLikeCount = 0
        
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        var finalQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("")
        }
        
        if isLike {
            group.enter()
            finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).collection("관심목록").document(loginUserData?.phoneNumber ?? "").delete(completion: { error in
                if let error = error {
                    print(error)
                }
                
                // 좋아요 카운트 업데이트
                finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).getDocument(completion: { snapShot, error in
                    if let error = error {
                        print(error)
                    } else {
                        if let likeCount = snapShot?.data()?["likeCount"] as? Int {
                            resultLikeCount = likeCount - 1
                            finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).updateData(["likeCount": resultLikeCount], completion: { error in
                                if let error = error {
                                    print(error)
                                }
                            })
                            group.leave()
                        }
                    }
                })
            })
            
            group.enter()
            db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("관심목록").document(id).delete { error in
                if let error = error {
                    print(error)
                }
                group.leave()
            }
            
            resultIsLike = false
            
        } else {
            // 해당 상품 정보 관심 목록에 로그인 유저 번호 저장
            group.enter()
            finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).collection("관심목록").document(loginUserData?.phoneNumber ?? "").setData([:], completion: { error in
                if let error = error {
                    print(error)
                }
                
                // 좋아요 카운트 업데이트
                finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).getDocument(completion: { snapShot, error in
                    if let error = error {
                        print(error)
                    } else {
                        if let likeCount = snapShot?.data()?["likeCount"] as? Int {
                            resultLikeCount = likeCount + 1
                            finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).updateData(["likeCount": resultLikeCount], completion: { error in
                                if let error = error {
                                    print(error)
                                }
                            })
                            
                        } else {
                            resultLikeCount = 1
                            finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).updateData(["likeCount": resultLikeCount], completion: { error in
                                if let error = error {
                                    print(error)
                                }
                            })
                        }
                        group.leave()
                    }
                })
            })
            
            // 로그인 유저 정보에도 관심 등록
            group.enter()
            db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("관심목록").document(id).setData(["address": address, "id": id, "update": Date()]) { error in
                if let error = error {
                    print(error)
                }
                group.leave()
            }
            
            resultIsLike = true
        }
    
        group.notify(queue: .main) {
            completion(resultIsLike, resultLikeCount)
        }
    }
    
    // MARK: [Function] ---------- 조회수 관련 ----------
    /// 조회수 카운트 가져오기
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - completion: 응답 처리 (조회했다면 true, 아니라면 false)
    func fetchViewCount(id: String, address: String, completion: @escaping (Int) -> ()) {
        
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        var finalQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("fetchViewCount - default")
        }
        
        finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).collection("조회").getDocuments(completion: { snapShot, error in
            if let error = error {
                print(error)
            }
        
            let count = snapShot?.documents.count ?? 0
           
            completion(count)
        })
    }
    
    /// 조회했던 상품인지 체크
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - completion: 응답 처리 (조회했다면 true, 아니라면 false)
    func checkViewProduct(id: String, address: String, completion: @escaping (Bool) -> ()) {
        
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        var finalQuery: CollectionReference?
        
        let loginUserData = UserModel.getUserData()
        
        switch separatedAddress.count {
        case 2:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("checkViewProduct - default")
        }
        
        finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).collection("조회").document(loginUserData?.phoneNumber ?? "").getDocument(completion: { snapShot, error in
            if let error = error {
                print(error)
            }
        
            
            let isView = snapShot?.data() == nil ? false : true
           
            completion(isView)
        })
    }
    
    /// 조회수 업데이트
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - completion: 응답 처리
    func updateViewCount(id: String, address: String, completion: @escaping () -> ()) {
        // 상품에도 관심 등록
        
        let group = DispatchGroup()
        
        let loginUserData = UserModel.getUserData()
        
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        var finalQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("updateViewCount - default")
        }
        
        // 상품 정보에만 로그인 유저 정보 저장
        group.enter()
        finalQuery?.document(separatedAddress.last ?? "").collection("상품").document(id).collection("조회").document(loginUserData?.phoneNumber ?? "").setData([:], completion: { error in
            if let error = error {
                print(error)
            }
            group.leave()
            
        })
    
        group.notify(queue: .main) {
            completion()
        }
    }
    
    
    // MARK: [Function] ---------- 동네별로 상품 가져오기 관련 ----------
    /// 동네별 상품 1개씩 가지고 오기 (같은 카테고리 뷰에서도 사용)
    /// - Parameters:
    ///   - address: 동네 이름
    ///   - category: 해당 카테고리만 가지고 올때 사용
    ///   - completion: 응답 처리
    func fetchProducts(address: String, category: String = "", completion: @escaping (Result<[ProductRegistrationModel], FirebaseError>) -> ()) {
     
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        // 지역 이름 저장 배열
        var dongmyunList = [String]()
        
        // 지역별로 가져온 상품 데이터 저장 배열
        var products = [ProductRegistrationModel]()
        var finalQuery: CollectionReference?
        
        let group = DispatchGroup()
        
        switch separatedAddress.count {
        case 2:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            finalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("경로 가져오기 실패 - default")
        }
        
        
        finalQuery?.getDocuments { snapShot, error in
            if let error = error {
                completion(.failure(.getDongmyunListError(error)))
            }
            
            guard let documents = snapShot?.documents else {
                return completion(.failure(.emptyDongmyunListError))
            }
            
            dongmyunList = documents.map({$0.documentID})
            
            print(dongmyunList)
            
            for dongmyun in dongmyunList {
                
                group.enter()
                
                // 카테고리로 필터X
                if category == "" {
                    finalQuery?.document(dongmyun).collection("상품").whereField("hidden", isEqualTo: false).order(by: "update", descending: true).limit(to: 1).getDocuments(completion: { snapShot, error in
                        if let error = error {
                            completion(.failure(.getProductError(error)))
                        }
                        
                        guard let document = snapShot?.documents.first else {
                            // 없으면 그냥 넘어가도록 에러처리 X
                            group.leave()
                            return
                        }
                        
                        products.append(ProductRegistrationModel(data: document))
                        self.productFinalQuery = finalQuery
                        self.lastProductDocuments[dongmyun] = document
                        group.leave()
                    })
                } else {
                    // 카테고리로 필터 O
                    finalQuery?.document(dongmyun).collection("상품").whereField("hidden", isEqualTo: false).whereField("category", isEqualTo: category).order(by: "update", descending: true).limit(to: 1).getDocuments(completion: { snapShot, error in
                        if let error = error {
                            completion(.failure(.getProductError(error)))
                        }
                        
                        guard let document = snapShot?.documents.first else {
                            // 없으면 그냥 넘어가도록 에러처리 X
                            group.leave()
                            return
                        }
                        
                        products.append(ProductRegistrationModel(data: document))
                        self.categoryProductFinalQuery = finalQuery
                        self.lastCategoryProductDocuments[dongmyun] = document
                        group.leave()
                        
                    })
                }
            }
            
            group.notify(queue: .main) {
                // 최신순으로 정렬
                self.productsHasNextPage = products.isEmpty ? false : true
                products.sort(by: {$0.update.seconds > $1.update.seconds})
                completion(.success(products))
            }
        }
    }
    
    /// 판매자가 게시글을 등록한 동네와 같은 다른 상품 4개 가져오기
    /// - Parameters:
    ///   - phoneNumber: 핸드폰 번호
    ///   - address: 지역 이름
    ///   - completion: 응답 처리
    func fetch4OtherProducts(phoneNumber: String, address: String, completion: @escaping (Result<[ProductRegistrationModel], FirebaseError>) -> ()) {
        
        var otherProducts = [ProductRegistrationModel]()
        
        let group = DispatchGroup()
        
        var finalQurey: CollectionReference?
        
        // 같은 동네인 상품만 가져오도록 동네이름만 따로 저장
        // 경기도 평택시 평택동
        var separatedAddress = address.components(separatedBy: " ")
        
        var city = ""
        
        switch separatedAddress.count {
        case 2:
            city = separatedAddress[0]
        case 3:
            city = separatedAddress[1]
        case 4:
            city = separatedAddress[2]
        default:
            print(" ")
        }
        
        db.collection("유저정보").document(phoneNumber).collection("전체상품").whereField("city", isEqualTo: city).limit(to: 4).getDocuments { snapShot, error in
            
            if let error = error {
                completion(.failure(.getOtherProductsError(error)))
            }
            
            // 다른 상품이 없으면 빈배열 리턴
            guard let documents = snapShot?.documents else { return completion(.success(otherProducts)) }
            
            // 동네 이름 구분
            separatedAddress = (documents.first?.data()["address"] as? String)?.components(separatedBy: " ") ?? []
            
            // 동네 이름 카운트에 따라 firebase 쿼리 분기처리
            switch separatedAddress.count {
            case 2:
                finalQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0])
            case 3:
                finalQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
            case 4:
                finalQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
            default:
                print(separatedAddress)
                print("fetch4OtherProducts - default")
            }
            
            // 만든 파이널 쿼리로 각각 상품별 동네로 검색해서 상품 데이터 가지고 오기
            for document in documents {
                
                let productId = document.data()["id"] as? String ?? ""
                let dongmyun = (document.data()["address"] as? String ?? "").components(separatedBy: " ").last ?? ""
                
                group.enter()
                finalQurey?.document(dongmyun).collection("상품").document(productId).getDocument(completion: { snapShot, error in
                    if let error = error {
                        completion(.failure(.getProductError(error)))
                    }
                    
                    guard let document2 = snapShot else {
                        group.leave()
                        return
                    }
                    
                    otherProducts.append(ProductRegistrationModel(singleData: document2))
                    group.leave()
                })
            }
            
            group.notify(queue: .main) {
                completion(.success(otherProducts))
            }
        }
    }
    
    /// 상품 디테일뷰에서 사용
    /// 같은 카테고리 상품 20개 랜덤으로 가져오기
    /// - Parameters:
    ///   - address: 동네 이름
    ///   - category: 카테고리
    ///   - completion: 응답 처리
    func fetchCategoryPtoducts(address: String, category: String, completion: @escaping (Result<[ProductRegistrationModel], FirebaseError>) -> ()) {
        
        // 지역이름 나누기
        let separatedAddress = address.components(separatedBy: " ")
        
        // 지역 이름 저장 배열
        var dongmyunList = [String]()
        
        // 지역별로 가져온 상품 데이터 저장 배열
        var products = [ProductRegistrationModel]()
        
        let group = DispatchGroup()
        
        switch separatedAddress.count {
        case 2:
            categoryProductFinalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0])
        case 3:
            categoryProductFinalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
        case 4:
            categoryProductFinalQuery = db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
        default:
            print("fetchCategoryPtoducts - default")
        }
        
        categoryProductFinalQuery?.getDocuments { snapShot, error in
            if let error = error {
                completion(.failure(.getDongmyunListError(error)))
            }
            
            guard let documents = snapShot?.documents else {
                return completion(.failure(.emptyDongmyunListError))
            }
            
            dongmyunList = documents.map({$0.documentID})
         
            for dongmyun in dongmyunList {
                group.enter()
                
                self.categoryProductFinalQuery?.document(dongmyun).collection("상품").whereField("category", isEqualTo: category).limit(to: 5).getDocuments(completion: { snapShot, error in
                    
                    if let error = error {
                        completion(.failure(.getProductError(error)))
                    }
                    
                    guard let document = snapShot?.documents.first else {
                        // 없으면 그냥 넘어가도록 에러처리 X
                        group.leave()
                        return
                    }
                    
                    products.append(ProductRegistrationModel(data: document))
                    group.leave()
                })
            }
            
            group.notify(queue: .main) {
                let result = products.shuffled().prefix(20).map({$0})
                completion(.success(result))
            }
        }
    }
    
    /// 전체상품, 판매중, 거래완료, 숨김 상태 상품 가져오기
    /// - Parameters:
    ///   - phoneNumber: 핸드폰 번호
    ///   - status: 상품 상태(전체상품, 판매중, 거래완료, 숨김)
    ///   - completion: 응답처리 (해당 상태에 맞는 상품)
    func fetchAllOrTradingOrCompletedOtherProducts(phoneNumber: String, status: ProductStatusType, completion: @escaping (Result<[ProductRegistrationModel], FirebaseError>) -> ()) {
        
        var finalSemiDataQurey: Query?
        var finalProductQurey: CollectionReference?
        
        var products = [ProductRegistrationModel]()
        
        let group = DispatchGroup()
        
        switch status {
        case .all:
            finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").whereField("hidden", isEqualTo: false).order(by: "update", descending: true).limit(to: 10)
        case .trading:
            finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).whereField("hidden", isEqualTo: false).whereField("status", isEqualTo: ProductStatusType.trading.rawValue).limit(to: 10)
        case .completed:
            finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).whereField("hidden", isEqualTo: false).whereField("status", isEqualTo: ProductStatusType.completed.rawValue).limit(to: 10)
        case .hidden:
            finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).whereField("hidden", isEqualTo: true).limit(to: 10)
        default:
            print("fetchAllOrTradingOrCompletedOtherProducts - default")
        }
    
        // 세미 데이터 가져오기
        finalSemiDataQurey?.getDocuments(completion: { snapShot, error in
            if let error = error {
                completion(.failure(.getOtherProductsError(error)))
            }
            
            guard let documents = snapShot?.documents else { return completion(.success(products)) }
        
            // 상품 데이터 가져오기
            for document in documents {
                
                let separatedAddress = (document.data()["address"] as? String)?.components(separatedBy: " ") ?? []
                
                switch separatedAddress.count {
                case 2:
                    finalProductQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0])
                case 3:
                    finalProductQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
                case 4:
                    finalProductQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
                default:
                    print("fetchFinalSemiDataQurey - default")
                }
                
                let productId = document.data()["id"] as? String ?? ""
                let dongmyun = separatedAddress.last ?? ""
                
                group.enter()
                finalProductQurey?.document(dongmyun).collection("상품").document(productId).getDocument(completion: { snapShot, error in
                    if let error = error {
                        completion(.failure(.getProductError(error)))
                    }
                    
                    guard let productData = snapShot else {
                        group.leave()
                        return
                    }
                    
                    products.append(ProductRegistrationModel(singleData: productData))
                    group.leave()
                })
            }
            
            group.notify(queue: .main) {
                
                switch status {
                case .all:
                    self.lastAllOtherProductDocument = documents.last
                    self.allOtherProductHasNextPage = documents.count == 10 ? true : false
                case .trading:
                    self.lastTradingOtherProductDocument = documents.last
                    self.tradingOtherProductHasNextPage = documents.count == 10 ? true : false
                case .completed:
                    self.lastCompletedOtherProductDocument = documents.last
                    self.completedOtherProductHasNextPage = documents.count == 10 ? true : false
                case .hidden:
                    self.lastHiddenOtherProductDocument = documents.last
                    self.hiddenOtherProductHasNextPage = documents.count == 10 ? true : false
                default:
                    print("lastDocument - default")
                }
                
                completion(.success(products.sorted(by: {$0.update.seconds > $1.update.seconds})))
            }
        })
    }
    
    /// 페이징 처리하여 동네에 저장된 상품 1개씩 차례대로 가져오기
    /// 카테고리가 있으면 카테고리 같은 상품만 가져오기
    /// lastDocuments 배열에 딕셔너리 타입으로 가지고온 상품정보 저장 후 해당 상품정보를 기준으로 다음 상품 가져오기
    /// - Parameters:
    ///   - category: 카테고리 이름
    ///   - completion: 응답 처리
    func pagingProducts(category: String = "", completion: @escaping (Result<[ProductRegistrationModel], FirebaseError>) -> ()) {
        
        // 지역별로 가져온 상품 데이터 저장 배열
        var products = [ProductRegistrationModel]()
        
        let group = DispatchGroup()
        
        let documents = category == "" ? self.lastProductDocuments : self.lastCategoryProductDocuments
        
        for (key, value) in documents {
            group.enter()
            
            if category == "" {
                productFinalQuery?.document(key).collection("상품").order(by: "update", descending: true).start(afterDocument: value).limit(to: 1).getDocuments(completion: { snapShot, error in
                    
                    if let error = error {
                        completion(.failure(.getProductError(error)))
                    }
                    
                    guard let document = snapShot?.documents.first else {
                        // 다음 상품이 없을 경우 그냥 넘어가도록 에러처리 X
                        group.leave()
                        return
                    }
                
                    products.append(ProductRegistrationModel(data: document))
                    self.lastProductDocuments[key] = document
                    group.leave()
                })
            } else {
                categoryProductFinalQuery?.document(key).collection("상품").whereField("category", isEqualTo: category).order(by: "update", descending: true).start(afterDocument: value).limit(to: 1).getDocuments(completion: { snapShot, error in
                    if let error = error {
                        completion(.failure(.getProductError(error)))
                    }
                    
                    guard let document = snapShot?.documents.first else {
                        // 다음 상품이 없을 경우 그냥 넘어가도록 에러처리 X
                        group.leave()
                        return
                    }
                
                    products.append(ProductRegistrationModel(data: document))
                    self.lastCategoryProductDocuments[key] = document
                    group.leave()
                })
            }
        }
        
        group.notify(queue: .main) {
            // 다음 페이지가 있는지 체크
            if category == "" {
                self.productsHasNextPage = products.isEmpty ? false : true
            } else {
                self.categoryProductsHasNextPage = products.isEmpty ? false : true
            }
            
            // 날짜 순으로 재정렬
            products.sort(by: {$0.update.seconds > $1.update.seconds})
            completion(.success(products))
        }
    }
    
    /// 페이징 처리하여 전체상품, 판매중, 거래완료, 숨김 상태 상품 10개씩 가져오기
    /// - Parameters:
    ///   - phoneNumber: 핸드폰 번호
    ///   - status: 상품 상태(전체상품, 판매중, 거래완료, 숨김)
    ///   - completion: 응답처리 (해당 상태에 맞는 상품)
    func pagingAllOrTradingOrCompletedOtherProducts(phoneNumber: String, status: ProductStatusType, completion: @escaping (Result<[ProductRegistrationModel], FirebaseError>) -> ()) {

        var finalSemiDataQurey: Query?
        var finalProductQurey: CollectionReference?

        // 지역별로 가져온 상품 데이터 저장 배열
        var products = [ProductRegistrationModel]()

        let group = DispatchGroup()

        switch status {
        case .all:
            if let lastDocument = self.lastAllOtherProductDocument {
                finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).start(afterDocument: lastDocument).limit(to: 10)
            }
        case .trading:
            if let lastDocument = self.lastTradingOtherProductDocument {
                finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).whereField("status", isEqualTo: ProductStatusType.trading.rawValue).start(afterDocument: lastDocument).limit(to: 10)
            }
        case .completed:
            if let lastDocument = self.lastCompletedOtherProductDocument {
                finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).whereField("status", isEqualTo: ProductStatusType.completed.rawValue).start(afterDocument: lastDocument).limit(to: 10)
            }
        case .hidden:
            if let lastDocument = self.lastHiddenOtherProductDocument {
                finalSemiDataQurey = db.collection("유저정보").document(phoneNumber).collection("전체상품").order(by: "update", descending: true).whereField("status", isEqualTo: ProductStatusType.hidden.rawValue).start(afterDocument: lastDocument).limit(to: 10)
            }
            
        default:
            print("pagingAllOrTradingOrCompletedOtherProducts - default")
        }

        // 세미 데이터 가져오기
        finalSemiDataQurey?.getDocuments(completion: { snapShot, error in
            if let error = error {
                completion(.failure(.getOtherProductsError(error)))
            }

            guard let documents = snapShot?.documents else { return completion(.success(products)) }

            // 상품 데이터 가져오기
            for document in documents {

                let separatedAddress = (document.data()["address"] as? String)?.components(separatedBy: " ") ?? []

                switch separatedAddress.count {
                case 2:
                    finalProductQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0])
                case 3:
                    finalProductQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동")
                case 4:
                    finalProductQurey = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동")
                default:
                    print("PagingfinalSemiDataQurey - default")
                }

                let productId = document.data()["id"] as? String ?? ""
                let dongmyun = separatedAddress.last ?? ""

                group.enter()
                finalProductQurey?.document(dongmyun).collection("상품").document(productId).getDocument(completion: { snapShot, error in
                    if let error = error {
                        completion(.failure(.getProductError(error)))
                    }

                    guard let productData = snapShot else {
                        group.leave()
                        return
                    }

                    products.append(ProductRegistrationModel(singleData: productData))
                    group.leave()
                })
            }

            group.notify(queue: .main) {

                switch status {
                case .all:
                    self.lastAllOtherProductDocument = documents.last
                    self.allOtherProductHasNextPage = documents.count == 10 ? true : false
                case .trading:
                    self.lastTradingOtherProductDocument = documents.last
                    self.tradingOtherProductHasNextPage = documents.count == 10 ? true : false
                case .completed:
                    self.lastCompletedOtherProductDocument = documents.last
                    self.completedOtherProductHasNextPage = documents.count == 10 ? true : false
                case .hidden:
                    self.lastHiddenOtherProductDocument = documents.last
                    self.hiddenOtherProductHasNextPage = documents.count == 10 ? true : false
                default:
                    print("default")
                }

                
                print("pagingAllOrTradingOrCompletedOtherProducts", self.lastTradingOtherProductDocument, self.tradingOtherProductHasNextPage)
                
                completion(.success(products.sorted(by: {$0.update.seconds > $1.update.seconds})))
            }
        })
    }
    
    
    // MARK: [Function] ---------- 이미지 가져오기 관련 -----------
    /// 대표 이미지 다운로드하기 ( 썸네일 이미지 )
    /// - Parameters:
    ///   - url: 이미지 URL 주소
    ///   - completion: 응답 처리
    func downloadThumbnailImage(url: String, completion: @escaping (Result<UIImage, FirebaseError>) -> ()) {
    
        if let url = URL(string: url) {
            let resource = ImageResource(downloadURL: url)
            
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                switch result {
                case .success(let value):
                    // 리사이즈 추가하기
                    completion(.success(value.image.resizeThumbnailTo()))
                case .failure(let error):
                    completion(.failure(.getProductImageError(error)))
                }
            }
        } else {
            completion(.failure(.urlError))
        }
    }
    
    /// 상품 상세정보 화면에서 상품 사진들 다운로드
    /// - Parameters:
    ///   - url: 이미지들의 URL 주소
    ///   - completion: 응답 처리
    func downloadProductImages(urls: [String]?, completion: @escaping (Result<[UIImage], FirebaseError>) -> ()) {
        
        guard let urls = urls else { return }
        
        let group = DispatchGroup()
        
        var productImages = [UIImage]()
        
        for url in urls {
            
            group.enter()
            
            if let url = URL(string: url) {
                let resource = ImageResource(downloadURL: url)
                
                KingfisherManager.shared.retrieveImage(with: resource) { result in
                    switch result {
                    case .success(let value):
                        productImages.append(value.image)
                        group.leave()
                    case .failure(let error):
                        completion(.failure(.getProductImageError(error)))
                    }
                }
            } else {
                completion(.failure(.urlError))
            }
        }
        group.notify(queue: .main) {
            completion(.success(productImages))
        }
    }
    
    /// 프로필 이미지 및 상품 이미지 업로드
    /// - Parameters:
    ///   - documentId: 상품 ID
    ///   - phoneNumber: 로그인된 사용자 핸드폰번호
    ///   - images: 프로필 및 상품 이미지들
    ///   - uploadType: 프로필 이미지 업로드인지 상품 이미지 업로드인지
    ///   - completion: 응답 처리
    func uploadImages(documentId: String, phoneNumber: String, images: [UIImage]?, uploadType: UploadType, completion: @escaping (Result<[String], Error>) -> ()) {
        
        var imageURL = [Int: String]()

        let group = DispatchGroup()
        
        for (index, image) in images!.enumerated() {
            
            group.enter()
            
            let imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            var firebaseReference = Storage.storage().reference()
            var imageName = ""
            
            switch uploadType {
            case .profileImage:
                imageName = "profileImage"
                firebaseReference = firebaseReference.child("ProfileImage").child(phoneNumber).child(imageName)
            case .productsImage:
                imageName = "ProductImage" + String(index)
                firebaseReference = firebaseReference.child("ProductImage").child(phoneNumber).child(documentId).child(imageName)
            }
            
            firebaseReference.putData(imageData, metadata: metaData) { _, error in
                if let error = error {
                    print("putData - error", error)
                }
                
                firebaseReference.downloadURL { url, error in
                    if let error = error {
                        print("downloadURL - error", error)
                    }
                   
                    imageURL[index] = url?.absoluteString ?? ""
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            let resultImages = imageURL.sorted(by: {$0.0 < $1.0}).map({$0.value})
            completion(.success(resultImages))
            
       
        }
    }
    
    /// 파이어베이스 스토리지에 저장된 이미지 삭제
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - phoneNumber: 등록한 유저 핸드폰 번호
    ///   - process: 상품이미지, 프로필이미지
    ///   - completion: 응답 처리
    func deleteStoregeInProductAndProfileImages(id: String, phoneNumber: String, process: String, completion: @escaping () -> ()) {
        let storege = Storage.storage()
        let storegeRef = storege.reference()
        
        var desertRef: StorageReference?
        
        if process == "ProductImage" {
            desertRef = storegeRef.child("ProductImage").child(phoneNumber)
        } else {
            desertRef = storegeRef.child("ProfileImage").child(phoneNumber).child(id)
        }
        
        desertRef?.listAll { result, error in
            result?.items.forEach { image in
//                image.delete()
            }
            completion()
        }
    }
    

   
    
    // MARK: [Function] ---------- 새로운 상품 등록 관련 ----------
    /// 상품 추가하기
    /// - Parameters:
    ///   - productData: 상품 정보
    ///   - selectedImages: 선택한 상품 이미지들
    ///   - completion: 응답 처리
    func addProduct(productData: [String: Any], selectedImages: [UIImage], completion: @escaping (Result<Bool,FirebaseError>) -> ()) {
        
        let group = DispatchGroup()
        
        let loginUserData = UserModel.getUserData()
        
        var finishedQuery: CollectionReference?
        let documentId = db.collection("게시물").document().documentID
        var city = ""
        
        checkAreaDocument(address: loginUserData?.selectedAddress ?? "") { ref in
            finishedQuery = ref?.collection("상품")
            
            let separatedAddress = loginUserData?.selectedAddress.components(separatedBy:  " ") ?? []
            
            switch separatedAddress.count {
            case 2:
                city = separatedAddress[0]
            case 3:
                city = separatedAddress[1]
            case 4:
                city = separatedAddress[2]
            default:
                print("default")
            }
            
            // 이미지 URL 업로드
            self.uploadImages(documentId: documentId, phoneNumber: productData["phoneNumber"] as? String ?? "", images: selectedImages, uploadType: .productsImage) { result in
               
                switch result {
                case .success(let url):
                    
                    // 상품 데이터에 이미지 URL, id 넣어야함
                    var copyProductData = productData
                    copyProductData["productId"] = documentId
                    copyProductData["imagesURL"] = url
                    copyProductData["update"] = Date()
                    
                    group.enter()
                    // 상품에 추가
                    finishedQuery?.document(documentId).setData(copyProductData, completion: { error in
                        if let error = error {
                            completion(.failure(.addProductError(error)))
                        } else {
                            print("상품 추가 완료")
                            group.leave()
                        }
                    })
                    
                    let semiProductData = [
                        "address": loginUserData?.selectedAddress ?? "",
                        "city": city,
                        "id": documentId,
                        "status": ProductStatusType.trading.rawValue,
                        "hidden": false,
                        "update": copyProductData["update"]
                    ] as [String: Any]
                    
                    group.enter()
                    // 내 정보에도 추가
                    self.db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("전체상품").document(documentId).setData(semiProductData) { error in
                        if let error = error {
                            completion(.failure(.semiAddproductError(error)))
                        } else {
                            group.leave()
                        }
                    }
                    
                    group.enter()
                    // 상품 카운트 추가
                    self.getProductsCount(phoneNumber: loginUserData?.phoneNumber ?? "") { result in
                        switch result {
                        case .success(let productCount):
                            group.enter()
                            self.updateProductsCount(phoneNumber: loginUserData?.phoneNumber ?? "", productCountData: productCount, process: "create", productStatus: "", isHidden: false) { result in
                                switch result {
                                case .success(_):
                                    print("상품 카운트 업데이트 완료")
                                    group.leave()
                                case .failure(let error):
                                    print("updateProductsCount - error", error)
                                    group.leave()
                                }
                            }
                            group.leave()
                        case .failure(let error):
                            print(error)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        completion(.success(true))
                    }
            
                case .failure(let error):
                    completion(.failure(.uploadImagesError(error)))
                }
            }
        }
    }
    
    /// 해당 동네에 최초 게시글 작성시 파이어베이스 문서 경로 생성하기
    /// - Parameters:
    ///   - address: 지역 이름
    ///   - completion: 응답 처리
    func checkAreaDocument(address: String, completion: @escaping (DocumentReference?) -> ()) {
        
        let separatedAddress = address.components(separatedBy:  " ")
        
        switch separatedAddress.count {
        case 2:
            checkArea1Document(area: separatedAddress[0], area1: separatedAddress[1]) { ref in
                completion(ref)
            }
        case 3:
            checkArea1Document(area: separatedAddress[0], area1: separatedAddress[1]) { ref in
                self.checkArea2Document(area: separatedAddress[2], count: 3, ref: ref) { ref in
                    completion(ref)
                }
            }
        case 4:
            checkArea1Document(area: separatedAddress[0], area1: separatedAddress[1]) { ref1 in
                print("ref1", ref1?.path)
                self.checkArea2Document(area: separatedAddress[2], count: 4, ref: ref1) { ref2 in
                    print("ref2", ref2?.path)
                    self.checkArea3Document(area: separatedAddress[3], ref: ref2) { ref3 in
                        print("ref3", ref3?.path)
                        completion(ref3)
                    }
                }
            }
        default:
            print("default")
        }
    }
    
    func checkArea1Document(area: String, area1: String, completion: @escaping (DocumentReference?) -> ()) {
        
        // 게시글 - 행정구역 - 세종특별자치시 - 반곡동(#)
        // 게시글 - 행정구역 - 경기도 - 평택시(#) - 행정동 - 서정동(#)
        // 게시글 - 행정구역 - 경기도 - 수원시(#) - 행정구 - 권선구(#) - 행정동 - 세류동(#)

        let ref = db.collection("게시글").document("행정구역").collection(area)
        
        ref.getDocuments { snapShot, error in
            if let error = error {
                print(error)
            }
            
            guard let documentsID = snapShot?.documents.map({$0.documentID}) else { return }
            
            let resultRef = ref.document(area1)
            
            if documentsID.contains(area1) {
                completion(resultRef)
            } else {
                ref.document(area1).setData([:]) { error in
                    completion(resultRef)
                }
            }
        }
    }
    
    func checkArea2Document(area: String, count: Int, ref: DocumentReference?, completion: @escaping (DocumentReference?) -> ()) {
        
        // 게시글 - 행정구역 - 경기도 - 평택시(#) << 여기까지 생성 - 행정동 - 서정동(#)
        // 게시글 - 행정구역 - 경기도 - 수원시(#) << 여기까지 생성 - 행정구 - 권선구(#) - 행정동 - 세류동(#)
        var newRef: CollectionReference?
        
        if count == 3 {
            newRef = ref?.collection("행정동")
        } else {
            newRef = ref?.collection("행정구")
        }
        
        newRef?.getDocuments(completion: { snapShot, error in
            if let error = error {
                print(error)
            }
            
            guard let documentsID = snapShot?.documents.map({$0.documentID}) else { return }
            
            let resultRef = newRef?.document(area)
            
            if documentsID.contains(area) {
                completion(resultRef)
            } else {
                newRef?.document(area).setData([:]) { error in
                    completion(resultRef)
                }
            }
        })
    }
    
    func checkArea3Document(area: String, ref: DocumentReference?, completion: @escaping (DocumentReference?) -> ()) {
        
        // 게시글 - 행정구역 - 경기도 - 수원시(#) - 행정구 - 권선구(#)  << 여기까지 생성 - 행정동 - 세류동(#)
        
        let newRef = ref?.collection("행정동")
        
        newRef?.getDocuments(completion: { snapShot, error in
            if let error = error {
                print(error)
            }
            
            guard let documentsID = snapShot?.documents.map({$0.documentID}) else { return }
            
            let resultRef = newRef?.document(area)
            
            if documentsID.contains(area) {
                completion(resultRef)
            } else {
                newRef?.document(area).setData([:]) { error in
                    completion(resultRef)
                }
            }
        })
    }

    // MARK: [Function] ---------- 상품 수정 관련 관련 ----------
    /// 등록된 상품 정보 수정하기
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - phoneNumber: 해당 상품을 등록한 유저 정보
    ///   - address: 해당 상품이 등록된 지역 정보
    ///   - productData: 상품 데이터
    ///   - selectedImages: 선택한 이미지들
    ///   - completion: 응답 처리
    func editProduct(id: String, phoneNumber: String, address: String, productData: [String: Any], selectedImages: [UIImage], completion: @escaping (Result<Bool,FirebaseError>) -> ()) {
    
        let separatedAddress = address.components(separatedBy:  " ")
        
        var finishedQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
        case 3:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
        case 4:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
        default:
            print("addProduct - default")
        }
        
        // 스토리지 이미지 삭제하기
        deleteStoregeInProductAndProfileImages(id: id, phoneNumber: phoneNumber, process: "ProductImage") {
            // 이미지 URL 업로드
        
            self.uploadImages(documentId: id, phoneNumber: phoneNumber, images: selectedImages, uploadType: .productsImage) { result in
                switch result {
                case .success(let url):
                    
                    // 상품 데이터에 이미지 URL, id 넣어야함
                    var copyProductData = productData
                    copyProductData["imagesURL"] = url
                    
                    // 업데이트
                    finishedQuery?.document(id).updateData(copyProductData, completion: { error in
                        if let error = error {
                            completion(.failure(.updateProductError(error)))
                        } else {
                            completion(.success(true))
                        }
                    })
                case .failure(let error):
                    completion(.failure(.uploadImagesError(error)))
                }
            }
        }
    }
    
    // MARK: 상품 삭제 관련 ----------
    /// 등록된 상품 삭제
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - phoneNumber: 해당 상품을 등록한 유저 정보
    ///   - address: 해당 상품이 등록된 지역 정보
    ///   - status: 상품 상태(거래중,예약중,거래완료,숨김)
    ///   - completion: 응답처리
    func deleteProduct(id: String, phoneNumber: String,address: String, status: ProductStatusType.RawValue, completion: @escaping (Result<Bool,FirebaseError>) -> ()) {
        
        let group = DispatchGroup()
        
        let separatedAddress = address.components(separatedBy:  " ")
        
        var finishedQuery: CollectionReference?
        var likeUserListQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
            likeUserListQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품").document(id).collection("관심목록")
        case 3:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
            likeUserListQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품").document(id).collection("관심목록")
        case 4:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
            likeUserListQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품").document(id).collection("관심목록")
        default:
            print("addProduct - default")
        }
        
        // 내 상품목록에서 삭제
        group.enter()
        db.collection("유저정보").document(phoneNumber).collection("전체상품").document(id).delete { error in
            if let error = error {
                completion(.failure(.deleteMyProductListError(error)))
            } else {
                group.leave()
            }
        }
        
        // 동네 상품 목록에서 삭제
        group.enter()
        finishedQuery?.document(id).delete(completion: { error in
            if let error = error {
                completion(.failure(.deleteCityInProductError(error)))
            } else {
                group.leave()
            }
        })
        
        // 좋아요 누른 사람들 목록에서 삭제
        group.enter()
        likeUserListQuery?.getDocuments(completion: { snapShot, error in
            if let error = error {
                completion(.failure(.likeUserListError(error)))
            } else {
                group.leave()
                
                let userList = snapShot?.documents.map({$0.documentID}) ?? []
                
                for user in userList {
                    group.enter()
                    self.db.collection("유저정보").document(user).collection("관심목록").document(id).delete { error in
                        if let error = error {
                            completion(.failure(.likeUserDeleteProductError(error)))
                        } else {
                            group.leave()
                        }
                    }
                }
            }
        })
        
        group.enter()
        // 상품 카운트 내리기
        getProductsCount(phoneNumber: phoneNumber) { result in
            switch result {
            case .success(let productsCount):
                
                self.updateProductsCount(phoneNumber: phoneNumber, productCountData: productsCount, process: "delete", productStatus: status, isHidden: false) { result in
                    switch result {
                    case .success(_):
                        completion(.success(true))
                        group.leave()
                    case .failure(let error):
                        completion(.failure(.updateProductsCountError(error)))
                        group.leave()
                    }
                }
            case .failure(let error):
                print(error)
                group.leave()
            }
        }
    
        group.notify(queue: .main) {
            completion(.success(true))
        }
    }
    
    // MARK: [Function] ---------- 상태 관련 (예약중, 거래완료) ----------
    /// 예약중 상태 업데이트
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - isReservation: 예약 상태인지 체크하는 Bool값
    ///   - completion: 응답 처리
    func updateReservationProduct(id: String, address: String, isReservation: Bool, completion: @escaping () -> ()) {
        
        let loginUserData = UserModel.getUserData()
        
        let group = DispatchGroup()
        
        // 동네에 속한 상품 상태 업데이트
        let separatedAddress = address.components(separatedBy: " ")
        var finishedQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
        case 3:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
        case 4:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
        default:
            print("updateProductReservationAndStatus - addProduct - default")
        }
        
        if isReservation {
            finishedQuery?.document(id).updateData(["reservation": false], completion: { error in
                if let error = error {
                    print(error)
                }
                completion()
            })
        } else {
            finishedQuery?.document(id).updateData(["reservation": true], completion: { error in
                if let error = error {
                    print(error)
                }
                completion()
            })
        }
    }
    
    /// 거래 완료 상태 업데이트
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - isCompleted: 거래완료 상태인지 체크하는 Bool값
    ///   - completion: 응답처리
    func updateCompletedProduct(id: String, address: String, isCompleted: Bool, completion: @escaping () -> ()) {
       
        let loginUserData = UserModel.getUserData()
        
        let group = DispatchGroup()
        
        // 동네에 속한 상품 상태 업데이트
        let separatedAddress = address.components(separatedBy: " ")
        var finishedQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
        case 3:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
        case 4:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
        default:
            print("updateProductReservationAndStatus - addProduct - default")
        }
        
       
        var productStatus = ""

        if isCompleted {
            productStatus = ProductStatusType.trading.rawValue
        } else {
            productStatus = ProductStatusType.completed.rawValue
        }

        // 동네에 속한 상품 정보 변경
        group.enter()
        finishedQuery?.document(id).updateData(["reservation": false, "status": productStatus], completion: { error in
            if let error = error {
                print(error)
                group.leave()
            } else {
                group.leave()
            }
        })

        // 내 정보에 등록된 상품 정보 변경
        group.enter()
        db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("전체상품").document(id).updateData(["status": productStatus]) { error in
            if let error = error {
                print(error)
                group.leave()
            } else {
                group.leave()
            }
        }
        
        // 상품 카운트 정보 변경
        group.enter()
        getProductsCount(phoneNumber: loginUserData?.phoneNumber ?? "") { result in
            switch result {
            case .success(let productsCount):
                self.updateProductsCount(phoneNumber: loginUserData?.phoneNumber ?? "", productCountData: productsCount, process: "completed", productStatus: productStatus, isHidden: false) { result in
                    switch result {
                    case .success(_):
                        print("완료")
                        group.leave()
                    case .failure(let error):
                        print(error)
                        group.leave()
                    }
                }
            case .failure(let error):
                print(error)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    // MARK: [Function] ---------- 로그인 유저가 등록한 상품 및 판매자가 등록한 상품 관련 ----------
    /// 등록한 전체 상품 카운트 업데이트
    /// - Parameters:
    ///   - phoneNumber: 로그인 유저 핸드폰 번호
    ///   - productCountData: 등록한 전체 상품 카운트 정보
    ///   - process: CRUD 상태
    ///   - productStatus: 상품 상태(예약중,거래중,거래완료,숨김)
    ///   - isHidden: 숨김 상태
    ///   - completion: 응답 처리
    func updateProductsCount(phoneNumber: String, productCountData: [String: Int]?, process: String, productStatus: String, isHidden: Bool, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        
        switch process {
        case "create":
            // 상품 등록
            if let productsCount = productCountData {
                let resultProductsCount = [
                    "completed": productsCount["completed"] ?? 0,
                    "total": (productsCount["total"] ?? 0) + 1,
                    "trading": (productsCount["trading"] ?? 0) + 1,
                    "hidden": productsCount["hidden"] ?? 0
                ] as [String: Int]
                
                self.db.collection("유저정보").document(phoneNumber).updateData(["productsCount": resultProductsCount]) { error in
                    if let error = error {
                        completion(.failure(.updateProductsCountError(error)))
                    } else {
                        completion(.success(true))
                    }
                }
            } else {
                let resultProductsCount = [
                    "total": 1,
                    "completed": 0,
                    "trading": 1,
                    "hidden": 0
                ] as [String: Int]
                
                self.db.collection("유저정보").document(phoneNumber).updateData(["productsCount": resultProductsCount]) { error in
                    if let error = error {
                        completion(.failure(.updateProductsCountError(error)))
                    } else {
                        completion(.success(true))
                    }
                }
            }
        case "delete":
            // 상품 삭제
            var copyProductsCount = productCountData
            
            switch productStatus {
            case ProductStatusType.trading.rawValue:
                let tradingCount = copyProductsCount?["trading"] ?? 0
                copyProductsCount?["trading"] = tradingCount - 1
            case ProductStatusType.completed.rawValue:
                let completedCount = copyProductsCount?["completed"] ?? 0
                copyProductsCount?["completed"] = completedCount - 1
            case ProductStatusType.hidden.rawValue:
                let hiddenCount = copyProductsCount?["hidden"] ?? 0
                copyProductsCount?["hidden"] = hiddenCount - 1
            default:
                print("updateProductsCount - delete - default")
            }
            
            let totalCount = copyProductsCount?["total"] ?? 0
            copyProductsCount?["total"] = totalCount - 1
            
            db.collection("유저정보").document(phoneNumber).updateData(["productsCount": copyProductsCount]) { error in
                if let error = error {
                    completion(.failure(.updateProductsCountError(error)))
                } else {
                    completion(.success(true))
                }
            }
            
        case "completed":
            //상품 상태 업데이트
            var copyProductsCount = productCountData
            
            if productStatus == ProductStatusType.completed.rawValue {
                let tradingCount = copyProductsCount?["trading"] ?? 0
                copyProductsCount?["trading"] = tradingCount - 1
                let completedCount = copyProductsCount?["completed"] ?? 0
                copyProductsCount?["completed"] = completedCount + 1
            } else {
                let tradingCount = copyProductsCount?["trading"] ?? 0
                copyProductsCount?["trading"] = tradingCount + 1
                let completedCount = copyProductsCount?["completed"] ?? 0
                copyProductsCount?["completed"] = completedCount - 1
            }
            
            db.collection("유저정보").document(phoneNumber).updateData(["productsCount": copyProductsCount]) { error in
                if let error = error {
                    completion(.failure(.updateProductsCountError(error)))
                } else {
                    completion(.success(true))
                }
            }
        
        case "hidden":
            
            var copyProductsCount = productCountData
            
            if isHidden {
                if productStatus == ProductStatusType.trading.rawValue {
                    let tradingCount = copyProductsCount?["trading"] ?? 0
                    copyProductsCount?["trading"] = tradingCount - 1
                    let hiddenCount = copyProductsCount?["hidden"] ?? 0
                    copyProductsCount?["hidden"] = hiddenCount + 1
                } else {
                    let completedCount = copyProductsCount?["completed"] ?? 0
                    copyProductsCount?["completed"] = completedCount - 1
                    let hiddenCount = copyProductsCount?["hidden"] ?? 0
                    copyProductsCount?["hidden"] = hiddenCount + 1
                }
            } else {
                // 숨김 해제
                if productStatus == ProductStatusType.trading.rawValue {
                    let tradingCount = copyProductsCount?["trading"] ?? 0
                    copyProductsCount?["trading"] = tradingCount + 1
                    let hiddenCount = copyProductsCount?["hidden"] ?? 0
                    copyProductsCount?["hidden"] = hiddenCount - 1
                } else {
                    let completedCount = copyProductsCount?["completed"] ?? 0
                    copyProductsCount?["completed"] = completedCount + 1
                    let hiddenCount = copyProductsCount?["hidden"] ?? 0
                    copyProductsCount?["hidden"] = hiddenCount - 1
                }
            }
            
            db.collection("유저정보").document(phoneNumber).updateData(["productsCount": copyProductsCount]) { error in
                if let error = error {
                    completion(.failure(.updateProductsCountError(error)))
                } else {
                    completion(.success(true))
                }
            }
            
        default:
            print("updateProductsCount - default")
        }
    }
    
    
    /// 숨김 상태 상품 업데이트하기
    /// - Parameters:
    ///   - id: 상품 ID
    ///   - address: 상품이 등록된 주소
    ///   - isHidden: 숨김 상태
    ///   - status: 상품 상태(예약중,거래중,거래완료,숨김)
    ///   - completion: 응답 처리
    func updateHiddenProduct(id: String, address: String, isHidden: Bool, status: String, completion: @escaping () -> ()) {
       
        let loginUserData = UserModel.getUserData()
        
        let group = DispatchGroup()
        
        // 동네에 속한 상품 상태 업데이트
        let separatedAddress = address.components(separatedBy: " ")
        var finishedQuery: CollectionReference?
        
        switch separatedAddress.count {
        case 2:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("상품")
        case 3:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정동").document(separatedAddress[2]).collection("상품")
        case 4:
            finishedQuery = self.db.collection("게시글").document("행정구역").collection(separatedAddress[0]).document(separatedAddress[1]).collection("행정구").document(separatedAddress[2]).collection("행정동").document(separatedAddress[3]).collection("상품")
        default:
            print("updateProductReservationAndStatus - addProduct - default")
        }
    
        // 동네에 속한 상품 정보 변경
        group.enter()
        finishedQuery?.document(id).updateData(["reservation": false, "hidden": isHidden ?? false], completion: { error in
            if let error = error {
                print(error)
                group.leave()
            } else {
                group.leave()
            }
        })
        

        // 내 정보에 등록된 상품 정보 변경
        group.enter()
            
        var productStatus = ""
      
        if status == ProductStatusType.trading.rawValue {
            productStatus = ProductStatusType.trading.rawValue
        } else {
            productStatus = ProductStatusType.completed.rawValue
        }
       
        if isHidden ?? true {
            // 숨김 처리
            db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("전체상품").document(id).updateData(["hidden": true]) { error in
                if let error = error {
                    print(error)
                    group.leave()
                } else {
                    group.leave()
                }
            }
        } else {
            db.collection("유저정보").document(loginUserData?.phoneNumber ?? "").collection("전체상품").document(id).updateData(["hidden": false]) { error in
                if let error = error {
                    print(error)
                    group.leave()
                } else {
                    group.leave()
                }
            }
        }
        
        // 상품 카운트 정보 변경
        group.enter()
        getProductsCount(phoneNumber: loginUserData?.phoneNumber ?? "") { result in
            switch result {
            case .success(let productsCount):
                
                print("productsCount", productsCount, productStatus)
    
                
                self.updateProductsCount(phoneNumber: loginUserData?.phoneNumber ?? "", productCountData: productsCount, process: "hidden", productStatus: productStatus, isHidden: isHidden) { result in
                    switch result {
                    case .success(_):
                        print("완료")
                        group.leave()
                    case .failure(let error):
                        print(error)
                        group.leave()
                    }
                }
            case .failure(let error):
                print(error)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    // MARK: [Function] ---------- 선택한 동네 정보 관련 ----------
    /// 선택한 동네 변경시 변경된 동네 업데이트
    /// - Parameters:
    ///   - userPhoneNumber: 로그인 유저 핸드폰 번호
    ///   - data: 유저 데이터
    ///   - completion: 응답 처리
    func updateAddressData(userPhoneNumber: String ,data: UserModel, completion: @escaping () -> ()) {

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                db.collection("유저정보").document(userPhoneNumber).updateData(result) { error in
                    if let error = error {
                        print("동네 정보 업데이트 실패 - ", error)
                    } else {
                        completion()
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    
    // MARK: [Function] ---------- Reset 관련 ----------
    /// 리프레쉬하면 데이터 초기화 작업
    func resetProductsDownloadData(isCategory: Bool, completion: @escaping () -> ()) {
        
        if isCategory {
            lastCategoryProductDocuments.removeAll()
            categoryProductFinalQuery = nil
            categoryProductsHasNextPage = false
        } else {
            lastProductDocuments.removeAll()
            productFinalQuery = nil
            productsHasNextPage = false
        }
        
        KingfisherManager.shared.downloader.cancelAll()
        Thread.sleep(forTimeInterval: 2)
        completion()
    }
    
    /// 리프레쉬하면 데이터 초기화 작업
    func resetOtherProductsDownloadData(status: ProductStatusType, completion: @escaping () -> ()) {
        
        switch status {
        case .all:
            lastAllOtherProductDocument = nil
            allOtherProductFinalQuery = nil
            allOtherProductHasNextPage = false
        case .trading:
            lastTradingOtherProductDocument = nil
            tradingOtherProductFinalQuery = nil
            tradingOtherProductHasNextPage = false
        case .completed:
            lastCompletedOtherProductDocument = nil
            completedOtherProductFinalQuery = nil
            completedOtherProductHasNextPage = false
        case .hidden:
            lastHiddenOtherProductDocument = nil
            hiddenOtherProductFinalQuery = nil
            hiddenOtherProductHasNextPage = false
        default:
            print("resetOtherProductsDownloadData - default")
        }
        
        KingfisherManager.shared.downloader.cancelAll()
        Thread.sleep(forTimeInterval: 2)
        completion()
    }
    
    
    func resetLikeProductsDownloadData(completion: @escaping () -> ()) {
        lastLikeProductDocument = nil
        likeProductsHaseNextPage = false
        
        KingfisherManager.shared.downloader.cancelAll()
        Thread.sleep(forTimeInterval: 2)
        completion()
    }

    
    // MARK: [Function] ---------- 더미데이터 추가하기
    func updateDummyData(completion: @escaping ([DummyData]) -> ()) {
        var userData = ["01043291857",
                        "01012341234",
                        "01011112222",
                        "01011113333",
                        "01011114444",
                        "01011115555",
                        "01011116666",
                        "01011117777",
                        "01011118888",
                        "01011119999"]
        
//        var addressList = ["경기도 평택시 중앙동",
//                       "경기도 평택시 서정동",
//                       "경기도 평택시 장당동",
//                       "경기도 평택시 모곡동",
//                       "경기도 평택시 칠괴동",
//                       "경기도 평택시 칠원동",
//                       "경기도 평택시 도일동",
//                       "경기도 평택시 가재동",
//                       "경기도 평택시 장안동",
//                       "경기도 평택시 이충동",
//                       "경기도 평택시 지산동",
//                       "경기도 평택시 독곡동",
//                       "경기도 평택시 신장동",
//                       "경기도 평택시 평택동",
//                       "경기도 평택시 통복동"]
        
//        var addressList = ["경기도 수원시 권선구 세류동",
//                           "경기도 수원시 권선구 평동",
//                           "경기도 수원시 권선구 고색동",
//                           "경기도 수원시 권선구 오목천동",
//                           "경기도 수원시 권선구 평리동",
//                           "경기도 수원시 권선구 서둔동",
//                           "경기도 수원시 권선구 구운동",
//                           "경기도 수원시 권선구 탑동",
//                           "경기도 수원시 권선구 금곡동",
//                           "경기도 수원시 권선구 호매실동",
//                           "경기도 수원시 권선구 곡반정동",
//                           "경기도 수원시 권선구 권선동",
//                           "경기도 수원시 권선구 장지동",
//                           "경기도 수원시 권선구 대황교동",
//                           "경기도 수원시 권선구 입북동"]
        
//        var addressList = ["서울특별시 강남구 역삼동",
//                           "서울특별시 강남구 개포동",
//                           "서울특별시 강남구 청담동",
//                           "서울특별시 강남구 삼성동",
//                           "서울특별시 강남구 대치동",
//                           "서울특별시 강남구 신사동",
//                           "서울특별시 강남구 논현동",
//                           "서울특별시 강남구 압구정동",
//                           "서울특별시 강남구 세곡동",
//                           "서울특별시 강남구 자곡동",
//                           "서울특별시 강남구 율현동",
//                           "서울특별시 강남구 일원동",
//                           "서울특별시 강남구 수서동",
//                           "서울특별시 강남구 도곡동",
//                           "서울특별시 강남구 역삼동"]
        
        var addressList = ["세종특별자치시 반곡동",
                           "세종특별자치시 소담동",
                           "세종특별자치시 보람동",
                           "세종특별자치시 대평동",
                           "세종특별자치시 가람동",
                           "세종특별자치시 한솔동",
                           "세종특별자치시 나성동",
                           "세종특별자치시 새롬동",
                           "세종특별자치시 다정동",
                           "세종특별자치시 어진동",
                           "세종특별자치시 종촌동",
                           "세종특별자치시 고운동",
                           "세종특별자치시 아름동",
                           "세종특별자치시 도담동",
                           "세종특별자치시 산울동"]
        
        var categoryDatas = [
            // 디지털기기
            DummyData(phoneNumber: nil, address: nil, title: "3060 그래픽카드 팝니다.", content: "상태 좋은 3060 그래픽카드 팔아요.", price: "400000", category: "디지털기기", images: ["3060"]),
            DummyData(phoneNumber: nil, address: nil, title: "3080 그래픽카드 팝니다.", content: "상태 좋은 3080 그래픽카드 팔아요. 궁금하신점은 연락주세요!", price: "600000", category: "디지털기기", images: ["3080"]),
            DummyData(phoneNumber: nil, address: nil, title: "노키아 카메라", content: "거의 사용안한 노키아 카메라 판매합니다 ~~!!", price: "200000", category: "디지털기기", images: ["노키아카메라"]),
            DummyData(phoneNumber: nil, address: nil, title: "노트 10 판매 합니다.", content: "사용감 적은 노트10 판매합니다.", price: "500000", category: "디지털기기", images: ["노트10"]),
            DummyData(phoneNumber: nil, address: nil, title: "매직 키보드", content: "작년 10월 구매한 매직 키보드 팝니다.\n 상태 최상급!!\n사용감 매우 적어요!!", price: "100000", category: "디지털기기", images: ["매직키보드"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 맥북 팝니다.", content: "맥북 16인치 판매합니다.\n용량 1테라\n메모리32기가\n Intel Core i9", price: "1500000", category: "디지털기기", images: ["맥북1"]),
            DummyData(phoneNumber: nil, address: nil, title: "맥북 에어 팝니다.", content: "맥북 에어 판매합니다.\n용량 512\n메모리16기가\n Intel Core i5", price: "1200000", category: "디지털기기", images: ["맥북2"]),
            DummyData(phoneNumber: nil, address: nil, title: "맥북 팝니다.", content: "맥북 판매합니다.\n용량 512\n메모리16기가\n Intel Core i7", price: "2000000", category: "디지털기기", images: ["맥북3"]),
            DummyData(phoneNumber: nil, address: nil, title: "빔 프로젝터 팝니다. 사용감 적음!", content: "작년 12월 구매한 빔 프로젝터 판매합니다.", price: "200000", category: "디지털기기", images: ["빔프로젝터"]),
            DummyData(phoneNumber: nil, address: nil, title: "빔 프로젝터 팝니다.", content: "판매합니다.", price: "150000", category: "디지털기기", images: ["빔프로젝터2"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "삼성 노트북 팝니다.", content: "삼성 노트북 판매합니다.\n용량 512\n메모리16기가\n Intel Core i7", price: "800000", category: "디지털기기", images: ["삼성노트북1"]),
            DummyData(phoneNumber: nil, address: nil, title: "삼성 노트북", content: "삼성 노트북 판매합니다.\n용량 512\n메모리16기가\n Intel Core i5", price: "700000", category: "디지털기기", images: ["삼성노트북2"]),
            DummyData(phoneNumber: nil, address: nil, title: "소니 카메라", content: "상태 좋은 소니 카메라 판매합니다. 궁금하신점 연락주세요.", price: "340000", category: "디지털기기", images: ["소니카메라"]),
            DummyData(phoneNumber: nil, address: nil, title: "아이패드 11인치 팝니다.", content: "케이스, 펜슬도 같이 드려요~", price: "400000", category: "디지털기기", images: ["아이패드11"]),
            DummyData(phoneNumber: nil, address: nil, title: "아이패드 미니 5", content: "아이패드 미니 5 팝니다. 상태 좋아요", price: "300000", category: "디지털기기", images: ["아이패드미니5"]),
            DummyData(phoneNumber: nil, address: nil, title: "아이패드 미니 6 팝니다.", content: "아이패드 미니 6 판매합니다~ 궁금하신점 연락주세요!", price: "440000", category: "디지털기기", images: ["아이패드미니6"]),
            DummyData(phoneNumber: nil, address: nil, title: "아이패드 에어5", content: "아이패드 에어 5 팝니다 상태 좋아요!", price: "800000", category: "디지털기기", images: ["아이패드에어5"]),
            DummyData(phoneNumber: nil, address: nil, title: "아이폰 14", content: "아이폰 14 약정 끝난 공기기 판매합니다.", price: "990000", category: "디지털기기", images: ["아이폰14"]),
            DummyData(phoneNumber: nil, address: nil, title: "애플워치 팝니다.", content: "상태 좋은 애플워치 판매합니다.\n궁금하신점은 연락주세요!", price: "150000", category: "디지털기기", images: ["애플워치"]),
            DummyData(phoneNumber: nil, address: nil, title: "애플펜슬 팝니다.", content: "사용감 적은 애플펜슬 팝니다.", price: "80000", category: "디지털기기", images: ["애플펜슬1"]),
            DummyData(phoneNumber: nil, address: nil, title: "애플펜슬 1세대 판매합니다.", content: "상태 좋아요!", price: "70000", category: "디지털기기", images: ["애플펜슬1세대"]),
            DummyData(phoneNumber: nil, address: nil, title: "에어팟1세대 팝니다.", content: "사용감 적습니다. 궁금한점은 연락주세요!", price: "120000", category: "디지털기기", images: ["에어팟1세대"]),
            DummyData(phoneNumber: nil, address: nil, title: "에어팟 프로 1세대 팝니다.", content: "", price: "200000", category: "디지털기기", images: ["에어팟프로"]),
            DummyData(phoneNumber: nil, address: nil, title: "원형블루투스 팝니다", content: "", price: "130000", category: "디지털기기", images: ["원형블루투스"]),
            DummyData(phoneNumber: nil, address: nil, title: "충전기 팝니다", content: "", price: "15000", category: "디지털기기", images: ["충전기"]),
            DummyData(phoneNumber: nil, address: nil, title: "폴라로이드", content: "", price: "50000", category: "디지털기기", images: ["폴라로이드"]),
            DummyData(phoneNumber: nil, address: nil, title: "픽스라이프블루투스 팝니다", content: "", price: "250000", category: "디지털기기", images: ["픽스라이프블루투스"]),
            DummyData(phoneNumber: nil, address: nil, title: "LG노트북1 팔아요", content: "", price: "800000", category: "디지털기기", images: ["LG노트북1"]),
            DummyData(phoneNumber: nil, address: nil, title: "LG노트북2 팝니다", content: "", price: "900000", category: "디지털기기", images: ["LG노트북2"]),
            DummyData(phoneNumber: nil, address: nil, title: "PS4 저렴하게 판매합니다.", content: "", price: "500000", category: "디지털기기", images: ["PS4"]),
            
            // 가구/인테리어
            DummyData(phoneNumber: nil, address: nil, title: "선반 팝니다", content: "", price: "50000", category: "가구/인테리어", images: ["선반1"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 선반 팝니다", content: "", price: "30000", category: "가구/인테리어", images: ["선반2"]),
            DummyData(phoneNumber: nil, address: nil, title: "새 선반 팝니다", content: "", price: "70000", category: "가구/인테리어", images: ["선반3"]),
            DummyData(phoneNumber: nil, address: nil, title: "선반 팔아요", content: "", price: "90000", category: "가구/인테리어", images: ["선반4"]),
            DummyData(phoneNumber: nil, address: nil, title: "쇼파 팝니다.", content: "", price: "300000", category: "가구/인테리어", images: ["쇼파1"]),
            DummyData(phoneNumber: nil, address: nil, title: "상태 좋은 쇼파 팝니다.", content: "", price: "240000", category: "가구/인테리어", images: ["쇼파2"]),
            DummyData(phoneNumber: nil, address: nil, title: "쇼파 팔아요", content: "", price: "500000", category: "가구/인테리어", images: ["쇼파3"]),
            DummyData(phoneNumber: nil, address: nil, title: "쇼파 급하게 팝니다", content: "", price: "350000", category: "가구/인테리어", images: ["쇼파4"]),
            DummyData(phoneNumber: nil, address: nil, title: "의자 팔아요", content: "", price: "50000", category: "가구/인테리어", images: ["의자1"]),
            DummyData(phoneNumber: nil, address: nil, title: "의자 팝니다.", content: "", price: "80000", category: "가구/인테리어", images: ["의자2"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "의자 팔아요~", content: "", price: "30000", category: "가구/인테리어", images: ["의자3"]),
            DummyData(phoneNumber: nil, address: nil, title: "침대 팝니다.", content: "", price: "150000", category: "가구/인테리어", images: ["침대1"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 침대 팝니다.", content: "", price: "300000", category: "가구/인테리어", images: ["침대2"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 침대 팝니다.", content: "", price: "250000", category: "가구/인테리어", images: ["침대3"]),
            DummyData(phoneNumber: nil, address: nil, title: "침대", content: "", price: "400000", category: "가구/인테리어", images: ["침대4"]),
            DummyData(phoneNumber: nil, address: nil, title: "테이블 팝니다.", content: "", price: "200000", category: "가구/인테리어", images: ["테이블1"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 테이블 팝니다.", content: "", price: "150000", category: "가구/인테리어", images: ["테이블2"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 테이블 팝니다.", content: "", price: "130000", category: "가구/인테리어", images: ["테이블3"]),
            DummyData(phoneNumber: nil, address: nil, title: "티비 장식장 팝니다.", content: "", price: "500000", category: "가구/인테리어", images: ["티비다이1"]),
            DummyData(phoneNumber: nil, address: nil, title: "티비 다이 팝니다.", content: "", price: "440000", category: "가구/인테리어", images: ["티비다이2"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "중고 티비 다이 팝니다.", content: "", price: "350000", category: "가구/인테리어", images: ["티비다이3"]),
            DummyData(phoneNumber: nil, address: nil, title: "파티션 대량 팝니다.", content: "", price: "100000", category: "가구/인테리어", images: ["파티션1"]),
            DummyData(phoneNumber: nil, address: nil, title: "파티션 3개 팝니다.", content: "", price: "96000", category: "가구/인테리어", images: ["파티션2"]),
            DummyData(phoneNumber: nil, address: nil, title: "파티션 2개 팝니다.", content: "", price: "60000", category: "가구/인테리어", images: ["파티션3"]),
            DummyData(phoneNumber: nil, address: nil, title: "행거 팝니다", content: "", price: "50000", category: "가구/인테리어", images: ["행거1"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 행거 팝니다.", content: "", price: "75000", category: "가구/인테리어", images: ["행거2"]),
            DummyData(phoneNumber: nil, address: nil, title: "크기 적당한 행거 팝니다.", content: "", price: "99000", category: "가구/인테리어", images: ["행거3"]),
            DummyData(phoneNumber: nil, address: nil, title: "화장품 선반 팝니다.", content: "", price: "150000", category: "가구/인테리어", images: ["화장품선반1"]),
            DummyData(phoneNumber: nil, address: nil, title: "화장품 보관함 팔아요", content: "", price: "130000", category: "가구/인테리어", images: ["화장품선반2"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 화장품 선반 팝니다.", content: "", price: "110000", category: "가구/인테리어", images: ["화장품선반3"]),
            
            // 생활가전
            DummyData(phoneNumber: nil, address: nil, title: "가습기 저렴하게 팝니다.", content: "", price: "50000", category: "생활가전", images: ["가습기1"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 가습기 팝니다.", content: "", price: "80000", category: "생활가전", images: ["가습기2"]),
            DummyData(phoneNumber: nil, address: nil, title: "가정용 커피머신 팝니다.", content: "", price: "400000", category: "생활가전", images: ["가정용커피머신"]),
            DummyData(phoneNumber: nil, address: nil, title: "대우 전자레인지 팝니다.", content: "", price: "140000", category: "생활가전", images: ["대우전자레인지"]),
            DummyData(phoneNumber: nil, address: nil, title: "마사지건", content: "", price: "50000",  category: "생활가전", images: ["마사지건"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 마사지건 팔아요", content: "", price: "60000", category: "생활가전", images: ["마사지건1"]),
            DummyData(phoneNumber: nil, address: nil, title: "믹서기 팔아요", content: "", price: "67000", category: "생활가전", images: ["믹서기1"]),
            DummyData(phoneNumber: nil, address: nil, title: "믹서기", content: "", price: "50000", category: "생활가전", images: ["믹서기2"]),
            DummyData(phoneNumber: nil, address: nil, title: "봉고데기 팝니다.", content: "", price: "40000", category: "생활가전", images: ["봉고데기"]),
            DummyData(phoneNumber: nil, address: nil, title: "브레빌 커피머신", content: "", price: "990000", category: "생활가전", images: ["브레빌커피머신"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "삼성 냉장고 팝니다.", content: "", price: "1300000", category: "생활가전", images: ["삼성냉장고"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 삼성 에어컨 팔아요", content: "", price: "1200000", category: "생활가전", images: ["삼성에어컨1"]),
            DummyData(phoneNumber: nil, address: nil, title: "삼성 에어컨", content: "", price: "1600000", category: "생활가전", images: ["삼성에어컨2"]),
            DummyData(phoneNumber: nil, address: nil, title: "삼성 에어컨 팝니다.", content: "", price: "1500000", category: "생활가전", images: ["삼성에어컨3"]),
            DummyData(phoneNumber: nil, address: nil, title: "삼성 전자레인지 팝니다.", content: "", price: "300000", category: "생활가전", images: ["삼성전자레인지"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 선풍기 팔아요", content: "", price: "50000", category: "생활가전", images: ["선풍기1"]),
            DummyData(phoneNumber: nil, address: nil, title: "선풍기 팝니다.", content: "", price: "70000", category: "생활가전", images: ["선풍기2"]),
            DummyData(phoneNumber: nil, address: nil, title: "스탠드 티비 팔아요", content: "", price: "500000", category: "생활가전", images: ["스탠드티비"]),
            DummyData(phoneNumber: nil, address: nil, title: "얼음 정수기 팝니다.", content: "", price: "200000", category: "생활가전", images: ["얼음정수기"]),
            DummyData(phoneNumber: nil, address: nil, title: "엘지 냉장고 팝니다", content: "", price: "1500000", category: "생활가전", images: ["엘지냉장고"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "엘지 에어컨 팔아요", content: "", price: "1500000", category: "생활가전", images: ["엘지에어컨"]),
            DummyData(phoneNumber: nil, address: nil, title: "예스뷰티 고데기 팝니다.", content: "", price: "30000", category: "생활가전", images: ["예스뷰티고데기"]),
            DummyData(phoneNumber: nil, address: nil, title: "전자레인지 팔아요", content: "", price: "40000", category: "생활가전", images: ["전자레인지"]),
            DummyData(phoneNumber: nil, address: nil, title: "창문형 에어컨 팝니다.", content: "", price: "330000", category: "생활가전", images: ["창문형에어컨"]),
            DummyData(phoneNumber: nil, address: nil, title: "청소기 급하게 팝니다.", content: "", price: "300000", category: "생활가전", images: ["청소기1"]),
            DummyData(phoneNumber: nil, address: nil, title: "청소기 팔아요", content: "", price: "250000", category: "생활가전", images: ["청소기2"]),
            DummyData(phoneNumber: nil, address: nil, title: "코스텔 냉장고", content: "", price: "400000", category: "생활가전", images: ["코스텔냉장고"]),
            DummyData(phoneNumber: nil, address: nil, title: "쿠쿠 밥솥 팝니다.", content: "", price: "150000", category: "생활가전", images: ["쿠쿠밥솥"]),
            DummyData(phoneNumber: nil, address: nil, title: "엘지 티비 팔아요", content: "", price: "1350000", category: "생활가전", images: ["LG티비"]),
            DummyData(phoneNumber: nil, address: nil, title: "PN 풍년 밥솥 팔아요", content: "", price: "130000", category: "생활가전", images: ["PN풍년밥솥"]),
            
            // 생활/주방
            DummyData(phoneNumber: nil, address: nil, title: "그릇 2개 팝니다.", content: "", price: "30000", category: "생활/주방", images: ["그릇1"]),
            DummyData(phoneNumber: nil, address: nil, title: "그릇 팝니다.", content: "", price: "40000", category: "생활/주방", images: ["그릇2"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 그릇 팝니다.", content: "", price: "50000", category: "생활/주방", images: ["그릇3"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 밀폐용기 팝니다.", content: "", price: "60000", category: "생활/주방", images: ["밀폐용기1"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 밀폐용기 팔아요", content: "", price: "50000", category: "생활/주방", images: ["밀폐용기2"]),
            DummyData(phoneNumber: nil, address: nil, title: "중고 밀폐용기 팝니다", content: "", price: "40000", category: "생활/주방", images: ["밀폐용기3"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 수세미 팝니다.", content: "", price: "5000", category: "생활/주방", images: ["수세미1"]),
            DummyData(phoneNumber: nil, address: nil, title: "수세미 팔아요", content: "", price: "9000", category: "생활/주방", images: ["수세미2"]),
            DummyData(phoneNumber: nil, address: nil, title: "수세미", content: "", price: "3000", category: "생활/주방", images: ["수세미3"]),
            DummyData(phoneNumber: nil, address: nil, title: "주방용 칼 팝니다.", content: "", price: "50000", category: "생활/주방", images: ["식칼1"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "주방용 칼", content: "", price: "45000", category: "생활/주방", images: ["식칼2"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 주방용 칼 팝니다.", content: "", price: "30000", category: "생활/주방", images: ["식칼3"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 양념통 팔아요", content: "", price: "12000", category: "생활/주방", images: ["양념통1"]),
            DummyData(phoneNumber: nil, address: nil, title: "양념통 2개 팔아요", content: "", price: "15000", category: "생활/주방", images: ["양념통2"]),
            DummyData(phoneNumber: nil, address: nil, title: "양념통 5개 팝니다.", content: "", price: "18000", category: "생활/주방", images: ["양념통3"]),
            DummyData(phoneNumber: nil, address: nil, title: "새 양념통 팝니다.", content: "", price: "20000", category: "생활/주방", images: ["양념통4"]),
            DummyData(phoneNumber: nil, address: nil, title: "양념통 팔아요", content: "", price: "30000", category: "생활/주방", images: ["양념통5"]),
            DummyData(phoneNumber: nil, address: nil, title: "와인잔 팝니다", content: "", price: "30000", category: "생활/주방", images: ["와인잔"]),
            DummyData(phoneNumber: nil, address: nil, title: "가벼운 와인잔 팔아요", content: "", price: "25000", category: "생활/주방", images: ["와인잔1"]),
            DummyData(phoneNumber: nil, address: nil, title: "와인잔 3개 팝니다", content: "", price: "20000", category: "생활/주방", images: ["와인잔3"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "새상품 와인잔 판매합니다.", content: "", price: "22000", category: "생활/주방", images: ["와인잔4"]),
            DummyData(phoneNumber: nil, address: nil, title: "주방세제 팝니다.", content: "", price: "5000", category: "생활/주방", images: ["주방세제1"]),
            DummyData(phoneNumber: nil, address: nil, title: "천연 주방세제 팝니다.", content: "", price: "10000", category: "생활/주방", images: ["주방세제2"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 주방세제 팔아요", content: "", price: "12000", category: "생활/주방", images: ["주방세제3"]),
            DummyData(phoneNumber: nil, address: nil, title: "텀블러 팝니다.", content: "", price: "8000", category: "생활/주방", images: ["텀블러1"]),
            DummyData(phoneNumber: nil, address: nil, title: "텀블러 팔아요", content: "", price: "12000", category: "생활/주방", images: ["텀블러2"]),
            DummyData(phoneNumber: nil, address: nil, title: "텀블러", content: "", price: "25000", category: "생활/주방", images: ["텀블러3"]),
            DummyData(phoneNumber: nil, address: nil, title: "후라이팬 팝니다.", content: "", price: "25000", category: "생활/주방", images: ["후라이팬"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 후라이팬 팝니다", content: "", price: "2000", category: "생활/주방", images: ["후라이팬2"]),
            DummyData(phoneNumber: nil, address: nil, title: "후라이팬", content: "", price: "22000", category: "생활/주방", images: ["후라이팬3"]),
            
            // 유아동
            DummyData(phoneNumber: nil, address: nil, title: "애기옷 팝니다", content: "", price: "40000", category: "유아동", images: ["유아옷1"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 애기옷 팝니다.", content: "", price: "43000", category: "유아동", images: ["유아옷2"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 애기옷 팝니다", content: "", price: "34000", category: "유아동", images: ["유아옷3"]),
            DummyData(phoneNumber: nil, address: nil, title: "아동 옷 팔아요", content: "", price: "35000", category: "유아동", images: ["유아옷4"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아 옷 팔아요", content: "", price: "55000", category: "유아동", images: ["유아옷5"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 유아옷 팝니다", content: "", price: "12000", category: "유아동", images: ["유아옷6"]),
            DummyData(phoneNumber: nil, address: nil, title: "애기 옷 2개 팔아요", content: "", price: "33000", category: "유아동", images: ["유아옷7"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 장난감 팝니다.", content: "", price: "12000", category: "유아동", images: ["장난감1"]),
            DummyData(phoneNumber: nil, address: nil, title: "애기들 장난감 팔아요", content: "", price: "15000", category: "유아동", images: ["장난감2"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 장난감 팝니다.", content: "", price: "19000", category: "유아동", images: ["장난감3"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "유아용 장난감", content: "", price: "20000", category: "유아동", images: ["장난감4"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 장난감 여러개 팝니다", content: "", price: "11000", category: "유아동", images: ["장난감5"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 장난감 팝니다", content: "", price: "32000", category: "유아동", images: ["장난감6"]),
            DummyData(phoneNumber: nil, address: nil, title: "한번도 사용안한 유아용 장난감 팔아요", content: "", price: "33000", category: "유아동", images: ["장난감7"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 장난감 2개 팝니다", content: "", price: "40000", category: "유아동", images: ["장난감8"]),
            DummyData(phoneNumber: nil, address: nil, title: "장난감 팝니다.", content: "", price: "60000", category: "유아동", images: ["장난감9"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 장난감 팝니다.", content: "", price: "14000", category: "유아동", images: ["장난감10"]),
            DummyData(phoneNumber: nil, address: nil, title: "사용감 적은 유아용 장난감 팝니다.", content: "", price: "64000", category: "유아동", images: ["장난감11"]),
            DummyData(phoneNumber: nil, address: nil, title: "장난감 팔아요", content: "", price: "15000", category: "유아동", images: ["장난감12"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 장난감 3개 팝니다.", content: "", price: "17000", category: "유아동", images: ["장난감13"]),
            
            DummyData(phoneNumber: nil, address: nil, title: "애기용 장난감 팝니다.", content: "", price: "11000", category: "유아동", images: ["장난감14"]),
            DummyData(phoneNumber: nil, address: nil, title: "젖병 팔아요", content: "", price: "5000", category: "유아동", images: ["젖병1"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 젖병", content: "", price: "3000", category: "유아동", images: ["젖병2"]),
            DummyData(phoneNumber: nil, address: nil, title: "젖병 3개 팝니다.", content: "", price: "12000", category: "유아동", images: ["젖병3"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 젖병 팔아요", content: "", price: "33000", category: "유아동", images: ["젖병4"]),
            DummyData(phoneNumber: nil, address: nil, title: "새상품 유아용 옷 2개 팝니다.", content: "", price: "3300", category: "유아동", images: ["유아옷8"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 옷 팔아요", content: "", price: "7500", category: "유아동", images: ["유아옷9"]),
            DummyData(phoneNumber: nil, address: nil, title: "애기용 옷", content: "", price: "5500", category: "유아동", images: ["유아옷10"]),
            DummyData(phoneNumber: nil, address: nil, title: "유아용 옷 팝니다.", content: "", price: "9400", category: "유아동", images: ["유아옷11"]),
            DummyData(phoneNumber: nil, address: nil, title: "옷 판매", content: "", price: "11000", category: "유아동", images: ["유아옷12"])
        ]
        
        var userCount = 0
        var addressCount = 0
        var categoryDataCount = 0

        categoryDatas.shuffle()
        
        for i in 0...149 {
            if userCount == userData.count {
                userCount = 0
                userData.shuffle()
            }
            
            if addressCount == addressList.count {
                addressCount = 0
                addressList.shuffle()
            }

            
            categoryDatas[i].phoneNumber = userData[userCount]
            categoryDatas[i].address = addressList[addressCount]
            //categoryDatas[i].title += "\(i)"
            
            userCount += 1
            addressCount += 1
            
            if i == 149 {
                completion(categoryDatas)
            }
        }
    }

    /// 상품 추가하기
    /// - Parameters:
    ///   - productData: 상품 정보
    ///   - selectedImages: 선택한 상품 이미지들
    ///   - completion: 응답 처리
    func addDummyProduct(address: String, productData: [String: Any], selectedImages: [UIImage], completion: @escaping (Result<Bool,FirebaseError>) -> ()) {
        
        let group = DispatchGroup()
        
        var finishedQuery: CollectionReference?
        let documentId = db.collection("게시물").document().documentID
        var city = ""
        
       
            
        self.checkAreaDocument(address: address) { ref in
            finishedQuery = ref?.collection("상품")
            
            let separatedAddress = address.components(separatedBy:  " ") ?? []
            
            switch separatedAddress.count {
            case 2:
                city = separatedAddress[0]
            case 3:
                city = separatedAddress[1]
            case 4:
                city = separatedAddress[2]
            default:
                print("default")
            }
            
            // 이미지 URL 업로드
            self.uploadImages(documentId: documentId, phoneNumber: productData["phoneNumber"] as? String ?? "", images: selectedImages, uploadType: .productsImage) { result in
                
                switch result {
                case .success(let url):
                    
                    // 상품 데이터에 이미지 URL, id 넣어야함
                    var copyProductData = productData
                    copyProductData["productId"] = documentId
                    copyProductData["imagesURL"] = url
                    copyProductData["update"] = Date()
                    
                    group.enter()
                    // 상품에 추가
                    finishedQuery?.document(documentId).setData(copyProductData, completion: { error in
                        if let error = error {
                            completion(.failure(.addProductError(error)))
                        } else {
                            print("상품 추가 완료")
                            group.leave()
                        }
                    })
                    
                    let semiProductData = [
                        "address": address,
                        "city": city,
                        "id": documentId,
                        "status": ProductStatusType.trading.rawValue,
                        "hidden": false,
                        "update": copyProductData["update"]
                    ] as [String: Any]
                    
                    group.enter()
                    // 내 정보에도 추가
                    self.db.collection("유저정보").document(productData["phoneNumber"] as? String ?? "").collection("전체상품").document(documentId).setData(semiProductData) { error in
                        if let error = error {
                            completion(.failure(.semiAddproductError(error)))
                        } else {
                            group.leave()
                        }
                    }
                    
                    group.enter()
                    // 상품 카운트 추가
                    self.getProductsCount(phoneNumber: productData["phoneNumber"] as? String ?? "") { result in
                        switch result {
                        case .success(let productCount):
                            group.enter()
                            self.updateProductsCount(phoneNumber: productData["phoneNumber"] as? String ?? "", productCountData: productCount, process: "create", productStatus: "", isHidden: false) { result in
                                switch result {
                                case .success(_):
                                    print("상품 카운트 추가 완료")
                                    group.leave()
                                case .failure(let error):
                                    print("updateProductsCount - error", error)
                                    group.leave()
                                }
                            }
                            group.leave()
                        case .failure(let error):
                            print(error)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        completion(.success(true))
                    }
                    
                case .failure(let error):
                    completion(.failure(.uploadImagesError(error)))
                }
            }
        }
    }
}

struct DummyData {
    var phoneNumber: String?
    var address: String?
    var title: String
    let content: String
    var price: String
    let category: String
    let hidden: Bool = false
    let status: String = "trading"
    let reservation: Bool = false
    let images: [String]
}
