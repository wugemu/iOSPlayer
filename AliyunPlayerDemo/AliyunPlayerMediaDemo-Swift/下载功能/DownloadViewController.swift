//
//  DownloadViewController.swift
//  AliyunPlayerMediaDemo-Swift
//
//  Created by baby on 2017/10/17.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,AliyunVodDownLoadDelegate,DownloadViewDelegate,CellClickDelegate,AliyunVodPlayerViewDelegate {
 

    @IBOutlet weak var downloadTableView: UITableView!
    
    private var listDataArray = [DownloadCellModel]()
    private var listAddArray = [AliyunDataSource]()
    lazy private var downloadView:AddDownloadView = {
        let tempDownloadView = AddDownloadView(frame: CGRect(x: (SCREEN_WIDTH-300)/2, y: 100, width: 300, height: 400))
        tempDownloadView.isHidden = true
        view.addSubview(tempDownloadView)
        tempDownloadView.delegate = self
        return tempDownloadView
    }()
    private var isLock = false
    private var playerView:AliyunVodPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///下载必须要设置的三个内容：1.下载代理 2.下载路径3.下载加密的秘钥（如果要加密的话）
        //设置下载代理
        let downloadManager = AliyunVodDownLoadManager.share()
        downloadManager?.downloadDelegate = self

        //设置下载路径
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        downloadManager?.setDownLoadPath(path)
        
        //设置加密下载
        let bundlePath = Bundle.main.bundlePath
        let appInfo = bundlePath.appending("/encryptedApp.dat")
        downloadManager?.setEncrptyFile(appInfo)

        //设置同时下载的个数
        downloadManager?.setMaxDownloadOperationCount(3)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let playerView = playerView {
            playerView.setNeedsLayout()
        }
    }

    @IBAction func addVideoForDownload(_ sender: UIBarButtonItem) {
        downloadView.initShow()
        downloadView.isHidden = false
    }
    
    @IBAction func downloadAll(_ sender: UIButton) {
        AliyunVodDownLoadManager.share().startDownloadMedias(listAddArray)
        downloadTableView.reloadData()
    }
    
    @IBAction func deleteAll(_ sender: UIButton) {
        AliyunVodDownLoadManager.share().clearAllMedias()
        listDataArray.removeAll()
        listAddArray.removeAll()
        downloadTableView.reloadData()
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        
        if let playerView = playerView{
            playerView.stop()
            playerView.releasePlayer()
            playerView.removeFromSuperview()
        }
        navigationController?.popViewController(animated: true)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadCell", for: indexPath) as! DownloadListTableViewCell
        cell.delegate = self
        
        if listDataArray.count > indexPath.row{
            let dcm = listDataArray[indexPath.row]
            let info = dcm.mInfo
            cell.mInfo = info
            cell.mSource = dcm.mSource
            
            let sizeStr = "标题：" + (info?.title)! + "(size：" + "\((info?.size)!/(1024*1024))" + "M)"
            cell.sizeInfoLabel.text = sizeStr
            
            let tempProgress = info?.downloadProgress
            if let tempProgress = tempProgress{
                if tempProgress <= 0{
                    cell.statusLabel.text = NSLocalizedString("download_status_unload", comment: "")//"未下载"
                }else if tempProgress >= 100{
                    cell.statusLabel.text = NSLocalizedString("download_status_finish", comment: "")//"已完成"
                }else if tempProgress > 0 && tempProgress < 100 {
                    cell.statusLabel.text = "\(tempProgress)" + "%"
                }
            }
            if !dcm.mCanStop {
                cell.statusLabel.text = NSLocalizedString("download_status_stop", comment: "")//"已停止""download_status_stop"
            }
            
            let url = URL(string: (info?.coverURL)!)
            let request = URLRequest(url: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { (response,data , error) in
                if error == nil {
                    cell.coverImageView.image = UIImage(data:data!)
                }
            })

            cell.playBtn.isEnabled = dcm.mCanPlay
            cell.stopBtn.isEnabled = dcm.mCanStop
            cell.startBtn.isEnabled = dcm.mCanStart
        }
        return cell
    }
    
    
    // MARK: - Delegate
    func onUnFinished(_ mediaInfos: [AliyunDataSource]!) {
        if mediaInfos.count > 0{
            let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: NSLocalizedString("Unfinished last time", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
            alert.show()
            
            for source in mediaInfos{
                if source.playAuth == nil {
                    source.playAuth = PLAYAUTH
                }
                
                let dcm = DownloadCellModel()
                let info = AliyunDownloadMediaInfo()
                info.vid = source.vid
                info.quality = source.quality
                info.format = source.format
                dcm.mInfo = info
                dcm.mCanPlay = false
                dcm.mCanStop = true
                dcm.mCanStart = false
                dcm.mSource = source
                listDataArray.append(dcm)
                listAddArray.append(dcm.mSource)
            }
            downloadTableView.reloadData()
            AliyunVodDownLoadManager.share().startDownloadMedias(mediaInfos)
        }
    }
    
    func onGetPlayAuth(_ vid: String!, format: String!, quality: AliyunVodPlayerVideoQuality) -> String! {
        return PLAYAUTH
    }
    
    func onPrepare(_ mediaInfos: [AliyunDownloadMediaInfo]!) {
        downloadView.updateQualityInfo(mediaInfos)
    }
    
    func onStart(_ mediaInfo: AliyunDownloadMediaInfo!) {
        for dcm in listDataArray{
            let info = (dcm.mInfo)!
            if info.quality == mediaInfo.quality && info.format == mediaInfo.format && info.vid == mediaInfo.vid {
                info.title = mediaInfo.title
                info.coverURL = mediaInfo.coverURL
                info.size = mediaInfo.size
                info.duration = mediaInfo.duration
                info.downloadFilePath = mediaInfo.downloadFilePath
                
                dcm.mCanStop = true
                dcm.mCanPlay = false
                dcm.mCanStart = false
                
                downloadTableView.reloadData()
                break
            }
        }
        let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: NSLocalizedString("Begun", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
        alert.show()
    }
    
    func onProgress(_ mediaInfo: AliyunDownloadMediaInfo!) {
        for dcm in listDataArray{
            let info = (dcm.mInfo)!
            if info.vid == mediaInfo.vid && info.format == mediaInfo.format && info.quality == mediaInfo.quality{
                info.downloadProgress = mediaInfo.downloadProgress
                downloadTableView.reloadData()
                break
            }
        }
    }
    
    func onStop(_ mediaInfo: AliyunDownloadMediaInfo!) {
        for dcm in listDataArray{
            if dcm.mInfo.vid == mediaInfo.vid && dcm.mInfo.quality == mediaInfo.quality && dcm.mInfo.format == mediaInfo.format{
                dcm.mCanStop = false
                dcm.mCanPlay = false
                dcm.mCanStart = true
                downloadTableView.reloadData()
                break
            }
        }
        let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: NSLocalizedString("Stopped", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
        alert.show()
    }
    
    func onCompletion(_ mediaInfo: AliyunDownloadMediaInfo!) {
        for dcm in listDataArray{
            if dcm.mInfo.vid == mediaInfo.vid && dcm.mInfo.quality == mediaInfo.quality && dcm.mInfo.format == mediaInfo.format{
                dcm.mCanStop = true
                dcm.mCanPlay = true
                dcm.mCanStart = true
                downloadTableView.reloadData()
                break
            }
        }
        let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: NSLocalizedString("Finished", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
        alert.show()
    }
    
    func onChangeEncryptFileProgress(_ progress: Int32) {
        
    }
    
    func onChangeEncryptFileComplete() {
        
    }
    
    func onError(_ mediaInfo: AliyunDownloadMediaInfo!, code: Int32, msg: String!) {
        let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: msg, delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
        alert.show()
    }
    
    func onStartDownload(_ dataSource: AliyunDataSource, medianInfo info: AliyunDownloadMediaInfo) {
        for source in listAddArray {
            if dataSource.vid == source.vid && dataSource.format == source.format && dataSource.quality == source.quality{
                let alert = UIAlertView(title: NSLocalizedString("Tips", comment: ""), message: NSLocalizedString("Cannot repeatly add", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok_button1", comment: ""))
                alert.show()
                return
            }
        }
        
        listAddArray.append(dataSource)
        let dcm = DownloadCellModel()
        dcm.mCanStop = true
        dcm.mCanPlay = false
        dcm.mCanStart = true
        dcm.mInfo = info
        dcm.mSource = dataSource
        listDataArray.append(dcm)
        
        downloadTableView.reloadData()
    }
    
    func tableViewCell(_ tableViewCell: DownloadListTableViewCell, onClickDelete info: AliyunDownloadMediaInfo) {
        AliyunVodDownLoadManager.share().clearMedia(info)
        
        for (index,dcm) in listDataArray.enumerated(){
            let donwloadInfo = (dcm.mInfo)!
            if donwloadInfo.vid == info.vid && donwloadInfo.format == info.format && donwloadInfo.quality == info.quality{
                donwloadInfo.downloadProgress = 0
                dcm.mCanPlay = true
                dcm.mCanStop = true
                dcm.mCanStart = true
                listDataArray.remove(at: index)
                downloadTableView.reloadData()
                break
            }
        }
        
        for (index,source) in listAddArray.enumerated(){
            if source.vid == info.vid && source.format == info.format && source.quality == info.quality{
                listAddArray.remove(at: index)
                break
            }
        }
    }
    
    func tableViewCell(_ tableViewCell: DownloadListTableViewCell, onClickPlay info: AliyunDownloadMediaInfo) {
        if info.downloadFilePath != nil {
            navigationController?.setNavigationBarHidden(true, animated: false)
            if let playerView = playerView{
                playerView.removeFromSuperview()
                playerView.stop()
                playerView.releasePlayer()
            }
            playerView = AliyunVodPlayerView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH*9/16))
            playerView?.delegate = self
            playerView?.setAutoPlay(true)
            view.addSubview(playerView!)
            playerView?.playPrepare(with: URL(string: info.downloadFilePath))
            
        }
    }
    
    func tableViewCell(_ tableViewCell: DownloadListTableViewCell, onClickStart dataSource: AliyunDataSource) {
        AliyunVodDownLoadManager.share().startDownloadMedia(dataSource)
    }
    
    func tableViewCell(_ tableViewCell: DownloadListTableViewCell, onClickStop info: AliyunDownloadMediaInfo) {
        AliyunVodDownLoadManager.share().stopDownloadMedia(info)
    }
    
    func onBackViewClick(with playerView: AliyunVodPlayerView!) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        if let playerView = playerView{
            playerView.removeFromSuperview()
            playerView.stop()
            playerView.releasePlayer()
        }
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
        isLock = isLockScreen
    }
    
    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onVideoQualityChanged quality: AliyunVodPlayerVideoQuality) {
        
    }
    
    override var shouldAutorotate: Bool{
        return !isLock
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if isLock{
            return .portrait
        }else{
            return .all
        }
    }
 
    

}
