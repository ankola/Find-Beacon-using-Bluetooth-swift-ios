//
//  LocationBeaconManger.swift
//  BeaconDemo
//
//  Created by Savan Ankola on 26/04/22.
//

import Foundation
import CoreBluetooth
import UIKit

var beaconMacAddress = ""

final class LocationBeaconManger: NSObject {
    
    // MARK: - Variables
    //Private
    var centralManager = CBCentralManager()
    var centralManagerQueue: DispatchQueue?
    
    // SERVICES
    private let SERVICE_DEVICE_INFORMATION = CBUUID(string: "180A")
    private let SERVICE_HEART_RATE = CBUUID(string: "180D")
    private let SERVICE_BATTERY = CBUUID(string: "180F")
    
    private let kEddystoneUIDFrameTypeID: UInt8 = 0x00
    private let kEddystoneURLFrameTypeID: UInt8 = 0x10
    private let kEddystoneTLMFrameTypeID: UInt8 = 0x20
    private let kEddystoneEIDFrameTypeID: UInt8 = 0x30
    
    static let Shared = LocationBeaconManger()
    fileprivate var timerStart: Timer!
    
    var dictRssi = [String:Any]()
    var dictMajorRssi = [String:Double]()
    var dictAvgRssi = [String:Double]()
    var dictAvgDistance = [String:Double]()
    var dictCount = [String:Int]()
    var dictMajor = [String:String]()
    var dictIdealCount = [String:Int]()
    var staticBeaconIdealCount = 3
    var dicFilteredRssi = [String:Any]()
    var arrMinorIds = [String]()
    var dicFilteredRssiTemp = [String:Any]()
    
    private override init() {}
    
    func startScan() {
        centralManagerQueue = DispatchQueue(label: "moko.com.centralManager")
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
//        centralManager = CBCentralManager(delegate: self, queue: .main, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        self.startTimer()
    }
    
    func stopScanning() {
        self.stopTimer()
        centralManager.stopScan()
    }
    
    //MARK: Start Timer
    private func startTimer() {
        if timerStart == nil {
            timerStart = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerActionStart), userInfo: nil, repeats: true)
            RunLoop.current.add(timerStart, forMode: .common)
        }
    }
    
    private func stopTimer() {
        if timerStart != nil {
            timerStart?.invalidate()
            timerStart = nil
        }
    }
}

//MARK RSSI
extension LocationBeaconManger {
    //MARK: Set Dictionary RSSI
    private func setDictWithRSSI(Minor: String, Rssi: Double, Distance:Double, majorRssi:Double, idealCount: Int, major:String) {
                
        if var tempArray = dictRssi[Minor] as? [[String : Any]] {
//            if Double(abs(Rssi)) <= majorRssi && Rssi != 0 {
            if Rssi != 0 {
                let currentDate = Date().timeIntervalSince1970
                var tempdata = [String: Any]()
                tempdata["RSSI"] = Rssi
                tempdata["Time"] = currentDate
                tempdata["Distance"] = Distance
                tempArray.append(tempdata)
                dictRssi[Minor] = tempArray
            }
            dictMajorRssi[Minor] = majorRssi
            dictMajor[Minor] = major
            dictIdealCount[Minor] = idealCount
            
        } else {
//            if Double(abs(Rssi)) <= majorRssi && Rssi != 0 {
            if Rssi != 0 {
                var tempdata = [String: Any]()
                tempdata["RSSI"] = Rssi
                tempdata["Time"] = Date().timeIntervalSince1970
                tempdata["Distance"] = Distance
                var temparray = [Any]()
                temparray.append(tempdata)
                dictRssi[Minor] = temparray
            }
            dictMajorRssi[Minor] = majorRssi
            dictMajor[Minor] = major
            dictIdealCount[Minor] = idealCount
        }
    }
    
