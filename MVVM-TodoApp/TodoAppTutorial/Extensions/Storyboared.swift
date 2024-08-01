//
//  Storyboared.swift
//  TodoAppTutorial
//
//  Created by 정정욱 on 8/1/24.
//

import Foundation
import UIKit

extension UIViewController : StoryBoarded {} // 2️⃣ 뷰컨은 해당 프로토콜을 준수한다 확장으로 정의
// 이렇게 해주면 모든 뷰컨마다 스토리보드, 스토리보드아이디, 파일 이름을 같게 가져올 수 있다.

//1️⃣ 해당 스토리보드 이름으로 뷰컨을 생성해주는 프로토콜
protocol StoryBoarded {
    static func instantiate(_ storyboardName: String?) -> Self
}

// 프로토콜 확장으로 기본 기능을 정의
extension StoryBoarded {
    
    static func instantiate(_ storyboardName: String? = nil) -> Self {
        
        let name = storyboardName ?? String(describing: self)
        
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)// 스토리보드 이름 가져와 생성
        
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}
