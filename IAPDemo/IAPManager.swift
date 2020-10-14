//
//  IAPManager.swift
//  IAPDemo
//
//  Created by mac on 2020/10/9.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation
import StoreKit

protocol IAPManagerDelegate {
    func receiveProduct(_ product : SKProduct?)
    func successWithRecipt(_ transactionReceipt : NSData?)
    func failurePurchaseWithError(_ errorDesc : String?)
}


class IAPManager: NSObject ,SKProductsRequestDelegate ,SKPaymentTransactionObserver {
    
    var delegate : IAPManagerDelegate?
    var currentTransaction = SKPaymentTransaction()
    var myProducts =  [SKProduct]()
    static let shared = IAPManager()
    
    // MARK :  请求商品
    func requestProductWithID(_ productId : String) {
        
        if productId.isEmpty {
            return
        }
        
        let requset = SKProductsRequest.init(productIdentifiers: NSSet(object: productId) as! Set<String> )
        requset.delegate = self
        requset.start()
        
        print("正在请求商品信息...")

        
    }
    
    // MARK :  购买商品
    func purchaseProduct(_ skProduct: SKProduct){
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: skProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
        }else {
            print("用户禁止应用内购买")
        }
        
    }
    // MARK :  恢复商品
    func restorePurchase() {
        
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        
    }
    
    // MARK :  结束这笔定单
    
    func finishedTransaction() {
        SKPaymentQueue.default().finishTransaction(self.currentTransaction)
        print("该订单已结束")
    }
    
    
    
    // MARK :  刷新凭证
    func refreshReceipt() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    
    // MARK :  ================ SKRequestDelegate =================
    func requestDidFinish(_ request: SKRequest) {
        
        if request.isKind(of: SKReceiptRefreshRequest.self) {
            let receiptUrl = Bundle.main.appStoreReceiptURL
            let receiptData = NSData.init(contentsOf: receiptUrl!)!
//            self.delegate?.successWithRecipt(receiptData)
        }
        
    }
    
    // MARK : ================ SKProductsRequest Delegate =================
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.isEmpty {
            delegate?.failurePurchaseWithError("无法获取产品信息")
            return
        }
        myProducts = response.products
        delegate?.receiveProduct(myProducts[0])
    }
    
    
    // MARK : ================ SKPaymentTransactionObserver Delegate =================
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print(transactions.count)
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchasing: // 商品添加进列表
                print("商品:被添加进购买列表")
            case .purchased:// 交易成功
                completeTransaction(transaction)
                finishedTransaction()
            case .failed:// 交易失败
                failedTransaction(transaction)
            case .restored: // 已购买过该商品
                restorePurchase()
            case .deferred: // 交易延迟
                break
            @unknown default: break
                
            }
        }
    }
    
    // MARK : Private Method
    
    func completeTransaction(_ transaction : SKPaymentTransaction) {
        
        // MARK :  保存，验证需要
        self.currentTransaction = transaction
        let  receiptUrl = Bundle.main.appStoreReceiptURL
        let receiptData = NSData(contentsOf: receiptUrl!)
        delegate?.successWithRecipt(receiptData)
        
    }
    
    func failedTransaction(_ transaction : SKPaymentTransaction) {
                
        delegate?.failurePurchaseWithError(transaction.error?.localizedDescription)
//        self.currentTransaction = transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