    @objc func timerActionStart() {
        self.setupDictFilterData()
        NotificationCenter.default.post(name: Notification.Name("Update_Beacon_List"), object: nil)//BeaconList Update
        
        if !dictRssi.isEmpty {
            if dictAvgRssi.keys.count > 0 {
                let tempNearest = findNearest(dict: dictAvgRssi)
//                print("beacon found - ", tempNearest)
                if beaconMacAddress != tempNearest {
                    beaconMacAddress = tempNearest
                    NotificationCenter.default.post(name: Notification.Name("Update_Nearest_Beacon"), object: tempNearest)
                    if let beaconMajor = dictMajorRssi[tempNearest] {
                        if let tempAvgRssi = dictAvgRssi[tempNearest] {
                            if abs(tempAvgRssi) <= beaconMajor {
                                beaconMacAddress = tempNearest
//                                let res = beaconGroupIds.contains(tempNearest)
//                                self.ManageViews(isSameGroupBeacon: res)
                            }
                        }
                    }
                }
            } else {
                beaconMacAddress = ""
                print("beacon not found")
                NotificationCenter.default.post(name: Notification.Name("Update_Nearest_Beacon"), object: "")
            }
        }
    }
            
    //MARK: Set Avarage Dictionary RSSI
    private func setupDictFilterData() {
        dictAvgRssi.removeAll()
        var tempdicFilteredRssi = [String:Any]()
        
        let newDic = self.dicFilteredRssi
        self.dicFilteredRssi.removeAll()
        let currentDate = Date().timeIntervalSince1970
        var tempDictRssi = [String:Any]()
        
        for (key, value) in newDic {
            if let tempArray2 = value as? [[String : Any]] {
                
                let tempArray = dictRssi[key] as? [[String : Any]] ?? []
                var tempNewArray = [[String : Any]]()
//                guard let idealCount = dictIdealCount[key] else { return }

//                if tempArray.count >= idealCount {
                    tempNewArray = tempArray.filter({ (currentDate - ($0["Time"] as! TimeInterval)) < 6 })
                    tempdicFilteredRssi[key] = tempArray2.filter({ (currentDate - ($0["Time"] as! TimeInterval)) < 6 })

//                } else {
//                    tempNewArray = tempArray.filter({ (currentDate - ($0["Time"] as! TimeInterval)) < 12 })
//                    tempdicFilteredRssi[key] = tempArray2.filter({ (currentDate - ($0["Time"] as! TimeInterval)) < 12 })
//                }
                
                dictCount[key] = tempNewArray.count
                if tempNewArray.count != 0 {
                    tempDictRssi[key] = tempNewArray
                    setupAvarage(mac: key, array: tempNewArray)
                }
            }
        }
        dictRssi = tempDictRssi
        self.dicFilteredRssi = tempdicFilteredRssi
        self.dicFilteredRssiTemp = tempdicFilteredRssi
    }

    private func setupAvarage(mac: String, array:[[String:Any]]) {
        let avrRSSI = array.map({ $0["RSSI"] as! Double }).reduce(0, +) / Double(array.count)
        dictAvgRssi[mac] = avrRSSI
        let avgDistance = array.map({ $0["Distance"] as! Double }).reduce(0, +)/Double(array.count)
        dictAvgDistance[mac] = avgDistance
    }
        
    //MARK: Find Nearest Device With AvarageRSSI
    private func findNearest(dict: [String:Double]) -> String{
        var smallest = -1000000.0
        var smallestkey = ""
//        var tempstring = ""
        for (key, value) in dict {
            let idealCount = dictIdealCount[key] ?? staticBeaconIdealCount
            if let keycount =  dictCount[key], keycount >= idealCount {
                if value > smallest {
                    smallest = value
                    smallestkey = key
                }
            }
//            if let temparry = dictRssi[key] as? [[String : Any]]{
//                tempstring = tempstring + "\(key) \(value), count:- \(temparry.count)\n"
//            }
        }
        return smallestkey
    }
}

