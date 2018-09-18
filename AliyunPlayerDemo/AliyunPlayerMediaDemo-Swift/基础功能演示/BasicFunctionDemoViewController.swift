//
//  BasicFunctionDemoViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/11.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit



class BasicFunctionDemoViewController: UIViewController,AliyunVodPlayerDelegate {

    static var s_autoPlay:Bool = false
    
    var videoID:String?
    var playAuth:String?
    
    private var timer:Timer = Timer()
    private var tempErrorModel:ALPlayerVideoErrorModel?
    private var qualitysAry:Array = [""]

    /*
     界面元素
     */
    @IBOutlet weak var playerContentView: UIView!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var timeProgress: UISlider!
    @IBOutlet weak var disPlayModeSegment: UISegmentedControl!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet weak var qualityControl: UISegmentedControl!
    
    
    lazy private var aliyunVodPlayer:AliyunVodPlayer = {
        //播放器初始化
        let tempPlayer = AliyunVodPlayer()
        tempPlayer.delegate = self as AliyunVodPlayerDelegate
        tempPlayer.isAutoPlay = self.autoPlaySwitch.isOn
        return tempPlayer
    }()
    
    lazy private var showMessageView:AliyunPlayMessageShowView  = {
        let _showMessageView = AliyunPlayMessageShowView()
        _showMessageView.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
        _showMessageView.alpha = 1
        return _showMessageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoPlaySwitch.isOn = BasicFunctionDemoViewController.s_autoPlay
        timeProgress.isEnabled = false
        
        self.setPlayerContentView()
        self.setCacheForPlaying()
        self.aliyunVodPlayer.prepare(withVid: videoID, playAuth: playAuth)
//        self.aliyunVodPlayer.prepare(with: URL(string: "http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"))
        
        //获取版本号
        let version = self.aliyunVodPlayer.getSDKVersion()
        print(version!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.aliyunVodPlayer.playerView.frame  = CGRect(x: 0, y: 0, width: self.playerContentView.bounds.size.width, height: self.playerContentView.bounds.size.height)
        self.showMessageView.frame = self.view.bounds
    }
    
    private func setPlayerContentView(){
        //设置播放视图
        let playerView = aliyunVodPlayer.playerView
        playerView?.frame = CGRect(x: 0, y: 0, width: self.playerContentView.bounds.size.width, height: self.playerContentView.bounds.size.height)
        playerContentView.addSubview(playerView!)
        
        playerContentView.bringSubview(toFront: leftTimeLabel)
        playerContentView.bringSubview(toFront: rightTimeLabel)
        playerContentView.bringSubview(toFront: timeProgress)
        
        //添加log视图
        self.showMessageView.isHidden = true
        self.view.addSubview(self.showMessageView)
    }
    
    private func setCacheForPlaying(){
        //缓存设置
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        aliyunVodPlayer.setPlayingCache(false, saveDir: path, maxSize: 30, maxDuration: 10000)
    }
    
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 201://play
            if self.aliyunVodPlayer.playerState() == AliyunVodPlayerState.idle || self.aliyunVodPlayer.playerState() == AliyunVodPlayerState.stop {
                self.aliyunVodPlayer.isAutoPlay = true
                self.aliyunVodPlayer.prepare(withVid: videoID, playAuth: playAuth)
//                self.aliyunVodPlayer.prepare(with: URL(string: "http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"))
            }else{
                self.aliyunVodPlayer.start()
            }
        case 202://stop
            self.aliyunVodPlayer.stop()
            self.timer.invalidate()
            self.timeProgress.setValue(0, animated: true)
            self.leftTimeLabel.text = getMMSSFromSS(0)
            timeProgress.isEnabled = false
        case 203://pause
            self.aliyunVodPlayer.pause()
        case 204://resume
            self.aliyunVodPlayer.resume()
        case 205://replay
            self.aliyunVodPlayer.displayMode = AliyunVodPlayerDisplayMode(rawValue: Int32(self.disPlayModeSegment.selectedSegmentIndex))!
            self.disPlayModeSegment.selectedSegmentIndex = Int(self.aliyunVodPlayer.displayMode.rawValue)
            self.aliyunVodPlayer.replay()
        case 206://diagnosis
            let debugToolVC = ALiyunPlaySDKCheckToolViewController()
            if let tempError = self.tempErrorModel{
                if let errorUrl = tempError.errorUrl{
                    debugToolVC.playUrlPath = errorUrl
                    print(errorUrl)
                }
            }
            self.navigationController?.pushViewController(debugToolVC, animated: true)
        default:
            print("other")
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 301://自动播放
            self.aliyunVodPlayer.isAutoPlay = sender.isOn
            BasicFunctionDemoViewController.s_autoPlay = sender.isOn
        case 302://静音
            self.aliyunVodPlayer.isMuteMode = sender.isOn
        default:
            print("other")
        }
    }
    
    //seek
    @IBAction func timeProgress(_ sender: UISlider) {
        
        self.aliyunVodPlayer.seek(toTime:TimeInterval(exactly: sender.value)! * self.aliyunVodPlayer.duration )
        
    }
    
    @IBAction func videoQualityChanged(_ sender: UISegmentedControl) {
        if qualitysAry.count > 0 {
            switch sender.selectedSegmentIndex {
            case Int(qualitysAry[sender.selectedSegmentIndex])!:
                aliyunVodPlayer.quality = AliyunVodPlayerVideoQuality(rawValue: Int32(qualitysAry[sender.selectedSegmentIndex])!)!
                print(aliyunVodPlayer.quality.rawValue)
            default:
                print("other quality")
            }
        }
    }
    
    @IBAction func progressChanged(_ sender: UISlider) {
        
        switch sender.tag {
        case 401://音量
            self.aliyunVodPlayer.volume = sender.value
        case 402://亮度
            self.aliyunVodPlayer.brightness = sender.value
        default:
            print("other things")
        }

    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        //切换显示模式
        self.aliyunVodPlayer.displayMode = AliyunVodPlayerDisplayMode(rawValue: Int32(self.disPlayModeSegment.selectedSegmentIndex))!
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.aliyunVodPlayer.displayMode = .fit
        case 1:
            self.aliyunVodPlayer.displayMode = .fitWithCropping
        default:
            print("other display model")
        }
        
    }
    
    @IBAction func showLog(_ sender: UIBarButtonItem) {
        self.showMessageView.isHidden = false
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.aliyunVodPlayer.stop()
        self.aliyunVodPlayer.release()
        self.timer.invalidate()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:播放器代理方法
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        if event == .prepareDone {
            //获取清晰度
            let videoModel = self.aliyunVodPlayer.getAliyunMediaInfo()
            qualitysAry.removeAll()
            qualityControl.removeAllSegments()
            if let allSupportQualitys = videoModel?.allSupportQualitys{
                for quality in allSupportQualitys {
                    let qualityDescription = self.videoQualityToString(quality as! String)
                    let index = qualityControl.numberOfSegments
                    qualityControl.insertSegment(withTitle: qualityDescription, at: index, animated: true)
                    if Int32(quality as! String)! == (videoModel?.videoQuality)!.rawValue {
                        qualityControl.selectedSegmentIndex = Int((videoModel?.videoQuality)!.rawValue)
                        print("current quality is " + "\(aliyunVodPlayer.quality.rawValue)")
                    }
                    qualitysAry.append(quality as! String)
                }
                
            }
            
            //时间进度显示
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRun(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
            self.rightTimeLabel.text = self.getMMSSFromSS(aliyunVodPlayer.duration)
        }
        
        if event == .firstFrame {
            timeProgress.isEnabled = true
        }
        
        //log
        self.showMessageView.addTextString(getMessageWithevent(event.rawValue, ""))

    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, playBack errorModel: ALPlayerVideoErrorModel!) {
        let errDescription = getMessageWithevent(errorModel.errorCode, errorModel.errorMsg)
        showMessageView.addTextString(errDescription)
        self.tempErrorModel = errorModel
        let alert = UIAlertView(title: "错误", message: errDescription, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, willSwitchTo quality: AliyunVodPlayerVideoQuality) {
        
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, didSwitchTo quality: AliyunVodPlayerVideoQuality) {
        
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, failSwitchTo quality: AliyunVodPlayerVideoQuality) {
        
    }
    

    //运行timer
    @objc func timerRun(_ sender:Timer){
        
            self.leftTimeLabel.text = getMMSSFromSS(self.aliyunVodPlayer.currentTime)
            self.timeProgress.setValue(Float(self.aliyunVodPlayer.currentTime/self.aliyunVodPlayer.duration), animated: true)
        
    }
    

    private func getMMSSFromSS(_ totalTime:TimeInterval) -> String{
        let seconds = Int(totalTime)
        let hour = seconds/3600
        let minute = (seconds % 3600)/60
        let second = seconds % 60
        
        var hourStr = "\(hour)"
        if hour == 0{
            hourStr = "0\(hour)"
        }
        var minuteStr = "\(minute)"
        if minute < 10 {
            minuteStr = "0\(minute)"
        }
        var secondStr = "\(second)"
        if second < 10 {
            secondStr = "0\(second)"
        }
        let formatTime = hourStr + ":" + minuteStr + ":" + secondStr
        
        return formatTime
    }
    
    private func videoQualityToString(_ strQuality:String) -> String{
        let nQuality = Int32(strQuality)
        let quality:AliyunVodPlayerVideoQuality = AliyunVodPlayerVideoQuality(rawValue: nQuality!)!
        var strQualityDescrp = "标清"
        switch quality {
        case .videoFD:
            strQualityDescrp = "流畅"
        case .videoLD:
            strQualityDescrp = "标清"
        case .videoSD:
            strQualityDescrp = "高清"
        case .videoHD:
            strQualityDescrp = "超清"
        case .video2K:
            strQualityDescrp = "2K"
        case .video4K:
            strQualityDescrp = "4K"
        case .videoOD:
            strQualityDescrp = "原画"
        }
        return strQualityDescrp
    }
    
    //MARK:展示日志信息
    private func getMessageWithevent(_ event:Int32, _ errorMsg:String) -> String{
        var str = ""
        switch event {
        case AliyunVodPlayerEvent.play.rawValue:
            str = "开始播放"
        case AliyunVodPlayerEvent.pause.rawValue:
            str = "播放器暂停"
        case AliyunVodPlayerEvent.stop.rawValue:
            str = "播放器停止"
        case AliyunVodPlayerEvent.finish.rawValue:
            str = "播放视频完成"
        case AliyunVodPlayerEvent.beginLoading.rawValue:
            str = "开始加载视频"
        case AliyunVodPlayerEvent.endLoading.rawValue:
            str = "加载视频完成"
        case AliyunVodPlayerEvent.prepareDone.rawValue:
            str = "获取到播放数据"
        case AliyunVodPlayerEvent.seekDone.rawValue:
            str = "视频跳转seek结束"
        case AliyunVodPlayerEvent.firstFrame.rawValue:
            str = "视频首帧开始播放"
        default:
            str = "播放器报错!!! 错误码:" + "\(event)" + " 错误描述:" + errorMsg
        }
        return str
    }
    
    //MARK:析构函数
    deinit {
        self.aliyunVodPlayer.stop()
        self.aliyunVodPlayer.release()
        self.timer.invalidate()
         print("back click")
    }
}
