//
//  AliyunPlaySDKDemoFullScreenScrollViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AliyunPlaySDKDemoFullScreenScrollViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize =  CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.showsHorizontalScrollIndicator = false
        
        // Register cell classes
        self.collectionView!.register(AliyunPlaySDKDemoFullScreenScrollCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let aliCell = cell as! AliyunPlaySDKDemoFullScreenScrollCollectionViewCell
        aliCell.aliyunVodPlayer.prepare(with: URL(string:"http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"))
        
    }

    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let aliCell = cell as! AliyunPlaySDKDemoFullScreenScrollCollectionViewCell
        aliCell.aliyunVodPlayer.stop()

    }
    
    

}
