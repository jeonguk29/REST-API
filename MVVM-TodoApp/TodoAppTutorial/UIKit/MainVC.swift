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
    
    var todos : [Todo] = []
    
    var todosVM: TodosVM = TodosVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        
        // 뷰모델 이벤트 받기 - 뷰 - 뷰모델 바인딩 - 묶기
        // 사실상 뷰모델에 클로저의 타입을 정의하고 값을 여기서 정의하여 함수를 실행하는 것
        self.todosVM.notifyTodosChanged = { updatedTodos in
            self.todos = updatedTodos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
    }
}

// 1. 갯수
// 2. 어떤 셀 보여줄지 정함
extension MainVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let cellData = self.todos[indexPath.row]
        
        // 데이터 썔에 넣어주기
        cell.updateUI(cellData)
        
        return cell
        
    }
}

extension MainVC {
    
    private struct VCRepresentable : UIViewControllerRepresentable {
        
        let mainVC : MainVC
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}

// 테이블 뷰의 이벤트를 위임받아 처리 하는 부분
extension MainVC : UITableViewDelegate {
    
    // 스크롤바 바닥 감지
    /// - Parameter scrollView:
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(#fileID, #function, #line, "- ")
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset // 바닥이랑 얼마정도 떨어져있는지 간격을 나타냄

        if distanceFromBottom - 200 < height {
            print("바닥이다")

        }
    }
    
    
}
