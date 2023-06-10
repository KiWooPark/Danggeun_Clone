//
//  LocationModel.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/08.
//

import Foundation

struct NaverCurrentLoationModel: Codable {
    let results: [Result]
    
    struct Result: Codable {
        let region: Region
        
        struct Region: Codable {
            let area1, area2, area3, area4: Area

            struct Area: Codable {
                let name: String
            }
        }
    }
}
