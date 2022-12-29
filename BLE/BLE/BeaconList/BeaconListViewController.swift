//
//  BeaconListViewController.swift
//  NWM
//
//  Created by Dhruv Patel on 30/06/21.
//

import UIKit

class BeaconListViewController: UIViewController {
    
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var lblNearestBeacon: UILabel!
    
    fileprivate var delegateDataSource: BeaconTblViewDelegateDataSource!
    let blueToothManager = LocationBeaconManger.Shared
    
    var array : [BeaconListModel] = [] //filtered with selected year and search string
    var arrNo = ["1","2","3","4","5","6","7"]
    var isFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.title = "Beacon List"
        setUpTblView()
        addObserver()
        
        let btnSwitch = UISwitch()
        btnSwitch.addTarget(self, action: #selector(self.btnSwitchValueUpdate(sender:)), for: .valueChanged)
        btnSwitch.isOn = UserDefaults.standard.bool(forKey: "BeaconList_SortingOrderListUsingAvg")
        btnSwitch.tintColor = .lightGray
        btnSwitch.layer.cornerRadius = btnSwitch.frame.height / 2.0
        btnSwitch.backgroundColor = .lightGray
        btnSwitch.clipsToBounds = true
        
        let btnSwitchRSSI = UISwitch()
        btnSwitchRSSI.addTarget(self, action: #selector(self.btnSwitchValueUpdateForRSSI(sender:)), for: .valueChanged)
        btnSwitchRSSI.isOn = UserDefaults.standard.bool(forKey: "BeaconList_RSSI_List")
        btnSwitchRSSI.tintColor = .lightGray
        btnSwitchRSSI.layer.cornerRadius = btnSwitchRSSI.frame.height / 2.0
        btnSwitchRSSI.backgroundColor = .lightGray
        btnSwitchRSSI.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [btnSwitchRSSI, btnSwitch])
            stackView.spacing = 16
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
        
        self.blueToothManager.startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObserver()
        self.blueToothManager.stopScanning()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateList(_:)), name: Notification.Name("Update_Beacon_List"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BeaconChanged(_:)), name: Notification.Name("Update_Nearest_Beacon"), object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Update_Beacon_List"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Update_Nearest_Beacon"), object: nil)
    }
    
    @objc func btnSwitchValueUpdate(sender : UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "BeaconList_SortingOrderListUsingAvg")
    }
    
    @objc func btnSwitchValueUpdateForRSSI(sender : UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "BeaconList_RSSI_List")
    }
    
    func setUpTblView() {
        
        let dictavg = LocationBeaconManger.Shared.dictAvgRssi
        let dictMajor = LocationBeaconManger.Shared.dictMajor
        let dictcount = LocationBeaconManger.Shared.dictCount
        let dictMajorRssi = LocationBeaconManger.Shared.dictMajorRssi
        let dicFilteredRssi = LocationBeaconManger.Shared.dicFilteredRssiTemp
        
        var arrData = [[String : Any]]()
        for (key, _) in dicFilteredRssi {
            var dict = [String : Any]()
            dict["mac"] = key
            dict["avg"] = dictavg[key]
            dict["count"] = dictcount[key]
            dict["major"] = dictMajor[key]
            dict["MajorRssi"] = dictMajorRssi[key]
            dict["minor"] = key
            
            if UserDefaults.standard.bool(forKey: "BeaconList_RSSI_List") {
                dict["extraDetails"] = (dicFilteredRssi[key] as? [[String:Any]] ?? [])
            }
            
            arrData.append(dict)
        }
        
        array = arrData.map({BeaconListModel(dict: $0)})
        if UserDefaults.standard.bool(forKey: "BeaconList_SortingOrderListUsingAvg") {
            array.sort { $0.avg > $1.avg }
        } else {
            array.sort { (Int($0.mac) ?? 0) < (Int($1.mac) ?? 0) }
        }

        if (delegateDataSource == nil) {
            delegateDataSource = BeaconTblViewDelegateDataSource(arrData: array, tbl: tblview)
        } else {
            delegateDataSource.reloadData(arrData: array)
        }
    }
    
    @objc private func UpdateList(_ noti: Notification) {
        setUpTblView()
    }
    
    @objc private func BeaconChanged(_ noti: Notification) {
        self.lblNearestBeacon.text = "Nearest Beacon : " + beaconMacAddress
    }
}
