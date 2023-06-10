//
//  CategoryModel.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/12.
//

import Foundation

struct CategoryModel {
    let categoryName: String
    let placeholeder: String
    var isSelected: Bool
    
    static func configureCategoryList() -> [CategoryModel] {
        return [
            CategoryModel(categoryName: "디지털기기", placeholeder: "모델명, 구성품, 구매 시기, 사용감 (흠집, 파손 여부, 수리 여부) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "생활가전", placeholeder: "구매 시기, 사용감 (흠집, 파손 여부) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "가구/인테리어", placeholeder: "모델명, 구매 시기, 크기  (가로/세로/높이), 사용감 (흠집, 파손 여부) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "생활/주방", placeholeder: "구매 시기, 사용감 (흠집, 파손 여부) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "유아동", placeholeder: "사이즈, 구매 시기, 사용감 (색바램, 얼룩, 뜯어짐) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "유아도서", placeholeder: "권수 (전집의 경우 누락 여부), 사용감 (찢김, 색바램, 낙서) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "여성의류", placeholeder: "구매 시기, 사이즈, 사용감 (색바램, 얼룩, 뜯어짐) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "여성잡화",placeholeder: "구매 시기, 사이즈, 사용감 (색바램, 얼룩, 뜯어짐) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "남성패션/잡화", placeholeder: "구매 시기, 사이즈, 사용감 (색바램, 얼룩, 뜯어짐) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "뷰티/미용", placeholeder: "구매 시기, 제조일자 또는 유통기한, 사용감 (파손 여부) 등\n※ 화장품 샘플은 판매할 수 없어요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "스포츠/레저", placeholeder: "모델명, 구매 시기, 사용감 (흠집, 파손 여부) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "취미/게임/음반", placeholeder: "구매 시기, 사용감 (흠집, 파손 여부, 상세 사진) 등\n※ 게임, OTT 서비스 등의 계정 정보는 공유하거나 판매할 수 없어요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "도서", placeholeder: "권수 (전집의 경우 누락 여부), 사용감 (찢김, 색바램, 낙서) 등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "티켓/교환권", placeholeder: "티켓 정보, 유효기간 등\n※ 사용 안 한 교환권의 바코드가 게시되지 않도록 주의해 주세요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "가공식품", placeholeder: "구매 시기, 유통기한 등\n※ 의약품, 건강기능식품은 관련법에 따라 판매할 수 없어요. 의약품, 건강기능식품 라벨이 제품에 표시되어 있는지 반드시 확인해주세요.\n※ 직접 만든 수제식품은 판매할 수 없어요.\n※ 유통기한이 지나거나 개봉한 식품은 판매할 수 없어요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "반려동물용품", placeholeder: "구매 시기, 사용감 (흠집, 파손 여부)등\n※ 생명이 있는 모든 동물・곤충(무료분양, 열대어 포함)은 판매할 수 없어요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "식물", placeholeder: "품종, 크기, 키우는 방법 등\n\n※ 삽수, 어린묘목 등은 종자산업법에 따라 판매할 수 없어요.\n※ 반려동물, 생명이 있는 모든 동물・곤충(무료분양, 열대어 포함)은 판매할 수 없어요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "기타 중고물품", placeholeder: "구매 시기, 사용감 (흠집, 파손 여부)등\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false),
            CategoryModel(categoryName: "삽니다", placeholeder: "제품명, 브랜드 등 자세하게 적을수록 좋아요.\n\n신뢰할 수 있는 거래를 위해 자세한 정보를 제공해주세요. 과학기술정보통신부, 한국인터넷진흥원과 함께 해요.\n", isSelected: false)
        ]
    }
}
