//
//  Item.swift
//  RecipeCatalogApp
//
//  Created by IS 543 on 11/18/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
