//
//  ViewController.swift
//  IAPDemo
//
//  Created by mac on 2020/10/9.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController ,IAPManagerDelegate {

    static let productId = ""
    static let url_verify_test = "https://sandbox.itunes.apple.com/verifyReceipt"
    static let url_verify = "https://buy.itunes.apple.com/verifyReceipt"


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        self.view.addSubview(btn)
        btn.setTitle("刷新凭证", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(refreshBtnClick), for: .touchUpInside)
        IAPManager.shared.delegate = self
        self.view.backgroundColor = UIColor.white
        
    }
    
    // MARK :  Actions
    @objc  func refreshBtnClick() {
        
        IAPManager.shared.refreshReceipt()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // MARK :  判断是否有未完成的订单
        let transaction = SKPaymentQueue.default().transactions
        if !transaction.isEmpty {
            print("有未完成订单")
            for transt in transaction {
                if transt.transactionState == SKPaymentTransactionState.purchased {
                    SKPaymentQueue.default().finishTransaction(transt)
                }
            }
        }
        IAPManager.shared.requestProductWithID(ViewController.productId)

    }
    

    // MARK :  IAPDelegate
    // MARK :  接收到产品信息
    func receiveProduct(_ product: SKProduct?) {
        print("请求到产品")
        if product != nil {
            IAPManager.shared.purchaseProduct(product!)
        }else {
            print("无法连接iTunes Store!")
        }
    }
    
    func successWithRecipt(_ transactionReceipt: NSData?) {
        
        
        let transactionReceiptStr = transactionReceipt?.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
        if transactionReceiptStr != nil {
            verfyIAPurchase()
        }
    }
    
    // MARK :  购买失败
    func failurePurchaseWithError(_ errorDesc: String?) {
        print(errorDesc!.description)
    }
    // MARK :  验证
    func verfyIAPurchase() {
        print("购买成功---验证")
        // MARK : 从沙盒中获取交易凭据
        let receiptUrl = Bundle.main.appStoreReceiptURL
        let receiptData = NSData(contentsOf: receiptUrl!)
        let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        // MARK :  拼接请求数据
        let bodyStr = "{\"receipt-data\" : \"\(String(describing: receiptString!))\"}"
        let bodyData = bodyStr.data(using: .utf8)!
        let session : URLSession = URLSession.shared
        let url = URL(string: ViewController.url_verify_test)
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = bodyData

        
        let dataTask : URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            do {
                let dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                
                let receiptDic = dict["receipt"] as! [String:Any]
                let inApp = receiptDic["in_app"] as! [[String:Any]]
                let transaction_id = inApp.last!["transaction_id"] as! String
                let transaction_id2 = IAPManager.shared.currentTransaction.transactionIdentifier!
                print(transaction_id,transaction_id2)
                // MARK : 验证
                if transaction_id == transaction_id2 {
                    print("验证成功")
                }else {
                    print("验证失败")
                }
 
            } catch {}
        }
        dataTask.resume()
    }
    

}

