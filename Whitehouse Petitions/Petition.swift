//
//  Petition.swift
//  Whitehouse Petitions
//
//  Created by Melis Yazıcı on 22.10.22.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
