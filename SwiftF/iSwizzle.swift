//
//  iSwizzle.swift
//  DeoFrame
//
//  Created by 杨栋 on 2017/4/21.
//  Copyright © 2017年 杨栋. All rights reserved.
//

import UIKit

public var kMParentViewController      = "_kMParentViewController"
public var kMFromViewController        = "_kMFromViewController"
public var kIsNavigationbarShow        = "_kIsNavigationBarShow"
public var kMIdentifier                = "identifier"
public var kPreferredStatusBarStyle    = "_kPreferredStatusBarStyle"
public var kIsStatusBarHidden          = "_kIsStatusBarHidden"

public let kViewControllerName                 = "viewController_name"
public let kViewControllerAnimation            = "viewController_animation"
public let kViewControllerStatusBarHidden      = "viewController_statusBarHidden"
public let kViewControllerNavigationBarShow    = "viewController_navigationBarShow"
public let kViewControllerArgument             = "viewController_argument"
public let kViewControllerCompletion           = "viewController_completion"


//MARK:协议
protocol RelayoutViewsProtocol {
    func relayoutViews(orientation:UIInterfaceOrientation)
}

protocol OnMessageProtocol {
    func onMessage(obj:Any!,type:Int,arg:Any?)
}

//MARK:===  UIViewController    ===
public let Message_clear_viewController:Int    = 0
public let Message_push_viewController:Int     = 1
public let Message_argument_viewController:Int = 2
public let Message_present_viewController:Int  = 3
public let Message_dismiss_viewController:Int  = 4
public let Message_back_preViewController:Int  = 5
public let Message_pushNIB_viewController:Int  = 6


//协议
extension UIViewController : OnMessageProtocol,RelayoutViewsProtocol{
    
    static open let callSwizzle:Void  = UIViewController.validateISwizzle()
    
