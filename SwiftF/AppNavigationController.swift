//
//  AppNavigationController.swift
//  DeoFrame
//
//  Created by 杨栋 on 2017/4/21.
//  Copyright © 2017年 杨栋. All rights reserved.
//

open class AppNavigationController: UINavigationController,UINavigationControllerDelegate {
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.mIsDidAppear  = true
    }
    
    override open var shouldAutorotate: Bool{
        get{
            return topViewController?.shouldAutorotate ?? false
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return topViewController?.supportedInterfaceOrientations ?? .portrait
        }
    }
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if(!UIApplication.shared.mIsDidAppear){
            return
        }
        
        view.endEditing(true)
        UIApplication.shared.mIsDidAppear = false
        self.isNavigationBarHidden = !viewController.mIsNavigationBarShow
        super.pushViewController(viewController, animated: animated)
    }
    
    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if(!UIApplication.shared.mIsDidAppear){
            return nil
        }
        
        UIApplication.shared.mIsDidAppear = false
        self.isNavigationBarHidden = !viewController.mIsNavigationBarShow
        return super.popToViewController(viewController, animated: animated)!
    }
    
    override open func popViewController(animated: Bool) -> UIViewController? {
        
        let aviewController = super.popViewController(animated: animated)
        
        guard let targetViewController = viewControllers.last else {
            return aviewController
        }
        
        isNavigationBarHidden = !targetViewController.mIsNavigationBarShow
        navigationController?.popToViewController(targetViewController, animated: animated)
        return aviewController
    }
    
    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        UIApplication.shared.mIsDidAppear = false
        viewControllerToPresent.relayoutViews(orientation: UIApplication.shared.statusBarOrientation)
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

