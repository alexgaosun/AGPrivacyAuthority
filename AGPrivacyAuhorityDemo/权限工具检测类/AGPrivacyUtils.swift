//
//  AGPrivacyUtils.swift
//  AGPrivacyAuhorityDemo
//
//  Created by 高莹莹 on 2019/6/20.
//  Copyright © 2019 高莹莹. All rights reserved.
//

import Photos
import AssetsLibrary
import CoreTelephony
import CoreLocation
import AVFoundation

/*
 1.⚠️必须在info.plst，配置权限，否则崩溃
 <key>NSCameraUsageDescription</key>
 <string> 是否允许app打开相册或照相机,以便用作图像上传?</string>
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>App将在首页位置、商圈中使用您的位置信息，注意:使用后台定位会减少电池的使用寿命 是否允许使用定位?</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>App将在首页位置、商圈中使用您的位置信息，注意:使用后台定位会减少电池的使用寿命 是否允许使用定位?</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>是否允许此App使用你的麦克风？</string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string> 是否允许app打开相册或照相机,以便用作图像上传?</string>
 <key>NSPhotoLibraryAddUsageDescription</key>
 <string>是否允许app存储图片</string>
 */


enum AGpermissionsType{
    /// 相机
    case camera
    /// 相册
    case photo
    /// 位置
    case location
    /// 网络
    case network
    /// 麦克风
    case microphone
}

// MARK: - 检测是否开启蜂窝联网
/*pragma
 isOpenURL: true:是否提示跳转设置页面, false:不提是弹出页面
 action: 回调Bool，true是开启权限，false：未开启权限
 */
func ag_openEventServiceWithBolck(_ isOpenURL:Bool? = nil,_ action :@escaping ((Bool)->())) {
    DispatchQueue.main.async(execute: {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            DispatchQueue.main.async(execute: {
                if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
                    action(false)
                    if isOpenURL == true {ag_OpenURL(.network)}
                } else {
                    
                    action(true)
                }
            })
        }
        let state = cellularData.restrictedState
        if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
            action(false)
            if isOpenURL == true {ag_OpenURL(.network)}
        } else {
            action(true)
        }
    })
}

// MARK: - 检测是否开启定位
/*pragma
 isOpenURL: true:是否提示跳转设置页面, false:不提是弹出页面
 action: 回调Bool，true是开启权限，false：未开启权限
 */
let locationManager = CLLocationManager()//必须设置为全局变量负责，定位框会闪现消失
func ag_openLocationServiceWithBlock(_ isSet:Bool? = nil,_ action :@escaping ((Bool)->())) {
    var isOpen = false
    locationManager.requestAlwaysAuthorization()//首次必须开启定位权限请求
    if CLLocationManager.authorizationStatus() != .restricted && CLLocationManager.authorizationStatus() != .denied {
        isOpen = true
    }
    if isOpen == false && isSet == true {ag_OpenURL(.location)}
    action(isOpen)
}

// MARK: - 检测是否开启相册
/*pragma
 isOpenURL: true:是否提示跳转设置页面, false:不提是弹出页面
 action: 回调Bool，true是开启权限，false：未开启权限
 */
func ag_openAlbumServiceWithBlock(_ isSet:Bool? = nil,_ action :@escaping ((Bool)->())) {
    PHPhotoLibrary.shared().performChanges({//首次必须开启相册权限请求
    }, completionHandler: { (isSucess, error) in
        DispatchQueue.main.async(execute: {
            if isSucess {
                action(true)
            }
            if (error != nil) {
                let code = (error! as NSError).code
                if code == 2047 {
                    var isOpen = true
                    let authStatus = PHPhotoLibrary.authorizationStatus()//authorizationStatus
                    if authStatus == PHAuthorizationStatus.restricted || authStatus == PHAuthorizationStatus.denied {
                        isOpen = false;
                        if isSet == true {ag_OpenURL(.photo)}
                    }
                    action(isOpen)
                }
            }
        })
    })
}

// MARK: - 检测是否开启摄像头
/*pragma
 isOpenURL: true:是否提示跳转设置页面, false:不提是弹出页面
 action: 回调Bool，true是开启权限，false：未开启权限
 */
func ag_openCaptureDeviceServiceWithBlock(_ isSet:Bool? = nil,_ action :@escaping ((Bool)->())) {
    let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    
    if authStatus == AVAuthorizationStatus.notDetermined {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            DispatchQueue.main.async(execute: {
                action(granted)
                if granted == false && isSet == true {ag_OpenURL(.camera)}
            })
        }
    } else if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
        action(false)
        if isSet == true {ag_OpenURL(.camera)}
    } else {
        action(true)
    }
}

// MARK: - 检测是否开启麦克风
/*pragma
 isOpenURL: true:是否提示跳转设置页面, false:不提是弹出页面
 action: 回调Bool，true是开启权限，false：未开启权限
 */
func ag_openRecordServiceWithBlock(_ isSet:Bool? = nil,_ action :@escaping ((Bool)->())) {
    let permissionStatus = AVAudioSession.sharedInstance().recordPermission
    if permissionStatus == AVAudioSession.RecordPermission.undetermined {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            DispatchQueue.main.async(execute: {
                action(granted)
                if granted == false && isSet == true {ag_OpenURL(.microphone)}
            })
        }
    } else if permissionStatus == AVAudioSession.RecordPermission.denied || permissionStatus == AVAudioSession.RecordPermission.undetermined{
        action(false)
        if isSet == true {ag_OpenURL(.microphone)}
    } else {
        action(true)
    }
}
// MARK: - 跳转系统设置界面
func ag_OpenURL(_ type: AGpermissionsType? = nil) {
    let title = "权限无法访问"
    var message = "请点击“前往”，允许访问权限"
    let appName: String = (Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? "") as! String //App 名称
    if type == .camera { // 相机
        message = "请在\"设置-隐私-相机\"选项中，允许\"\(appName)\"访问你的相机"
    } else if type == .photo { // 相册
        message = "请在\"设置-隐私-照片\"选项中，允许\"\(appName)\"访问你的相册"
    } else if type == .location { // 位置
        message = "请在\"设置-隐私-定位服务\"选项中，允许\"\(appName)\"访问您的位置，获得更多商品信息"
    } else if type == .network { // 网络
        message = "请在\"设置-蜂窝移动网络\"选项中，允许\"\(appName)\"访问你的移动网络"
    } else if type == .microphone { // 麦克风
        message = "请在\"设置-隐私-麦克风\"选项中，允许\"\(appName)\"访问你的麦克风"
    }
    let url = URL(string: UIApplication.openSettingsURLString)
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
    let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
    let settingsAction = UIAlertAction(title:"前往", style: .default, handler: {
        (action) -> Void in
        if  UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url!, options: [:],completionHandler: {(success) in})
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    })
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)
    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
}
