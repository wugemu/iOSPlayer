//
//  AliyunPlayerMediaUIDemoViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class AliyunPlayerMediaUIDemoViewController: UIViewController,AliyunVodPlayerViewDelegate {

    var videoID:String?
    var playAuth:String?
    
    private var isLock = false
    
    private var aliyunVodPlayer:AliyunVodPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        var width:CGFloat = 0
        var height:CGFloat = 0
        let orientation = UIApplication.shared.statusBarOrientation
        if (orientation == .portrait ) {
            width = SCREEN_WIDTH
            height = SCREEN_WIDTH * 9 / 16.0
        }else{
            width = SCREEN_HEIGHT
            height = SCREEN_HEIGHT * 9 / 16.0
        }
        aliyunVodPlayer = AliyunVodPlayerView(frame: CGRect(x: 0, y: 20, width: width ,height: height), andSkin: AliyunVodPlayerViewSkin.blue)
        aliyunVodPlayer?.delegate = self
        aliyunVodPlayer?.setAutoPlay(true)
        aliyunVodPlayer?.isLockScreen = isLock
        view.addSubview(aliyunVodPlayer!)
        
        setCacheForPlaying()

        aliyunVodPlayer?.playPrepare(withVid: videoID, playAuth: playAuth)
//        aliyunVodPlayer?.playPrepare(with: URL(string: "http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"))
    }
    
    private func setCacheForPlaying(){
        //缓存设置
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        aliyunVodPlayer?.setPlayingCache(false, saveDir: path, maxSize: 30, maxDuration: 10000)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onBackViewClick(with playerView: AliyunVodPlayerView!) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        aliyunVodPlayer?.stop()
        aliyunVodPlayer?.releasePlayer()
        aliyunVodPlayer?.removeFromSuperview()
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onPause currentPlayTime: TimeInterval) {
        
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onResume currentPlayTime: TimeInterval) {
        
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onStop currentPlayTime: TimeInterval) {
        
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onSeekDone seekDoneTime: TimeInterval) {
        
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, lockScreen isLockScreen: Bool) {
        self.isLock = isLockScreen
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onVideoQualityChanged quality: AliyunVodPlayerVideoQuality) {
        
    }
    
    //MARK: - 锁屏功能
    /**
     * 说明：播放器父类是UIView。
     屏幕锁屏方案需要用户根据实际情况，进行开发工作；
     如果viewcontroller在navigationcontroller中，需要添加子类重写navigationgController中的 以下方法，根据实际情况做判定 。
     */
    
    override var shouldAutorotate: Bool{
        return !self.isLock
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if self.isLock{
            return .portrait
        }else{
            return .all
        }
    }
    
    deinit {
        aliyunVodPlayer?.stop()
        aliyunVodPlayer?.releasePlayer()
        aliyunVodPlayer?.removeFromSuperview()
    }


}

//重写Nav方法控制锁屏
extension UINavigationController {
    override open var shouldAutorotate: Bool {
        return (self.viewControllers.last?.shouldAutorotate)!
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.viewControllers.last?.supportedInterfaceOrientations)!
    }
    

}

