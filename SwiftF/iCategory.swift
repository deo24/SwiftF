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
    
    open var mIsWillAppear:Bool{
        set(b){
            willChangeValue(forKey: kIsWillAppear)
            objc_setAssociatedObject(self, &kIsWillAppear, b, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kIsWillAppear)
        }
        
        get{
            return (objc_getAssociatedObject(self, &kIsWillAppear) as? Bool) ?? true
        }
    }

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
    
    @objc open var mSem:DispatchSemaphore{
        set(sem){
            willChangeValue(forKey: kSemaphore)
            objc_setAssociatedObject(self, &kSemaphore, sem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: kSemaphore)
        }
        
        get{
            return objc_getAssociatedObject(self, &kSemaphore) as! DispatchSemaphore
        }
    }
}

//MARK: === Bundle  ===
extension Bundle{
    open var namespace:String{
        return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
    }
}
