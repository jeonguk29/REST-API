//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/09.
//

import Foundation
import UIKit
import SwiftUI


class MainVC: UIViewController{
    
    @IBOutlet weak var myTableView: UITableView!
    
    var dummyDataList = ["aaksjsfd", "asdfas", "asdfasdf", "sdfsdfa", "aaksjsfd", "asdfas", "asdfasdf", "sdfsdfa", "aaksjsfd", "asdfas", "asdfasdf", "sdfsdfa", "aaksjsfd", "asdfas", "asdfasdf", "sdfsdfa"]
    
    
    var todosVM: TodosVM = TodosVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
    }
}

extension MainVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        return cell
        
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



