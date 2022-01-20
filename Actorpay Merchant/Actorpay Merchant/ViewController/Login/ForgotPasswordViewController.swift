//
//  ForgotPasswordViewController.swift
//  Actorpay Merchant
//
//  Created by iMac on 13/12/21.
//

import UIKit
import Alamofire

class ForgotPasswordViewController: UIViewController {
    
    //MARK: - Properties -

    @IBOutlet weak var forgotPasswordView: UIView!
    @IBOutlet weak var forgotPasswordLabelView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
            emailTextField.becomeFirstResponder()
        }
    }
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var emailValidationLbl: UILabel!
    
    //MARK: - Life Cycles -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailErrorView.isHidden = true
        topCorners(bgView: forgotPasswordLabelView, cornerRadius: 10, maskToBounds: true)
        bottomCorner(bgView: buttonView, cornerRadius: 10, maskToBounds: true)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.showAnimate()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Selectors -
    
    // Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton){
        removeAnimate()
        self.dismiss(animated: true, completion: nil)
    }
    
    // Ok Button Action
    @IBAction func okButtonAction(_ sender: UIButton){
        if self.forgotPasswordValidation() {
            emailErrorView.isHidden = true
            self.forgotPasswordApi()
        }
    }
    
    //MARK: - Helper Functions -
    
    // Forgot Password Validation
    func forgotPasswordValidation() -> Bool {
        
        var isValidate = true
        
        if emailTextField.text?.trimmingCharacters(in: .whitespaces).count == 0{
            emailErrorView.isHidden = false
            emailValidationLbl.text = ValidationManager.shared.emptyEmail
            isValidate = false
        } else if !isValidEmail(emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""){
            emailErrorView.isHidden = false
            emailValidationLbl.text = ValidationManager.shared.validEmail
            isValidate = false
        } else {
            emailErrorView.isHidden = true
        }
        
        return isValidate
        
    }
    
    // Show View With Animation
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    // Remove View With Animation
    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished){
                self.view.removeFromSuperview()
            }
        });
    }
    
    // View End Editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.first?.view != forgotPasswordView){
            removeAnimate()
        }
    }
    
}

//MARK: - Extensions -

//MARK: Api call
extension ForgotPasswordViewController {
    
    //Forgot Password Api
    func forgotPasswordApi() {
        let params: Parameters = [
            "emailId": "\(emailTextField.text ?? "")"
        ]
        showLoading()
        APIHelper.forgotPassword(params: params) { (success,response)  in
            if !success {
                dissmissLoader()
                let message = response.message
                self.view.makeToast(message)
            }else {
                dissmissLoader()
                let message = response.message
                myApp.window?.rootViewController?.view.makeToast(message)
                self.removeAnimate()
                self.dismiss(animated: true, completion: nil)
            }
        }

    }
}

//MARK: UITextFieldDelegate Methods

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case emailTextField:
            if emailTextField.text?.trimmingCharacters(in: .whitespaces).count == 0{
                emailErrorView.isHidden = false
                emailValidationLbl.text = ValidationManager.shared.emptyEmail
            } else if !isValidEmail(emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""){
                emailErrorView.isHidden = false
                emailValidationLbl.text = ValidationManager.shared.validEmail
            } else {
                emailErrorView.isHidden = true
            }
        default:
            break
        }
    }
    
}
