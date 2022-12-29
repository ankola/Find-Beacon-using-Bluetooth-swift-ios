//
//  ViewController.swift
//  BLE
//
//  Created by Savan Ankola on 26/09/22.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func TapOnStartBtn(_ sender: UIButton) {
        let dvc = BeaconListViewController.instantiate(appStoryboard: .BeaconList)
        self.navigationController?.pushViewController(dvc, animated: true)
//        let vc = UIStoryboard.init(name: "BeaconList", bundle: nil).instantiateViewController(withIdentifier: "BeaconListViewController")
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension UIViewController {
    class func instantiate(appStoryboard: AppStoryboard) -> Self {
        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: Self.self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}

enum AppStoryboard: String {
    case BeaconList = "BeaconList"
}
