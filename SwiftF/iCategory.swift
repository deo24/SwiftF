//
//  iCategory.swift
//  DeoFrame
//
//  Created by 杨栋 on 2017/4/21.
//  Copyright © 2017年 杨栋. All rights reserved.
//

import UIKit

var kIsWillAppear   = "_kIsWillAppear"
var kIsDidAppear    = "_kIsDidAppear"
var kSemaphore      = "_kSemaphore"

extension UIApplication{
    
    open var mIsDidAppear:Bool{
        set(b){
            willChangeValue(forKey: kIsDidAppear)
            objc_setAssociatedObject(self, &kIsDidAppear, b, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kIsDidAppear)
        }
        
        get{
            return (objc_getAssociatedObject(self, &kIsDidAppear) as? Bool) ?? true
        }
    }
}

//MARK: === Bundle  ===
extension Bundle{
    open var namespace:String{
        return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
    }
}

