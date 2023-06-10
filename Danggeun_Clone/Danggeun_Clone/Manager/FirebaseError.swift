//
//  FirebaseError.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/27.
//

import Foundation
import Kingfisher

enum FirebaseError: Error {
    case getDongmyunListError(_ err: Error)
    case emptyDongmyunListError
    
    case getProductError(_ err: Error)
    case emptyProductError
    
    case getProductImageError(_ err: KingfisherError)
    
    case getUserDataError(_ err: Error)
    case emptyUserDataError
    
    case getOtherProductsError(_ err: Error)
    case emptyOtherProductsError
    
    case getTradingOtherProductsError(_ err: Error)
    case emptyTradingOtherProductsError
    
    case getCompletedOtherProductsError(_ err: Error)
    case emptyCompletedOtherProductsError
    
    case addProductError(_ err: Error)
    
    case semiAddproductError(_ err: Error)
    
    case uploadImagesError(_ err: Error)
    
    case updateProductError(_ err: Error)
    
    case likeUserListError(_ err: Error)
    
    case likeUserDeleteProductError(_ err: Error)
    
    case deleteCityInProductError(_ err: Error)
    case deleteMyProductListError(_ err: Error)
    
    case updateProductsCountError(_ err: Error)
    
    case urlError
}
