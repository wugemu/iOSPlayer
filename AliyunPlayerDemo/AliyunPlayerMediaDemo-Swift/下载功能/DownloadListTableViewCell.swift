//
//  DownloadListTableViewCell.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/18.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

protocol CellClickDelegate {
    func tableViewCell(_ tableViewCell:DownloadListTableViewCell,onClickDelete info:AliyunDownloadMediaInfo)
    func tableViewCell(_ tableViewCell:DownloadListTableViewCell,onClickPlay info:AliyunDownloadMediaInfo)
    func tableViewCell(_ tableViewCell:DownloadListTableViewCell,onClickStart dataSource:AliyunDataSource)
    func tableViewCell(_ tableViewCell:DownloadListTableViewCell,onClickStop info:AliyunDownloadMediaInfo)

}

class DownloadCellModel{
    var mInfo:AliyunDownloadMediaInfo!
    var mSource:AliyunDataSource!
    var mCanStop = false
    var mCanPlay = false
    var mCanStart = true
}


class DownloadListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var sizeInfoLabel: UILabel!
    var delegate:CellClickDelegate?
    var mInfo:AliyunDownloadMediaInfo!
    var mSource:AliyunDataSource!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.frame = CGRect(x: 5, y: 13, width: 96, height: 54)
        sizeInfoLabel.frame = CGRect(x: 5, y: 67, width: SCREEN_WIDTH-5, height: 12)
        statusLabel.frame = CGRect(x: 36, y: 30, width: 40, height: 16)
        startBtn.frame = CGRect(x: 115, y: 25, width: 32, height: 30)
        let space = (SCREEN_WIDTH - 115)/4 - 32
        stopBtn.frame = CGRect(x: 115+32+space, y: 25, width: 32, height: 30)
        deleteBtn.frame = CGRect(x: 115+(32+space)*2, y: 25, width: 32, height: 30)
        playBtn.frame = CGRect(x: 115+(32+space)*3, y: 25, width: 32, height: 30)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func startDownload(_ sender: UIButton) {
        
        if let delegate = delegate{
            delegate.tableViewCell(self, onClickStart: mSource)
        }

    }
    
    @IBAction func stopDownload(_ sender: UIButton) {
        
        if let delegate = delegate{
            delegate.tableViewCell(self, onClickStop: mInfo)
        }

    }
    
    @IBAction func deleteDownloadedVideo(_ sender: UIButton) {
        
        if let delegate = delegate{
            delegate.tableViewCell(self, onClickDelete: mInfo)
        }

    }
    
    @IBAction func playDownloadedVideo(_ sender: UIButton) {
        
        if let delegate = delegate{
            delegate.tableViewCell(self, onClickPlay: mInfo)
        }

    }
    
    
    
}
