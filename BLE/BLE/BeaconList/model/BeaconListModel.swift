//
//  BeaconListModel.swift
//  NWM
//
//  Created by Dhruv Patel on 30/06/21.
//

import Foundation


class BeaconListModel: NSObject {

    var mac: String
    var avg: Double
    var count: String
    var major: String
    var minor: String
    var MajorRssi: String
    var details : [[String:Any]]
    
    enum Keys: String {
        case mac = "mac"
        case avg = "avg"
        case count = "count"
        case major = "major"
        case minor = "minor"
        case MajorRssi = "MajorRssi"
        case details = "extraDetails"
    }

    init(dict: [String : Any]) {
        mac = dict[Keys.mac.rawValue] as? String ?? ""
        avg = dict[Keys.avg.rawValue] as? Double ?? 0
        count = String(dict[Keys.count.rawValue] as? Int ?? 0)
        major = dict[Keys.major.rawValue] as? String ?? ""
        minor = dict[Keys.minor.rawValue] as? String ?? ""
        MajorRssi = String(dict[Keys.MajorRssi.rawValue] as? Double ?? 0)
        details = dict[Keys.details.rawValue] as? [[String:Any]] ?? [[String:Any]]()
        super.init()
    }
}

