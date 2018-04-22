//
//  ViewController.swift
//  ConvertCurrency
//
//  Created by ManTran on 4/22/18.
//  Copyright © 2018 ManTran. All rights reserved.
//

import UIKit
import Alamofire

typealias Dict = [String: Any]

class ViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func handleConvertButton(_ sender: UIButton) {
        if let amount = amountTextField.text {
            if let amountValue = Double(amount) {
                convert(amount: amountValue, from: (fromButton.titleLabel?.text)!, to: (toButton.titleLabel?.text)!)
            }
        }
    }
    
    var currencies: [String] = ["USD", "VND", "EUR"]
    
    var isFromCurrencyButton = false {
        didSet {
            if isFromCurrencyButton {
                fromButton.layer.borderColor = UIColor.red.cgColor
            } else {
                fromButton.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    var isToCurrencyButton = false {
        didSet {
            if isToCurrencyButton {
                toButton.layer.borderColor = UIColor.red.cgColor
            } else {
                toButton.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    @IBAction func handleHideKeyboard(_ sender: UIButton) {
        view.endEditing(true)
    }
    
    @IBAction func handleFromCurrencyButton(_ sender: UIButton) {
        isFromCurrencyButton = true
        isToCurrencyButton = false
    }
    
    @IBAction func handleToCurrencyButton(_ sender: UIButton) {
        isFromCurrencyButton = false
        isToCurrencyButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBorder()
        setupPickerView()
        getCurrencies()
        
        amountTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc private func hideKeyboard(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func setupBorder() {
        amountTextField.layer.borderColor = UIColor.lightGray.cgColor
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.cornerRadius = 5.0
        fromButton.layer.borderColor = UIColor.lightGray.cgColor
        fromButton.layer.borderWidth = 1
        fromButton.layer.cornerRadius = 5.0
        toButton.layer.borderColor = UIColor.lightGray.cgColor
        toButton.layer.borderWidth = 1
        toButton.layer.cornerRadius = 5.0
    }

    private func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    private func showAlert(code: String, msg: String, statusCode: Int, show: String) {
        let alert = UIAlertController(title: "Error", message: show, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func convert(amount: Double, from: String, to: String) {
        Alamofire.request("https://free.currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=y").responseJSON { (response) in
            guard let responseDict = response.value as? Dict else {
                if let err = response.result.error  {
                    if let errCode = response.response?.statusCode {
                        self.showAlert(code: "ERROR_BAD_REQUEST", msg: err.localizedDescription, statusCode: errCode, show: "Cannot connect to db")
                    }
                }
                return
            }
            
            guard let dataDict = responseDict["\(from)_\(to)"] as? Dict else {
                self.showAlert(code: "ERROR_BAD_REQUEST", msg: "", statusCode: 400, show: "Something fail")
                return
            }
            
            guard let rate = dataDict["val"] as? Double else {
                self.showAlert(code: "NOT_FOUNT", msg: "", statusCode: 400, show: "Can not find this rate")
                return
            }
            
            let resValue = rate * amount
            
            self.resultLabel.text = (resValue.format(numberStyle: .currency, groupingSeparator: ".", decimalSeparator: ",")! as NSString).replacingOccurrences(of: "$", with: "")
        }
    }
    
    private func getCurrencies() {
        Alamofire.request("https://free.currencyconverterapi.com/api/v5/currencies").responseJSON { (response) in
            guard let responseDict = response.value as? Dict else {
                if let err = response.result.error  {
                    if let errCode = response.response?.statusCode {
                        self.showAlert(code: "ERROR_BAD_REQUEST", msg: err.localizedDescription, statusCode: errCode, show: "Cannot connect to db")
                    }
                }
                return
            }
            
            guard let dataDict = responseDict["results"] as? Dict else {
                self.showAlert(code: "ERROR_BAD_REQUEST", msg: "", statusCode: 400, show: "Something fail")
                return
            }
            
            self.currencies = (dataDict.keys.map { String($0) }).sorted()
            self.pickerView.reloadAllComponents()
            
        }
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value = currencies[row]
        if isFromCurrencyButton {
            fromButton.setTitle(value, for: .normal)
        }
        
        if isToCurrencyButton {
            toButton.setTitle(value, for: .normal)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isFromCurrencyButton = false
        isToCurrencyButton = false
    }
}