//MARK:- ----- CB Central Manager Delegate -----
extension LocationBeaconManger : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "FEAA"), CBUUID(string: "FEAB")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
//            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

        @unknown default:
            print("@unknown default")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if advertisementData.count > 0 {
            
            guard let advDic = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]/*,let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, localName == "UFO" */else {
    //            print(advertisementData[CBAdvertisementDataLocalNameKey] as? String,"else")
                return
            }
            
            let tXpower = advertisementData["kCBAdvDataTxPowerLevel"] as? Int ?? 0
                    
            for key in advDic.keys {
                if key == CBUUID(string: "FEAA"),  let feaaData : Data = advDic[CBUUID(string: "FEAA")] {
                    if feaaData.count > 0 {
                        self.fetchBaseBeacon(advData: feaaData, tXpower: tXpower, rssi: Double(truncating: RSSI))
                    }
                } else if key == CBUUID(string: "FEAB"),  let feaaData : Data = advDic[CBUUID(string: "FEAB")] {
                    if feaaData.count > 0 {
                        self.fetchBaseBeacon(advData: feaaData, tXpower: tXpower, rssi: Double(truncating: RSSI))
                    }
                }
            }
        }
    }
        
    func fetchBaseBeacon(advData: Data, tXpower : Int, rssi : Double) {
//        let frameType = self.fetchrameType(advData)
//        let bytes = advData.withUnsafeBytes { $0.load(as: UInt32.self) }
        
        let type = self.fetchrameType(advData)
        
        if type == .mkbxpBeaconFrameType {
            let content = hexStringFromData(advData: advData)
//            let temp = content.dropFirst(4).dropLast(4)
//            let temp1 = temp.dropFirst(2).prefix(8)
//            let temp2 = temp.dropFirst(10).prefix(4)
//            let temp3 = temp.dropFirst(14).prefix(4)
//            let temp4 = temp.dropFirst(18).prefix(4)
//            let temp5 = temp.dropFirst(22).prefix(12)

//            let uuid = [temp1, "-", temp2, "-", temp3, "-", temp4, "-", temp5].joined().uppercased()
            
            let minor = Int(content.dropFirst(42).prefix(8), radix: 16) ?? 0
            let major = Int(content.dropFirst(38).prefix(4), radix: 16) ?? 0
                        
//            print("\nUUID - ", uuid, "\ntXpower - ", tXpower, "\nRssi - ", rssi, "\nMinor - ", minor, "\nMajor - ", major, "\n")
            
            var str_Major_Rssi = Double("\(major)".prefix(2)) ?? 96
            str_Major_Rssi = (str_Major_Rssi > 1) ? str_Major_Rssi : 96
            
            let dic = ["Time" : Date().timeIntervalSince1970, "RSSI" : rssi] as [String : Any]
            var dicBeacon = self.dicFilteredRssi["\(minor)"] as? [[String : Any]] ?? []
            dicBeacon.insert(dic, at: 0)
            self.dicFilteredRssi["\(minor)"] = dicBeacon
                     
            let str_Minor = "\(minor)"
            var idealCount = Int("\(major)".suffix(1)) ?? self.staticBeaconIdealCount
            idealCount = (idealCount > 0) ? idealCount : self.staticBeaconIdealCount
            self.setDictWithRSSI(Minor: str_Minor, Rssi: rssi, Distance: 0, majorRssi: str_Major_Rssi, idealCount: idealCount, major: "\(major)")
        }
    }
    
    func hexStringFromData(advData : Data) -> String {
        var hexStr = ""
        for i in 0..<advData.count {
            let newHexStr = String(format: "%x", advData[i] & 0xff) ///16进制数
            if newHexStr.count == 1 {
                hexStr = "\(hexStr)0\(newHexStr)"
            } else {
                hexStr = "\(hexStr)\(newHexStr)"
            }
        }
        return hexStr
    }
    
    func fetchrameType(_ frameData: Data) -> MKBXPDataFrameType {
        var frameType: UInt8
        if (frameData.count > 1) {
            frameType = [UInt8](frameData)[0]
            switch frameType {
            case 0x00:
                return  .mkbxpuidFrameType
            case 0x10:
                return .mkbxpurlFrameType
            case 0x20:
                return .mkbxptlmFrameType
            case 0x40:
                return .mkbxpDeviceInfoFrameType
            case 0x50:
                return .mkbxpBeaconFrameType
            case 0x60:
                return .mkbxpThreeASensorFrameType
            case 0x70:
                return .mkbxpthSensorFrameType
            default:
                return .mkbxpUnknownFrameType
            }
        }
        return .mkbxpUnknownFrameType
    }
}

enum MKBXPDataFrameType : Int {
    case mkbxpuidFrameType
    case mkbxpurlFrameType
    case mkbxptlmFrameType
    case mkbxpDeviceInfoFrameType
    case mkbxpBeaconFrameType
    case mkbxpThreeASensorFrameType
    case mkbxpthSensorFrameType
    case mkbxpnodataFrameType
    case mkbxpUnknownFrameType
}
