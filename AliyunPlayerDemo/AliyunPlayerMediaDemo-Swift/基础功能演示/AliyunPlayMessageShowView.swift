//
//  AliyunPlayMessageShowView.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class AliyunPlayMessageShowView: UIView {

    lazy var textView:UITextView = {
        let _textView = UITextView()
        _textView.textColor = UIColor.red
        _textView.backgroundColor = UIColor.white
        _textView.font = UIFont.systemFont(ofSize: 12)
        _textView.textAlignment = NSTextAlignment.left
        _textView.isEditable = false
        _textView.isSelectable = false
        _textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
        _textView.layer.cornerRadius = 5
        _textView.layer.masksToBounds = true
        return _textView;
    }()
    
    lazy private var contentView:UIView = {
        let _contentView = UIView()
        _contentView.backgroundColor = UIColor.white
        return _contentView
    }()
    
    lazy private var clearButton:UIButton = {
        let _clearButton = UIButton(type: UIButtonType.system)
        _clearButton.setTitle("clear", for: UIControlState.normal)
        _clearButton.addTarget(self, action: #selector(clearAllLog(_:)), for: UIControlEvents.touchUpInside)
        return _clearButton
    }()
    
    @objc private func clearAllLog(_ sender:UIButton){
        self.textView.text = ""
    }
    
    lazy private var okButton:UIButton = {
        let _okButton = UIButton(type: UIButtonType.system)
        _okButton.setTitle("OK", for: UIControlState.normal)
        _okButton.addTarget(self, action: #selector(okAction(_:)), for: UIControlEvents.touchUpInside)
        return _okButton
    }()
    
    @objc private func okAction(_ sender:UIButton){
        self.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 60, height: SCREEN_HEIGHT - 130)
        self.contentView.center = self.center
        
        self.textView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.height - 50)
        self.clearButton.frame = CGRect(x: 10, y: self.contentView.bounds.height - 40, width: self.contentView.bounds.width/2-20, height: 30)
        self.okButton.frame = CGRect(x: self.contentView.bounds.width/2+10, y: self.contentView.bounds.height - 40, width: self.contentView.bounds.width/2-20, height: 30)
        
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.clearButton)
        self.contentView.addSubview(self.okButton)
        self.addSubview(self.contentView)

    }
    
    private func getCurrentTimes() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let current = Date()
        let currentTimeString = formatter.string(from: current)
        return currentTimeString
    }
    
    func addTextString(_ text:String){
        self.textView.text = self.textView.text + "\n" + self.getCurrentTimes() + " " + text
    }
    

}
