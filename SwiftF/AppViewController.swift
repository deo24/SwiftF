//
//  AppViewController.swift
//  DeoFrame
//
//  Created by 杨栋 on 2017/4/21.
//  Copyright © 2017年 杨栋. All rights reserved.
//

open class AppViewController: UIViewController{
    
    override open func onMessage(obj: Any!, type: Int, arg: Any?) {
        switch (type) {
            
        case Message_push_viewController:
            guard let dic = (arg as? Dictionary<String, Any>),
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            
            for vc in navigationController.viewControllers {
                let className_new = NSStringFromClass(cls_new)
                if let vc_new = vc.findVC(name: className_new) {
                    if vc_new.parent != nil {
                        navigationController.popToViewController(vc_new.parent!, animated: bIs)
                    }else{
                        navigationController.popToViewController(vc_new, animated: bIs)
                    }
                    return
                }
            }
            
//            for index in 0..<navigationController.viewControllers.count{
//                let vc_old = navigationController.viewControllers[index]
//                let className_old = NSStringFromClass(vc_old.classForCoder)
//                let className_new = NSStringFromClass(cls_new)
//                if (className_new as NSString).isEqual(to: className_old) {
//                    navigationController.popToViewController(vc_old, animated: bIs)
//                    return
//                }
//            }
            
            let aviewController = cls_new.init()
            print(aviewController.view)
            aviewController.mParentViewController = self
            aviewController.mIsStatusBarHidden = (dic[kViewControllerStatusBarHidden] as? Bool) ?? false
            aviewController.mIsNavigationBarShow = (dic[kViewControllerNavigationBarShow] as? Bool) ?? false
            aviewController.mFromViewController = obj as? UIViewController
            navigationController.pushViewController(aviewController, animated: bIs)
            
        case Message_argument_viewController:
            guard   let dic = (arg as? Dictionary<String, Any>),
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            
            let className_new = NSStringFromClass(cls_new)
            let completion = { (vc:UIViewController)->Void in
                vc.onMessage(obj: obj, type: type, arg: dic[kViewControllerArgument])
            }
            
            if  let presentedViewController = navigationController.presentedViewController,
                className_new == NSStringFromClass(presentedViewController.classForCoder) {
                completion(presentedViewController)
            }else {
                for vc in navigationController.viewControllers {
                    if let vc_new = vc.findVC(name: className_new) {
                        completion(vc_new)
                        break
                    }
                }
            }
            
        case Message_present_viewController:
            guard   let dic = (arg as? Dictionary<String, Any>),
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            let completion = dic[kViewControllerCompletion] as? ()->()
            
            let aviewController = cls_new.init()
            print(aviewController.view)
            aviewController.mParentViewController = self
            aviewController.mFromViewController = obj as? UIViewController
            aviewController.mIsStatusBarHidden = (dic[kViewControllerStatusBarHidden] as? Bool) ?? false
            aviewController.mIsNavigationBarShow = (dic[kViewControllerNavigationBarShow] as? Bool) ?? false
            navigationController.present(aviewController, animated: bIs, completion: completion)
            
        case Message_dismiss_viewController:
            guard   let dic = (arg as? Dictionary<String, Any>),
                let navigationController = navigationController
                else {
                    return
            }
            
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            let completion = dic[kViewControllerCompletion] as? ()->()
            navigationController.dismiss(animated: bIs, completion: completion)
            
        case Message_back_preViewController:
            guard   let dic = (arg as? Dictionary<String, Any>),
                let navigationController = navigationController else{
                    return
            }
            
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            let arr:[UIViewController] = navigationController.viewControllers
            if arr.count>1 {
                let preController = arr[arr.count-2]
                navigationController.popToViewController(preController, animated: bIs)
            }
            
        default:
            break
        }
    }
}

extension UIViewController {
    func findVC(name:String) -> UIViewController?{
        guard name == NSStringFromClass(self.classForCoder) else{
            for child in childViewControllers {
                let childName = NSStringFromClass(child.classForCoder)
                if childName == name {
                    return child
                }else {
                    if let temp = child.findVC(name: name) {
                        return temp
                    }
                }
            }
            return nil
        }
        return self
    }
}

extension AppViewController:UINavigationControllerDelegate{
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.relayoutViews(orientation: UIApplication.shared.statusBarOrientation)
    }
}