    private class func validateISwizzle(){
        iSwizzle(c:self,oriSEL: #selector(getter: prefersStatusBarHidden),newSEL: #selector(iSwizzle_prefersStatusBarHidden));
        iSwizzle(c:self,oriSEL: #selector(getter: preferredStatusBarStyle),newSEL: #selector(iSwizzle_preferredStatusBarStyle));
        iSwizzle(c:self,oriSEL: #selector(getter: shouldAutorotate),newSEL: #selector(iSwizzle_shouldAutorotate));
        
        iSwizzle(c: self, oriSEL: #selector(viewDidLoad), newSEL: #selector(iSwizzle_viewDidLoad))
        iSwizzle(c: self, oriSEL: #selector(viewWillAppear), newSEL: #selector(iSwizzle_viewWillAppear))
        iSwizzle(c: self, oriSEL: #selector(viewDidAppear), newSEL: #selector(iSwizzle_viewDidAppear))
        iSwizzle(c: self, oriSEL: #selector(viewWillDisappear), newSEL: #selector(iSwizzle_viewWillDisappear))
        iSwizzle(c: self, oriSEL: #selector(viewDidDisappear), newSEL: #selector(iSwizzle_viewDidDisappear))
    }
    
    private class func iSwizzle (c:AnyClass,oriSEL:Selector,newSEL:Selector){
        //获取实例方法
        var oriMethod:Method? = class_getInstanceMethod(c, oriSEL)
        let newMethod:Method?
        
        if (oriMethod == nil) {
            //获取静态方法
            oriMethod = class_getClassMethod(c, oriSEL)
            newMethod = class_getClassMethod(c, newSEL)
        }else{
            newMethod = class_getInstanceMethod(c, newSEL)
        }
        
        if (oriMethod == nil || newMethod == nil) {
            return;
        }
        //自身已经有了就添加不成功，直接交换即可
        if(class_addMethod(c, oriSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
            //添加成功一般情况是因为，origSEL本身是在c的父类里。这里添加成功了一个继承方法。
            class_replaceMethod(c, newSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        }else{
            method_exchangeImplementations(oriMethod, newMethod);
        }
    }
    
    @objc private func iSwizzle_viewDidLoad(){
        automaticallyAdjustsScrollViewInsets = false;
    }
    
    @objc private func iSwizzle_viewWillAppear(animated:Bool){
        NotificationCenter.default.addObserver(self, selector: #selector(checkOrientation), name:.UIApplicationDidChangeStatusBarFrame, object: nil)
        self.performSelector(onMainThread: #selector(willAppear), with: nil, waitUntilDone: true)
    }
    
    @objc private func iSwizzle_viewDidAppear(animated:Bool){
        self.performSelector(onMainThread: #selector(didAppear), with: nil, waitUntilDone: true)
    }
    
    @objc private func iSwizzle_viewWillDisappear(animated:Bool){
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidChangeStatusBarFrame, object: nil)
    }
    
    @objc private func iSwizzle_viewDidDisappear(animated:Bool){
        
    }
    
    @objc private func willAppear(){
        
    }
    
    @objc private func didAppear(){
        UIApplication.shared.mIsDidAppear = true
    }
    
    @objc private func checkOrientation(){
        self.relayoutViews(orientation: UIApplication.shared.statusBarOrientation)
    }
    
    @objc private func iSwizzle_prefersStatusBarHidden() -> Bool{
        return self.mIsStatusBarHidden
    }
    
    @objc private func iSwizzle_preferredStatusBarStyle() -> UIStatusBarStyle{
        return self.mPreferredStatusBarStyle
    }
    
    @objc private func iSwizzle_shouldAutorotate() -> Bool{
        return true;
    }
    
    open func relayoutViews(orientation:UIInterfaceOrientation){
        print("")
    }
    
    open func onMessage(obj:Any!,type:Int,arg:Any?){
        guard let parentViewController = self.mParentViewController else {
            assertionFailure("\(object_getClassName(self)) 's parentViewController is nil")
            return
        }
        parentViewController.onMessage(obj: obj, type: type, arg: arg)
    }
}

//关联
extension UIViewController{
    
    @objc open var mParentViewController:UIViewController?{
        set(vc){
            willChangeValue(forKey: kMParentViewController)
            objc_setAssociatedObject(self, &kMParentViewController, vc, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kMParentViewController)
        }
        
        get{
            return objc_getAssociatedObject(self, &kMParentViewController) as? UIViewController
        }
    }
    
    @objc open var mFromViewController:UIViewController?{
        set(vc){
            willChangeValue(forKey: kMFromViewController)
            objc_setAssociatedObject(self, &kMFromViewController, vc, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kMFromViewController)
        }
        
        get{
            return objc_getAssociatedObject(self, &kMFromViewController) as? UIViewController
        }
    }
    
    open var mIsNavigationBarShow:Bool{
        set(b){
            willChangeValue(forKey: kIsNavigationbarShow)
            objc_setAssociatedObject(self, &kIsNavigationbarShow, b, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kIsNavigationbarShow)
        }
        
        get{
            return objc_getAssociatedObject(self, &kIsNavigationbarShow) as? Bool ?? false
        }
    }
    
    open var mPreferredStatusBarStyle:UIStatusBarStyle{
        set(value){
            willChangeValue(forKey: kPreferredStatusBarStyle)
            objc_setAssociatedObject(self, &kPreferredStatusBarStyle, value, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kPreferredStatusBarStyle)
        }
        
        get{
            return objc_getAssociatedObject(self, &kPreferredStatusBarStyle) as? UIStatusBarStyle ?? .lightContent
        }
    }
    
    open var mIsStatusBarHidden:Bool{
        set(b){
            willChangeValue(forKey: kIsStatusBarHidden)
            objc_setAssociatedObject(self, &kIsStatusBarHidden, b, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kIsStatusBarHidden)
        }
        
        get{
            return objc_getAssociatedObject(self, &kIsStatusBarHidden) as? Bool ?? true
        }
    }
}


//MARK: === UIView  ===
var kMParentView = "_kMParentView"

//协议
extension UIView:RelayoutViewsProtocol{
    open func relayoutViews(orientation:UIInterfaceOrientation){
    }
}

//关联
extension UIView {
    @objc open var mParentView:UIView?{
        set(vc){
            willChangeValue(forKey: kMParentView)
            objc_setAssociatedObject(self, &kMParentView, vc, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kMParentView)
        }
        
        get{
            return objc_getAssociatedObject(self, &kMParentView) as? UIView
        }
    }
}

