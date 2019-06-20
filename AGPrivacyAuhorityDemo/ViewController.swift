//
//  ViewController.swift
//  AGPrivacyAuhorityDemo
//
//  Created by 高莹莹 on 2019/6/20.
//  Copyright © 2019 高莹莹. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
class ViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func buttonClick(_ btn: UIButton) {
        switch btn.tag {
        case 0: // 媒体库
            print("暂不需要")
        
            
        case 1: // 互联网

                
                ag_openEventServiceWithBolck(true) { (tag) in
                    DispatchQueue.main.async(execute: {
                        
                        if tag {
                            btn.setTitle("开启", for: .normal)
                        } else {
                            btn.setTitle("互联网没开启", for: .normal)
                        }
                    })
                    
                }
        case 2: // 定位
            ///首次必须开启相册权限
            
            ag_openLocationServiceWithBlock(true) { (tag) in
                DispatchQueue.main.async(execute: {
                    

                    if tag {
                        btn.setTitle("开启", for: .normal)
                    } else {
                        btn.setTitle("定位没开启", for: .normal)
                    }
                })
                
            }
        case 3: // 相册

            ag_openAlbumServiceWithBlock(true) { (tag) in
                DispatchQueue.main.async(execute: {
                    if tag {
                        btn.setTitle("开启", for: .normal)
                    } else {
                        btn.setTitle("相册没开启", for: .normal)
                    }
                })
            }
        case 4: // 相机
            ag_openCaptureDeviceServiceWithBlock(true) { (tag) in
                DispatchQueue.main.async(execute: {
                    
                    if tag {
                        btn.setTitle("开启", for: .normal)
                    } else {
                        btn.setTitle("相机没开启", for: .normal)
                    }
                })
            }
        case 5: // 麦克风
            ag_openRecordServiceWithBlock(true) { (tag) in
                DispatchQueue.main.async(execute: {
                    
                    if tag {
                        btn.setTitle("开启", for: .normal)
                    } else {
                        btn.setTitle("麦克风没开启", for: .normal)
                    }
                })
            }
            
            
        default:
            break
        }
    }


}

