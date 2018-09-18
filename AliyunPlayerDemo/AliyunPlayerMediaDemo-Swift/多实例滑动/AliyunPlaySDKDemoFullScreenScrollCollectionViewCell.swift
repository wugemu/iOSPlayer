//
//  AliyunPlaySDKDemoFullScreenScrollCollectionViewCell.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class AliyunPlaySDKDemoFullScreenScrollCollectionViewCell: UICollectionViewCell {
    
    lazy var aliyunVodPlayer:AliyunVodPlayer = {
        //播放器初始化
        let tempPlayer = AliyunVodPlayer()
        tempPlayer.isAutoPlay = true
        return tempPlayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        let playView = self.aliyunVodPlayer.playerView
        playView?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        self.contentView.addSubview(playView!)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        aliyunVodPlayer.stop()
        aliyunVodPlayer.release()
    }
    
}
