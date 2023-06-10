//
//  ProductDetailView.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/16.
//

import UIKit
import SnapKit

enum ViewState {
    case notFinish
    case finish
}

class ProductDetailView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProductDetailView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureProductDetailView()
    }
    
    // 전체 루트 뷰
    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    // 메인 스크롤 뷰
    var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.restorationIdentifier = "mainScrollView"
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var productImagesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.restorationIdentifier = "productImagesScrollView"
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    // 게시글 정보 표시할 스텍 뷰
    var stackViewInMainScrollView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    // 유저 정보 뷰
    var userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "swift")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "닉네임 테스트"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var regionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "지역 이름 테스트"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var profileButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var underlineView1: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // 상세 내용 뷰
    var productInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var productTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상품 제목 테스트"
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var categoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("카테고리 버튼", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "2시간 전"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var contentTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "내용 테스트 \n내용 테스트2 \n내용 테스트3"
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    var chattingCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    var interestCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var underlineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // 신고하기 뷰
    var reportView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var reportLabel: UILabel = {
        let label = UILabel()
        label.text = "이 게시글 신고하기"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var reportArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "right-arrow")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var reportButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var underlineView3: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // 판매자 판매상품 뷰
    var otherProductsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var otherProductsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "XXX님 판매 상품"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var viewMoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("더보기", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var otherProductsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.restorationIdentifier = "otherProductsCollectionView"
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var underlineView4: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // 추천 상품 뷰
    var recommendationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var recommendationTitle: UILabel = {
        let label = UILabel()
        label.text = "xxx이건 어때요?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var recommendationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.restorationIdentifier = "recommendationCollectionView"
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var underlineView5: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // 페이지 컨트롤러
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        return pageControl
    }()
    
    // 하단 뷰
    var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var heartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.tintColor = .systemGray4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var line: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    var priceLabel: UILabel = {
       let label = UILabel()
        label.text = "111,111,111"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var startChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("채팅하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5
        return button
    }()
    
    var topline: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func configureProductDetailView() {
        
        addSubview(mainView)

        mainView.addSubview(mainScrollView)
        mainScrollView.addSubview(productImagesScrollView)
        mainScrollView.addSubview(stackViewInMainScrollView)
        mainScrollView.addSubview(pageControl)
        
        stackViewInMainScrollView.addArrangedSubview(userInfoView)
        userInfoView.addSubview(profileImageView)
        userInfoView.addSubview(nickNameLabel)
        userInfoView.addSubview(regionLabel)
        userInfoView.addSubview(profileButton)
        userInfoView.addSubview(underlineView1)
        
        stackViewInMainScrollView.addArrangedSubview(productInfoView)
        productInfoView.addSubview(productTitleLabel)
        productInfoView.addSubview(categoryButton)
        productInfoView.addSubview(timeLabel)
        productInfoView.addSubview(contentTextLabel)
        productInfoView.addSubview(countStackView)
        
        countStackView.addArrangedSubview(chattingCountLabel)
        countStackView.addArrangedSubview(interestCountLabel)
        countStackView.addArrangedSubview(countLabel)
        
        productInfoView.addSubview(underlineView2)
        
        stackViewInMainScrollView.addArrangedSubview(reportView)
        reportView.addSubview(reportLabel)
        reportView.addSubview(reportArrowImageView)
        reportView.addSubview(reportButton)
        reportView.addSubview(underlineView3)
        
        stackViewInMainScrollView.addArrangedSubview(otherProductsView)
        otherProductsView.addSubview(otherProductsTitleLabel)
        otherProductsView.addSubview(viewMoreButton)
        otherProductsView.addSubview(otherProductsCollectionView)
        otherProductsView.addSubview(underlineView4)
        
        stackViewInMainScrollView.addArrangedSubview(recommendationView)
        recommendationView.addSubview(recommendationTitle)
        recommendationView.addSubview(recommendationCollectionView)
        recommendationView.addSubview(underlineView5)
        
        addSubview(bottomView)
        bottomView.addSubview(heartButton)
        bottomView.addSubview(line)
        bottomView.addSubview(priceLabel)
        bottomView.addSubview(startChatButton)
        bottomView.addSubview(topline)
        
        mainView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        mainScrollView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.width.equalToSuperview()
        }
        
        productImagesScrollView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(mainView)
        }
        
        stackViewInMainScrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.width.equalToSuperview()
            make.top.equalTo(10)
        }
        
        // 유저 프로필 정보 뷰
        userInfoView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(15)
            make.width.height.equalTo(50)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).inset(-10)
            make.top.equalTo(profileImageView.snp.top)
        }
        
        regionLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).inset(-10)
            make.bottom.equalTo(profileImageView.snp.bottom)
        }
        
        profileButton.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        underlineView1.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    
        // 상세 내용 정보 뷰
        productInfoView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        productTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(20)
        }
        
        categoryButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(productTitleLabel.snp.bottom).offset(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryButton.snp.trailing).offset(10)
            make.centerY.equalTo(categoryButton.snp.centerY)
        }
        
        contentTextLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(categoryButton.snp.bottom).offset(10)
        }
        
        countStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(contentTextLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(15)
        }
        
        underlineView2.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        // 신고하기 뷰
        reportView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        reportLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview().inset(20)
        }
        
        reportArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
        
        reportButton.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        underlineView3.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    
        // 다른 판매 상품 뷰
        otherProductsView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        otherProductsTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(20)
        }
        
        viewMoreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalTo(otherProductsTitleLabel.snp.centerY)
        }
        
        otherProductsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(otherProductsTitleLabel.snp.bottom)
            make.height.equalTo(100)
        }
        
        underlineView4.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // 추천 상품 뷰
        recommendationView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        recommendationTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(20)
        }
        
        recommendationCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(recommendationTitle.snp.bottom)
            make.height.equalTo(10)
        }
        
        underlineView5.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(stackViewInMainScrollView.snp.top)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        heartButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(20)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        line.snp.makeConstraints { make in
            make.leading.equalTo(heartButton.snp.trailing)
            make.top.equalTo(heartButton.snp.top)
            make.bottom.equalTo(heartButton.snp.bottom)
            make.width.equalTo(1)
            make.height.equalTo(heartButton.snp.height)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(line.snp.trailing).offset(15)
            make.center.equalTo(startChatButton.snp.center)
            //make.top.equalTo(line.snp.top).offset(-5)
        }
        
        startChatButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.width.equalTo(100)
            make.height.equalTo(heartButton.snp.height)
            make.centerY.equalTo(heartButton.snp.centerY)
        }
        
        topline.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
