////
////  ProductDetailViewController.swift
////  Danggeun_Clone
////
////  Created by PKW on 2022/05/30.
////
//
//import UIKit
//import SnapKit
//import Kingfisher
//import FirebaseFirestore
//
//
//class ProductDetailViewController11: UIViewController {
//
//    // 메인 스크롤뷰
//    lazy var mainScrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.restorationIdentifier = "mainScrollView"
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//
//    // 메인 스크롤뷰 스택뷰
//    lazy var stackViewInMainScrollView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        return stackView
//    }()
//
//    // 유저 정보 뷰
//    lazy var userInfoView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleToFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    lazy var nickNameLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 17)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var regionLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    // 상세내용 뷰
//    lazy var productInfoView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var productTitleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var categoryLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var contentTextLabel: UILabel = {
//        let textView = UILabel()
//        textView.numberOfLines = 0
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        return textView
//    }()
//
//    lazy var countLabel: UILabel = {
//        let label = UILabel()
//        label.text = "관심 8 조회 333"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    // 신고하기 뷰
//    lazy var reportView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var reportLabel: UILabel = {
//        let label = UILabel()
//        label.text = "이 게시글 신고하기"
//        label.sizeToFit()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var reportArrowImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "right-arrow")
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    // 판매자 판매상품 뷰
//    lazy var otherProductsView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var otherProductsTitleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var viewMoreButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("더보기", for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    lazy var otherProductsCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.restorationIdentifier = "otherProductsCollectionView"
//        return collectionView
//    }()
//
//    // 추천 상품 뷰
//    lazy var recommendationView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var recommendationTitle: UILabel = {
//        let label = UILabel()
//        return label
//    }()
//
//    lazy var recommendationCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.restorationIdentifier = "recommendationCollectionView"
//        return collectionView
//    }()
//
//    // 이미지 스크롤뷰
//    lazy var productImagesScrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.restorationIdentifier = "productImagesScrollView"
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.isPagingEnabled = true
//        scrollView.isScrollEnabled = true
//        scrollView.bounces = false
//        return scrollView
//    }()
//
//    lazy var pageControl: UIPageControl = {
//        let pageControl = UIPageControl()
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        pageControl.currentPage = 0
//        return pageControl
//    }()
//
//    lazy var underlineView1: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray4
//        return view
//    }()
//
//    lazy var underlineView2: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray4
//        return view
//    }()
//
//    lazy var underlineView3: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray4
//        return view
//    }()
//
//    lazy var underlineView4: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray4
//        return view
//    }()
//
//    lazy var underlineView5: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray4
//        return view
//    }()
//
//    lazy var bottomView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var heartButton: UIButton = {
//        let button = UIButton()
//        let config = UIImage.SymbolConfiguration(pointSize: 20)
//        let image = UIImage(systemName: "heart", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .systemGray4
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    lazy var lineView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray4
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var priceLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 15)
//        label.text = "10,000원"
//        return label
//    }()
//
//    lazy var proposalLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 12)
//        label.text = "가격 제안 불가"
//        return label
//    }()
//
//    lazy var chattingButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.setTitle("채팅하기", for: .normal)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.backgroundColor = .orange
//        button.layer.cornerRadius = 5
//        return button
//    }()
//
//    var viewState = ViewState.notFinish
//
//    var product: ProductRegistrationModel?
//
//    let db = Firestore.firestore()
//
//    var images = [UIImage]()
//    var imageHeights = [CGFloat]()
//
//    var otherProducts = [ProductRegistrationModel]()
//    var categoryProducts = [ProductRegistrationModel]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        mainScrollView.delegate = self
//        productImagesScrollView.delegate = self
//
//        otherProductsCollectionView.register(OtherProductCollectionViewCell.self, forCellWithReuseIdentifier: OtherProductCollectionViewCell.identifier)
//
//        recommendationCollectionView.register(OtherProductCollectionViewCell.self, forCellWithReuseIdentifier: OtherProductCollectionViewCell.identifier)
//
//        otherProductsCollectionView.delegate = self
//        otherProductsCollectionView.dataSource = self
//
//        recommendationCollectionView.delegate = self
//        recommendationCollectionView.dataSource = self
//
//        self.navigationController?.hidesBarsOnSwipe = false
//
//        configureAddSubView()
//        configureConstratint()
//
//        setProductsValue()
//
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToZoom))
//        tap.numberOfTapsRequired = 1
//        productImagesScrollView.addGestureRecognizer(tap)
//
//        downloadImages { [weak self] images in
//            DispatchQueue.main.async {
//                self?.productImagesScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(images.count), height: 0)
//                self?.pageControl.numberOfPages = images.count
//                self?.configureImages(images: images)
//                self?.viewState = .finish
//                self?.images = images
//
//                if images.isEmpty {
//
//                    self?.productImagesScrollView.isHidden = true
//
//                    self?.stackViewInMainScrollView.snp.updateConstraints { make in
//                        make.leading.trailing.top.bottom.equalToSuperview()
//                    }
//                }
//            }
//        }
//
//
//        downloadImages2 {
//            if self.otherProducts.isEmpty {
//                self.otherProductsView.isHidden = true
//            } else {
//                self.otherProductsCollectionView.reloadData()
//            }
//        }
//
//        downloadImage3 {
//            self.recommendationCollectionView.reloadData()
//        }
//
//    }
//
//    @objc func tapToZoom() {
//        print("터치 먹힘")
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "zoom") as? ZoomImageViewController else { return }
//
//        vc.images = images
//        vc.imageIndex = pageControl.currentPage
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false)
//    }
//
//    func setProductsValue() {
//        // 유저 정보 세팅
//        print("게시글 유저 번호 = \(product!.phoneNumber)")
//
//        db.collection("유저정보").whereField("phoneNumber", isEqualTo: product!.phoneNumber).getDocuments { snapShot, error in
//            if let error = error {
//                print("유저 정보 가져오기 실패 \(error)")
//            }
//            guard let data = snapShot?.documents else { return }
//            for document in data {
//                self.profileImageView.kf.setImage(with: URL(string: document["profileImage"] as? String ?? ""), placeholder: UIImage(named: "user"))
//                self.nickNameLabel.text = document["nickname"] as? String ?? ""
//                self.regionLabel.text = document["address"] as? String ?? ""
//                self.otherProductsTitleLabel.text = "\(document["nickname"] as? String ?? "")님의 판매 상품"
//            }
//        }
//
//        // 게시글 정보 세팅
//        productTitleLabel.text = product?.title
//        categoryLabel.text = "\(product?.category ?? "") - \(product?.update.convertTimestamp() ?? "")전"
//        contentTextLabel.text = product?.content
//        // 조회수는 나중에 추가
//        recommendationTitle.text = "\(UserModel.getUserData().nickName)님 이건 어때요?"
//
//    }
//
//    override func viewDidLayoutSubviews() {
//        otherProductsCollectionView.snp.updateConstraints { make in
//            make.height.equalTo(otherProductsCollectionView.contentSize.height)
//        }
//
//        recommendationCollectionView.snp.updateConstraints { make in
//            make.height.equalTo(recommendationCollectionView.contentSize.height)
//            make.bottom.equalToSuperview().inset(bottomView.frame.height * 0.8)
//        }
//
//        profileImageView.layer.cornerRadius =  profileImageView.frame.width * 0.5
//
//        heartButton.snp.updateConstraints { make in
//            make.height.equalTo(chattingButton.frame.height)
//            make.width.equalTo(chattingButton.frame.height)
//        }
//
//        lineView.snp.updateConstraints { make in
//            make.height.equalTo(chattingButton.frame.height)
//        }
//    }
//
//
//    func configureAddSubView() {
//
//        self.view.addSubview(mainScrollView)
//
//        mainScrollView.addSubview(productImagesScrollView)
//        mainScrollView.addSubview(stackViewInMainScrollView)
//        mainScrollView.addSubview(pageControl)
//
//        stackViewInMainScrollView.addArrangedSubview(userInfoView)
//        userInfoView.addSubview(profileImageView)
//        userInfoView.addSubview(nickNameLabel)
//        userInfoView.addSubview(regionLabel)
//        userInfoView.addSubview(underlineView1)
//
//        stackViewInMainScrollView.addArrangedSubview(productInfoView)
//        productInfoView.addSubview(productTitleLabel)
//        productInfoView.addSubview(categoryLabel)
//        productInfoView.addSubview(contentTextLabel)
//        productInfoView.addSubview(countLabel)
//        productInfoView.addSubview(underlineView2)
//
//        stackViewInMainScrollView.addArrangedSubview(reportView)
//        reportView.addSubview(reportLabel)
//        reportView.addSubview(reportArrowImageView)
//        reportView.addSubview(underlineView3)
//
//
//        stackViewInMainScrollView.addArrangedSubview(otherProductsView)
//        otherProductsView.addSubview(otherProductsTitleLabel)
//        otherProductsView.addSubview(viewMoreButton)
//        otherProductsView.addSubview(otherProductsCollectionView)
//        otherProductsView.addSubview(underlineView4)
//
//
//        stackViewInMainScrollView.addArrangedSubview(recommendationView)
//        recommendationView.addSubview(recommendationTitle)
//        recommendationView.addSubview(recommendationCollectionView)
//
//        self.view.addSubview(bottomView)
//        bottomView.addSubview(heartButton)
//        bottomView.addSubview(lineView)
//        bottomView.addSubview(priceLabel)
//        bottomView.addSubview(proposalLabel)
//        bottomView.addSubview(chattingButton)
//        bottomView.addSubview(underlineView5)
//    }
//
//    func configureConstratint() {
//
//        let height = UIScreen.main.bounds.height * 0.5
//        let statusBarHeight = UIApplication.shared.statusBarFrame.height
//        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
//
//        // 메인 스크롤뷰
//        mainScrollView.snp.makeConstraints { make in
//            make.leading.trailing.top.bottom.equalToSuperview()
//            make.width.equalToSuperview()
//        }
//
//        // 메인 스크롤뷰 스택뷰
//        stackViewInMainScrollView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.equalTo(height - statusBarHeight - navigationBarHeight)
//            make.width.equalToSuperview()
//        }
//
//        // 페이지 컨트롤러
//        pageControl.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.bottom.equalTo(stackViewInMainScrollView.snp.top)
//        }
//
//        // 이미지 스크롤뷰
//        productImagesScrollView.snp.makeConstraints { make in
//            make.leading.equalTo(self.view.snp.leading)
//            make.trailing.equalTo(self.view.snp.trailing)
//            make.top.equalTo(self.view.snp.top)
//            make.bottom.equalTo(self.view.snp.bottom)
//        }
//
//        // 유저 정보 뷰
//        userInfoView.snp.makeConstraints { make in
//            make.width.equalTo(mainScrollView.snp.width)
//        }
//
//        profileImageView.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview().inset(20)
//            make.leading.equalToSuperview().inset(15)
//            make.width.equalTo(50)
//            make.height.equalTo(50)
//        }
//
//        nickNameLabel.snp.makeConstraints { make in
//            make.leading.equalTo(profileImageView.snp.trailing).inset(-10)
//            make.top.equalTo(profileImageView.snp.top)
//        }
//
//        regionLabel.snp.makeConstraints { make in
//            make.leading.equalTo(profileImageView.snp.trailing).inset(-10)
//            make.bottom.equalTo(profileImageView.snp.bottom)
//        }
//
//        // 제품정보 뷰
//        productInfoView.snp.makeConstraints { make in
//            make.width.equalTo(mainScrollView.snp.width)
//        }
//
//        productTitleLabel.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.top.equalToSuperview().inset(20)
//        }
//
//        categoryLabel.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.top.equalTo(productTitleLabel.snp.bottom).offset(15)
//        }
//
//        contentTextLabel.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.top.equalTo(categoryLabel.snp.bottom).offset(15)
//        }
//
//        countLabel.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.top.equalTo(contentTextLabel.snp.bottom).offset(15)
//            make.bottom.equalToSuperview().inset(20)
//        }
//
//        // 신고하기 뷰
//        reportView.snp.makeConstraints { make in
//            make.width.equalTo(mainScrollView.snp.width)
//        }
//
//        reportLabel.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(15)
//            make.top.bottom.equalToSuperview().inset(20)
//        }
//
//        reportArrowImageView.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().inset(15)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(13)
//            make.width.equalTo(13)
//        }
//
//
//        // 판매자 다른상품 뷰
//        otherProductsView.snp.makeConstraints { make in
//            make.width.equalTo(mainScrollView.snp.width)
//        }
//
//        otherProductsTitleLabel.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(15)
//            make.top.equalToSuperview().inset(20)
//        }
//
//        viewMoreButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().inset(15)
//            make.centerY.equalTo(otherProductsTitleLabel.snp.centerY)
//        }
//
//        otherProductsCollectionView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.equalTo(otherProductsTitleLabel.snp.bottom)
//            make.height.equalTo(10)
//        }
//
//        // 상품 추천 뷰
//        recommendationView.snp.makeConstraints { make in
//            make.width.equalTo(mainScrollView.snp.width)
//        }
//
//        recommendationTitle.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(15)
//            make.top.equalToSuperview().inset(20)
//        }
//
//        recommendationCollectionView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.equalTo(recommendationTitle.snp.bottom)
//            make.height.equalTo(10)
//        }
//
//        // 언더라인 뷰
//        underlineView1.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
//
//        underlineView2.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
//
//        underlineView3.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
//
//        underlineView4.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
//
//        // 바텀 뷰
//        bottomView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.11)
//        }
//
//        chattingButton.snp.makeConstraints { make in
//            make.trailing.top.equalToSuperview().inset(20)
//            make.width.equalToSuperview().multipliedBy(0.2)
//        }
//
//        heartButton.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(10)
//            make.height.equalTo(10)
//            make.width.equalTo(10)
//            make.centerY.equalTo(chattingButton.snp.centerY)
//        }
//
//        lineView.snp.makeConstraints { make in
//            make.leading.equalTo(heartButton.snp.trailing).offset(10)
//            make.centerY.equalTo(heartButton.snp.centerY)
//            make.width.equalTo(1)
//            make.height.equalTo(10)
//        }
//
//        priceLabel.snp.makeConstraints { make in
//            make.leading.equalTo(lineView.snp.trailing).offset(10)
//            make.top.equalTo(chattingButton.snp.top)
//        }
//
//        proposalLabel.snp.makeConstraints { make in
//            make.leading.equalTo(lineView.snp.trailing).offset(10)
//            make.bottom.equalTo(chattingButton.snp.bottom)
//        }
//
//        underlineView5.snp.makeConstraints { make in
//            make.leading.trailing.top.equalToSuperview()
//            make.height.equalTo(1)
//        }
//
//    }
//
//    func configureImages(images: [UIImage]) {
//        for (index,image) in images.enumerated() {
//            let imageView = UIImageView()
//            let xPos = UIScreen.main.bounds.width * CGFloat(index)
//            imageView.image = image
//
//            let ratio = image.size.width / image.size.height
//            var newHeight = UIScreen.main.bounds.width / ratio
//
//            if newHeight > 700 {
//                newHeight = UIScreen.main.bounds.height * 0.8
//            } else if newHeight < UIScreen.main.bounds.height / 2 {
//                newHeight = UIScreen.main.bounds.height / 2
//            }
//
//            imageHeights.append(floor(newHeight))
//            imageView.frame = CGRect(x: xPos, y: 0, width: UIScreen.main.bounds.width, height: floor(newHeight))
//            productImagesScrollView.addSubview(imageView)
//        }
//    }
//
//
//    func downloadImages(completion: @escaping ([UIImage]) -> ()) {
//
//        guard let photos = product?.photo else { return }
//        var images = [UIImage]()
//
//        DispatchQueue.global().async {
//            let semaphore = DispatchSemaphore(value: 0)
//
//            for url in photos {
//                if let url = URL(string: url) {
//                    let resource = ImageResource(downloadURL: url)
//                    KingfisherManager.shared.retrieveImage(with: resource) { result in
//                        switch result {
//                        case .success(let value):
//                            images.append(value.image)
//                            semaphore.signal()
//                        case .failure(let error):
//                            print(error)
//                            semaphore.signal()
//                        }
//                    }
//                    semaphore.wait()
//                }
//            }
//            completion(images)
//        }
//    }
//
//    func downloadImages2(completion: @escaping () -> ()) {
//        db.collection("게시글").whereField("phoneNumber", isEqualTo: product?.phoneNumber).getDocuments { snapShot, error in
//            if let error = error {
//                print("판매자 다른 상품 검색 실패 = \(error)")
//            }
//
//            guard let snap = snapShot?.documents else { return }
//
//            for product in snap {
//
//                if self.product?.title != product["title"] as? String ?? "" {
//                    let title = product["title"] as? String ?? ""
//                    let address = product["address"] as? String ?? ""
//                    let category = product["category"] as? String ?? ""
//                    let content = product["contents"] as? String ?? ""
//                    let phone = product["phoneNumber"] as? String ?? ""
//                    let photos = product["photos"] as? [String] ?? [""]
//                    let price = product["price"] as? String ?? ""
//                    let date = product["update"] as? Timestamp
//
//                    let productInfo = ProductRegistrationModel(phoneNumber: phone, photo: photos, title: title, category: category, price: price, content: content, update: date as? NSDate ?? NSDate())
//                    self.otherProducts.append(productInfo)
//                }
//
//            }
//            print("다른상품 글 가져오기")
//            completion()
//        }
//    }
//
//    func downloadImage3(completion: @escaping () -> ()) {
//        db.collection("게시글").whereField("category", isEqualTo: product?.category).getDocuments { snapShot, error in
//            if let error = error {
//                print("카테고리 게시물 가져오기 실패 = \(error)")
//            }
//
//            guard let snap = snapShot?.documents else { return }
//
//            for product in snap {
//
//                if self.product?.title != product["title"] as? String ?? "" {
//                    let title = product["title"] as? String ?? ""
//                    let address = product["address"] as? String ?? ""
//                    let category = product["category"] as? String ?? ""
//                    let content = product["contents"] as? String ?? ""
//                    let phone = product["phoneNumber"] as? String ?? ""
//                    let photos = product["photos"] as? [String] ?? [""]
//                    let price = product["price"] as? String ?? ""
//                    let date = product["update"] as? Timestamp
//
//                    let productInfo = ProductRegistrationModel(phoneNumber: phone, photo: photos, title: title, category: category, price: price, content: content, update: date as? NSDate ?? NSDate())
//                    self.categoryProducts.append(productInfo)
//                }
//            }
//            print("카테고리 글 가져오기")
//            completion()
//        }
//    }
//}
//
//
//extension ProductDetailViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        if collectionView.restorationIdentifier == "otherProductsCollectionView" {
//            if otherProducts.count > 5 {
//                return 4
//            } else {
//                return otherProducts.count
//            }
//        } else if collectionView.restorationIdentifier == "recommendationCollectionView" {
//            return 5
//        } else {
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherProductCollectionViewCell.identifier, for: indexPath) as? OtherProductCollectionViewCell else { return UICollectionViewCell() }
//
//        if collectionView.restorationIdentifier == "otherProductsCollectionView" {
//            if !otherProducts.isEmpty {
//                cell.imageView.kf.setImage(with: URL(string: otherProducts[indexPath.row].photo.first ?? ""))
//                cell.productTitleLabel.text = otherProducts[indexPath.row].title
//                cell.priceLabel.text = otherProducts[indexPath.row].price
//                cell.tag = indexPath.row
//            }
//            return cell
//        } else if collectionView.restorationIdentifier == "recommendationCollectionView" {
//            if !categoryProducts.isEmpty {
//                cell.imageView.kf.setImage(with: URL(string: categoryProducts[indexPath.row].photo.first ?? ""))
//                cell.productTitleLabel.text = categoryProducts[indexPath.row].title
//                cell.priceLabel.text = categoryProducts[indexPath.row].price
//                cell.tag = indexPath.row
//            }
//            return cell
//        } else {
//            return UICollectionViewCell()
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView.restorationIdentifier == "otherProductsCollectionView" {
//            print(collectionView.cellForItem(at: indexPath)?.tag)
//            guard let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? ProductDetaile2ViewController else { return }
//            vc.product = otherProducts[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else if collectionView.restorationIdentifier == "recommendationCollectionView" {
//            print(collectionView.cellForItem(at: indexPath)?.tag)
//        }
//    }
//}
//
//extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let size = UIScreen.main.bounds.width / 2 * 0.90
//        return CGSize(width: size, height: size)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 30
//    }
//}
//
//extension ProductDetailViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if viewState == .finish && !images.isEmpty {
//            if scrollView.restorationIdentifier == "mainScrollView" {
//                productImagesScrollView.contentOffset.y = scrollView.contentOffset.y > 0 ? scrollView.contentOffset.y : 0
//
//                let imageHeight = imageHeights[pageControl.currentPage]
//                let imageViews = productImagesScrollView.subviews.filter({$0 is UIImageView})
//                let imageView = imageViews[pageControl.currentPage]
//
//                let coverHeight = imageHeight - stackViewInMainScrollView.frame.origin.y
//                let scale = 1 + -(coverHeight + scrollView.contentOffset.y) * 2 / imageHeight
//
//
//                if stackViewInMainScrollView.frame.origin.y + -scrollView.contentOffset.y > 121 {
//                    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//                    self.navigationController?.navigationBar.shadowImage = UIImage()
//                } else {
//                    self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//                    self.navigationController?.navigationBar.shadowImage = nil
//                }
//
//                if stackViewInMainScrollView.frame.origin.y + -scrollView.contentOffset.y > imageHeights[pageControl.currentPage] {
//                    imageView.transform = .identity
//                    imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
//                } else {
//                    imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
//                }
//            }
//        }
//        if scrollView.restorationIdentifier == "productImagesScrollView" {
//            pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
//        }
//    }
//}
