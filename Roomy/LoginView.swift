//
//  LogInViewViewController.swift
//  Roomy
//
//  Created by Darius on 2015. 05. 16..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class  LoginView: UITabBarController ,PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate{
    
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            presentLoginViewController()
        }
    }
    
    func presentLoginViewController() {
        let loginViewController = PFLogInViewController()
        loginViewController.delegate = self
        
        let signUpViewController = PFSignUpViewController()
        signUpViewController.delegate = self
        
        loginViewController.signUpController = signUpViewController
        presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController,
        shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
            
            if let password = info["password"] as? String {
                if count(password) < 3 {
                    let alert = UIAlertController(title: "Password must be at least 3 characters long", message: nil, preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(okAction)
                    signUpController.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    return true
                }
            }
            
            return false
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        let alert = UIAlertController(title: "Login Error", message: error?.localizedDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
