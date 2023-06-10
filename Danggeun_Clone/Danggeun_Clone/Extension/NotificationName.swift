//
//  File.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/12.
//

import Foundation

extension Notification.Name {
    static let reloadProductListTableView = Notification.Name("reloadProductListTableView")
    
    static let reloadMainViewProducts = Notification.Name("reloadMainViewProducts")
    
    static let updateProductsCount = Notification.Name("updateProductsCount")
    static let updateCompletedProduct = Notification.Name("updateCompletedProduct")
    static let updateTradingProduct = Notification.Name("updateTradingProduct")
    static let updateHiddenProduct = Notification.Name("updateHiddenProduct")
    
}
