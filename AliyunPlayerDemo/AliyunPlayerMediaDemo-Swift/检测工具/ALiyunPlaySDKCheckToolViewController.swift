//
//  ALiyunPlaySDKCheckToolViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/12.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class ALiyunPlaySDKCheckToolViewController: UIViewController {
    
    var playUrlPath = ""
    
    lazy private var webView:UIWebView = {
        let _webView = UIWebView()
        _webView.frame = self.view.frame
        return _webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("test video url by debug tools", comment:"")//"播放器诊断工具""test video url by debug tools"
        initWebView()
        
    }
    
    private func initWebView(){
        let playStr = CHECTTOOLURL + "&source=" + playUrlPath
        let url = URL(string: playStr)
        if let url = url {
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
        self.view.addSubview(webView)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
