//
//  RoleViewController.swift
//  Actorpay Merchant
//
//  Created by iMac on 28/01/22.
//

import UIKit
import Alamofire
import PopupDialog

class RoleViewController: UIViewController {
    
    //MARK: - Properties -
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tblView: UITableView! {
        didSet {
            self.tblView.delegate = self
            self.tblView.dataSource = self
        }
    }
    
    var roleId: String?
    
    //MARK: - Life Cycles -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblView.addPullToRefresh {
            roleListPage = 0
            NotificationCenter.default.post(name: Notification.Name("reloadRoleListApi"), object: self)
        }
        topCorner(bgView: bgView, maskToBounds: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reloadRoleListTblView"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.reloadRoleListTblView),name:Notification.Name("reloadRoleListTblView"), object: nil)
    }
    
    //MARK: - Selectors -
    
    //Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Add New Role Button Action
    @IBAction func addNewRoleBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewRoleViewController") as! AddNewRoleViewController
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    //MARK: - Helper Functions -
    
    // Reload Role List Data
    @objc func reloadRoleListTblView() {
        self.tblView.reloadData()
    }
    
}

//MARK: - Extensions -

//MARK: Api Call
extension RoleViewController {
    
    // Delete Role By Id Api
    func deleteRoleByIdApi(RoleId: String) {
        let bodyParams: Parameters = [
            "ids": [
                RoleId
            ]
        ]
        
        showLoading()
        APIHelper.deleteRoleByIdApi(params: [:], bodyParameter: bodyParams) { (success, response) in
            self.tblView.pullToRefreshView?.stopAnimating()
            if !success {
                dissmissLoader()
                let message = response.message
                self.view.makeToast(message)
            }else {
                dissmissLoader()
                let message = response.message
                print(message)
                self.view.makeToast(message)
                roleListPage = 0
                NotificationCenter.default.post(name: Notification.Name("reloadRoleListApi"), object: self)
            }
        }
    }
    
}

//MARK: Table View Setup
extension RoleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if roleItems.count == 0{
            tableView.setEmptyMessage("No Role Found")
        } else {
            tableView.restore()
        }
        return roleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoleDetailsTableViewCell", for: indexPath) as! RoleDetailsTableViewCell
        let item = roleItems[indexPath.row]
        cell.item = item
        cell.deleteButtonHandler = {
            self.roleId = item.id
            let customV = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertViewController") as! CustomAlertViewController
            let popup = PopupDialog(viewController: customV, buttonAlignment: .horizontal, transitionStyle: .bounceUp, tapGestureDismissal: true)
            customV.setUpCustomAlert(titleStr: "Delete Role", descriptionStr: "Are you sure want to delete?", isShowCancelBtn: false)
            customV.customAlertDelegate = self
            self.present(popup, animated: true, completion: nil)
        }
        cell.editButtonHandler = {
            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewRoleViewController") as! AddNewRoleViewController
            newVC.isUpdateRole = true
            newVC.roleId = item.id
            self.navigationController?.pushViewController(newVC, animated: true)
        }
        return cell
    }
    
}

// MARK: ScrollView Setup
extension RoleViewController: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let totalRecords = roleList?.items?.count ?? 0
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 && totalRecords < roleListTotalCount {
            if roleListPage < ((roleList?.totalPages ?? 0)-1) {
                roleListPage += 1
                NotificationCenter.default.post(name: Notification.Name("reloadRoleListApi"), object: self)
            }
        }
    }
    
}

// MARK: Custom Alert Delegate Methods
extension RoleViewController: CustomAlertDelegate {
    
    func okButtonclick(tag: Int) {
        self.deleteRoleByIdApi(RoleId: self.roleId ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
