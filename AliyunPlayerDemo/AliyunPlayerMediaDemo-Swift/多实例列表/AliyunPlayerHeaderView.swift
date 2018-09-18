//
//  AliyunPlayerHeaderView.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class AliyunPlayerHeaderView: UITableViewCell {

    lazy var aliyunVodPlayer:AliyunVodPlayer = {
        //播放器初始化
        let tempPlayer = AliyunVodPlayer()
        tempPlayer.isAutoPlay = true
        return tempPlayer
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let playView = self.aliyunVodPlayer.playerView
       playView?.frame = CGRect(x: 10, y: 10, width: SCREEN_WIDTH-20, height: (SCREEN_WIDTH-20)*9/16.0-20)
        
        self.addSubview(playView!)
    }
    
    func prepareToStart(){
        self.aliyunVodPlayer.prepare(with: URL(string:"http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        aliyunVodPlayer.stop()
        aliyunVodPlayer.release()
    }
    
}
