# AGPrivacyAuthority
1.Swift 检测隐私权限是否开启的管理工具  
2.集成了相机，相册，移动网络，定位，麦克风管理权限  
3.封装OpenURL可直接跳转到设置页面使用  
4.相册权限代码范例  
ag_openAlbumServiceWithBlock(true) { (tag) in  
                  DispatchQueue.main.async(execute: {  
                        if tag {  
                             btn.setTitle("开启", for: .normal)  
                        } else {  
                             btn.setTitle("相册没开启", for: .normal)  
                        }  
                    })  
              }


