//
//  beaconListTableViewCell.swift
//  NWM
//
//  Created by Dhruv Patel on 30/06/21.
//

import UIKit

class beaconListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAvg: UILabel!
    @IBOutlet weak var lblMajor: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLbls()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Labels set up
    fileprivate func setUpLbls() {
        lblName.textColor = .darkGray
        lblAvg.textColor = .darkGray
        lblMajor.textColor = .darkGray
        lblDetails.textColor = .darkGray

//        lblName.font = UIFont.semiboldValueFont
//        lblAvg.font = UIFont.semiboldValueFont
//        lblMajor.font = UIFont.semiboldValueFont
//        lblDetails.font = UIFont.semiboldValueFont
    }
    
    func configureCell(data: BeaconListModel) {

        if UserDefaults.standard.bool(forKey: "BeaconList_RSSI_List") && data.details.count > 0 {
            
            var str = "Rssi: \n"
            var str2 = "\n\nIgnored Rssi: \n"
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.timeZone = .current
            
            for index in 1...data.details.count {
                
                let date = Date(timeIntervalSince1970: data.details[index - 1]["Time"] as? Double ?? 0)
                
                let localDate = dateFormatter.string(from: date)
                let rssi = data.details[index - 1]["RSSI"] as? Double ?? 0
//                let MajorRssi = data.MajorRssi
                
                let strRssi = "\(rssi)"
//                if rssi != 0 && Double(abs(rssi)) <= MajorRssi {
                if rssi != 0 {
                    str += " Time: " + localDate + "  " + strRssi + (index == data.details.count ? "" : ", \n")
                } else {
                    str2 += " Time: " + localDate + "  " + strRssi + (index == data.details.count ? "" : ", \n")
                }
            }
            
            self.lblDetails.text = str + str2
            self.lblDetails.isHidden = false
            
        } else {
            self.lblDetails.isHidden = true
        }
        
        self.lblName.text = data.mac
        self.lblAvg.text = "Avg: \(String(format: "%.2f", data.avg))  Count: \(data.count)"
        self.lblMajor.text = "Major: \(data.major)  Minor: \(data.minor)  MajorRssi \(data.MajorRssi)"
    }
}
