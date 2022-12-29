//
//  BeaconTblViewDelegateDataSource.swift
//  NWM
//
//  Created by Dhruv Patel on 30/06/21.
//

import UIKit

class BeaconTblViewDelegateDataSource: NSObject {
    
    //MARK:- Variables
    //Private
    fileprivate var arrSource: [BeaconListModel]
    fileprivate let tblView: UITableView
    
    //MARK:- Initializer
    init(arrData: [BeaconListModel], tbl: UITableView) {
        arrSource = arrData
        tblView = tbl
        super.init()
        setUp()
    }
    
    //MARK:- Private Methods
    fileprivate func setUp() {
        setUpColView()
    }
    
    fileprivate func setUpColView() {
        registerCell()
        tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        tblView.dataSource = self
    }
    
    fileprivate func registerCell() {
        tblView.register(UINib(nibName: "beaconListTableViewCell", bundle: nil), forCellReuseIdentifier: "beaconListTableViewCell")
    }
    
    //MARK:- Public Methods
    func reloadData(arrData: [BeaconListModel]) {
        arrSource = arrData
        tblView.reloadData()
    }
}

//MARK:- UITableViewDataSource Methods
extension BeaconTblViewDelegateDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : beaconListTableViewCell?
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "beaconListTableViewCell", for: indexPath) as? beaconListTableViewCell
        }
        cell!.configureCell(data: arrSource[indexPath.row])
        return cell!
    }
}
