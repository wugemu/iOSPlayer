//
//  AliyunPlaySDKListsAutoViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

class AliyunPlaySDKListsAutoViewController: UITableViewController {
    
    private var playLists:[AliyunVodPlayer] = [AliyunVodPlayer()]
    
   lazy var mTableView:UITableView = {
    () ->UITableView in
    let temp = UITableView()
    temp.delegate = self
    temp.dataSource = self
//    temp.register(AliyunPlayerHeaderView.self, forCellReuseIdentifier: "CELL")
    return temp
   }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Autoplay demo of multi-video by using url", comment: "")//"多视频自动播放"
        
        self.mTableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64)
        self.view.addSubview(self.mTableView)
        
        
        playLists.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let indentifier = "MineCenterCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier ) as? AliyunPlayerHeaderView
        
        if cell == nil {
            cell = AliyunPlayerHeaderView(style: .default, reuseIdentifier: "CELL")
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.none

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let aliCell = cell as! AliyunPlayerHeaderView
        aliCell.prepareToStart()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let aliCell = cell as! AliyunPlayerHeaderView
        aliCell.aliyunVodPlayer.stop()
    }
    
   
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (SCREEN_WIDTH-20)*9/16.0;
    }
    
    
}
