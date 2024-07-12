//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/09.
//

import Foundation
import UIKit
import SwiftUI


class MainVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
    }
    
}


// 3️⃣ UIViewController를 스유에서 활용가능하게 익스텐션 만들기
extension MainVC {
    
    // VCRepresentable는 스유뷰 자체를 말함 
    private struct VCRepresentable : UIViewControllerRepresentable {
        
        // 스유뷰로 만들 뷰컨을 정의
        let mainVC : MainVC
        
        // 스유에서는 값이 바뀌면 뷰를 업데이트함
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
        
        // 해당 뷰컨을 감쌓은 스유뷰 반환
        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    //뷰컨 자기 자신을 넣어 스유뷰를 반환하는 메서드
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}


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

