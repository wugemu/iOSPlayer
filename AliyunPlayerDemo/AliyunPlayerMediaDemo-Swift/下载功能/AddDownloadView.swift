//
//  AddDownloadView.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/17.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

protocol DownloadViewDelegate {
    
    func onStartDownload(_ dataSource:AliyunDataSource, medianInfo info:AliyunDownloadMediaInfo)
    
}

class AddDownloadView: UIView {
    
    var textVid:UITextField!
    var textView:UITextView!
    var okBtn:UIButton!
    var backBtn:UIButton!
    var qualityBtn:UIButton!
    var qualityControl:UISegmentedControl!
    var mArray:[AliyunDownloadMediaInfo] = [AliyunDownloadMediaInfo]()
    var delegate:DownloadViewDelegate?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        let control = UIControl(frame: self.bounds)
        control.addTarget(self, action: #selector(hidekeybroad(_:)), for: .touchDown)
        addSubview(control)
        
        let appKeyLabel = UILabel(frame: CGRect(x: 10, y: 40, width: 120, height: 30))
        appKeyLabel.text = "vid:"
        appKeyLabel.textColor = UIColor.black
        addSubview(appKeyLabel)
        
        textVid = UITextField(frame: CGRect(x: 100, y: 35, width: 180, height: 30))
        textVid.text = VID
        textVid.font = UIFont.systemFont(ofSize: 12)
        textVid.textColor = UIColor.black
        textVid.borderStyle = .roundedRect
        addSubview(textVid)
        
        let appSecretLabel = UILabel(frame: CGRect(x: 10, y: 77, width: 120, height: 30))
        appSecretLabel.text = "playAuth: "
        appSecretLabel.textColor = UIColor.black
        addSubview(appSecretLabel)

        textView = UITextView(frame: CGRect(x: 10, y: 110, width: self.frame.size.width-20, height: 90))
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.textAlignment = .left
        textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.text = PLAYAUTH
        addSubview(textView)
        
        backBtn = UIButton(type: .roundedRect)
        backBtn.frame = CGRect(x: 40, y: 325, width: 100, height: 40)
        backBtn.addTarget(self, action: #selector(cancelBtnAction(_:)), for: .touchUpInside)
        backBtn.setTitleColor(UIColor(red: 123/255.0, green: 134/255.0, blue: 252/255.0, alpha: 1), for: .normal)
        backBtn.setTitleColor(UIColor.gray, for: .selected)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backBtn.backgroundColor = UIColor(red: 0x87/255.0, green: 0x4b/255.0, blue: 0xe0/255.0, alpha: 1)
        backBtn.setTitle("取消", for: .normal)
        backBtn.clipsToBounds = true
        backBtn.layer.cornerRadius = 20
        backBtn.setTitleColor(UIColor.white, for: .normal)
        addSubview(backBtn)
        
        okBtn = UIButton(type: .roundedRect)
        okBtn.frame = CGRect(x: 60, y: 325, width: 100, height: 40)
        okBtn.addTarget(self, action: #selector(okBtnAction(_:)), for: .touchUpInside)
        okBtn.setTitleColor(UIColor(red: 123/255.0, green: 134/255.0, blue: 252/255.0, alpha: 1), for: .normal)
        okBtn.setTitleColor(UIColor.gray, for: .selected)
        okBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        okBtn.backgroundColor = UIColor(red: 0x87/255.0, green: 0x4b/255.0, blue: 0xe0/255.0, alpha: 1)
        okBtn.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = 20
        okBtn.setTitleColor(UIColor.white, for: .normal)
        addSubview(okBtn)

        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        
        qualityBtn = UIButton(type: .roundedRect)
        qualityBtn.frame = CGRect(x: 10, y: 220, width: 100, height: 30)
        qualityBtn.addTarget(self, action: #selector(qualityRequest(_:)), for: .touchUpInside)
        qualityBtn.setTitleColor(UIColor(red: 123/255.0, green: 134/255.0, blue: 252/255.0, alpha: 1), for: .normal)
        qualityBtn.setTitleColor(UIColor.gray, for: .selected)
        qualityBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        qualityBtn.backgroundColor = UIColor(red: 0x87/255.0, green: 0x4b/255.0, blue: 0xe0/255.0, alpha: 1)
        qualityBtn.setTitle(NSLocalizedString("get_all_definition", comment: ""), for: .normal)
        qualityBtn.clipsToBounds = true
        qualityBtn.layer.cornerRadius = 10
        qualityBtn.setTitleColor(UIColor.white, for: .normal)
        addSubview(qualityBtn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func hidekeybroad(_ sender:UIControl){
        textVid.resignFirstResponder()
        textView.resignFirstResponder()

    }
    
    @objc private func cancelBtnAction(_ sender:UIButton){
        isHidden = true
    }
    
    @objc private func okBtnAction(_ sender:UIButton){
        
        if qualityControl.isEnabled == false {
            let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: NSLocalizedString("Please request definition list first", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
            alert.show()
            return
        }
        
        let info = mArray[qualityControl.selectedSegmentIndex]
        let source = AliyunDataSource()
        source.vid = textVid.text ?? ""
        source.playAuth = textView.text ?? ""
        source.quality = info.quality
        source.format = info.format
        
        if let delegate = delegate {
            delegate.onStartDownload(source, medianInfo: info)
        }
        isHidden = true
        
    }
    
    @objc private func qualityRequest(_ sender:UIButton){
        
        textVid.resignFirstResponder()
        textView.resignFirstResponder()
        
        let source = AliyunDataSource()
        source.vid = textVid.text ?? ""
        source.playAuth = textView.text ?? ""
        
        AliyunVodDownLoadManager.share().prepareDownloadMedia(source)
        
    }

    func initShow(){
        if qualityControl != nil {
            qualityControl.removeFromSuperview()
        }
        
        mArray.removeAll()
    }
    
    func updateQualityInfo(_ mediaInfos:[AliyunDownloadMediaInfo]){
        DispatchQueue.main.async() {
            if mediaInfos.count == 0 {
                return
            }
        }
        
        if qualityControl != nil {
            qualityControl.removeFromSuperview()
        }
        
        mArray.removeAll()
        var array = [String]()
        let segmentedArray = [NSLocalizedString("fd_definition", comment: ""),
                             NSLocalizedString("ld_definition", comment: ""),
                             NSLocalizedString("sd_definition", comment: ""),
                             NSLocalizedString("hd_definition", comment: ""),
                             NSLocalizedString("2k_definition", comment: ""),
                             NSLocalizedString("4k_definition", comment: ""),
                             NSLocalizedString("od_definition", comment: "")]
        
        for info in mediaInfos{
            let text = segmentedArray[Int(info.quality.rawValue)]
            let sizeStr = text + "(" + "\(info.size/(1024*1024))" + "M)"
            array.append(sizeStr)
            mArray.append(info)
        }
        
        if array.count > 0 {
            qualityControl = UISegmentedControl(items: array)
            qualityControl.frame = CGRect(x: 20, y: 260, width: 250, height: 35)
            qualityControl.selectedSegmentIndex = 0
            qualityControl.tintColor = UIColor.white
            addSubview(qualityControl)
        }
        
    }

    
}
