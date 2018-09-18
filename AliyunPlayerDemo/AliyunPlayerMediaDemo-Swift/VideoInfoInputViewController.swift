//
//  VideoInfoInputViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/11.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class VideoInfoInputViewController: UIViewController {
    @IBOutlet weak var playAuthTextView: UITextView!
    @IBOutlet weak var vidTextField: UITextField!
    
    var isFullUI = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vidTextField.text = VID
        configPlayAuthTextView()

    }
 
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        vidTextField.resignFirstResponder()
        playAuthTextView.resignFirstResponder()

    }
    
    private func configPlayAuthTextView(){
        playAuthTextView.layer.cornerRadius = 5
        playAuthTextView.layer.masksToBounds = true
        playAuthTextView.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        playAuthTextView.layer.borderWidth = 0.5
        playAuthTextView.text = PLAYAUTH
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startPlayerInterface(_ sender: UIButton) {
        
        if isFullUI {
            let uiDemoVC = self.storyboard?.instantiateViewController(withIdentifier: "uiDemo") as! AliyunPlayerMediaUIDemoViewController
            uiDemoVC.videoID = vidTextField.text
            uiDemoVC.playAuth = playAuthTextView.text
            show(uiDemoVC, sender: sender)
        }else{
            let basicFunctionDemoVC = self.storyboard?.instantiateViewController(withIdentifier: "BasicFunctionDemoViewController") as! BasicFunctionDemoViewController
            basicFunctionDemoVC.videoID = vidTextField.text
            basicFunctionDemoVC.playAuth = playAuthTextView.text
            basicFunctionDemoVC.title = NSLocalizedString("Basic function demo of Vod by using vid and palyAuth", comment: "")
            
            show(basicFunctionDemoVC, sender: sender)
        }
        
    }
    
    
    

}
