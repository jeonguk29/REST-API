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
    
    @IBOutlet var pageInfoLabel: UILabel!
    
    var todos : [Todo] = []
    
    var todosVM: TodosVM = TodosVM()
    
    
    // 바텀 인디케이터뷰 : lazy 즉 사용할때 메모리에 올림
    lazy var bottomIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.systemBlue
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 44)
        return indicator
    }() // 클로저를 만들고 바로 호출해서 bottomIndicator안에 넣어준것
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        // 테이블뷰 설정
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.tableFooterView = bottomIndicator
        
        // MARK: - 뷰모델 설정 부분
        
        // 뷰모델 이벤트 받기 - 뷰 - 뷰모델 바인딩 - 묶기
        // 사실상 뷰모델에 클로저의 타입을 정의하고 값을 여기서 정의하여 함수를 실행하는 것
        self.todosVM.notifyTodosChanged = {  [weak self]  updatedTodos in
            guard let self = self else { return }
            self.todos = updatedTodos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        
        // 페이지 변경
        self.todosVM.notifyCurrentPageChanged = { [weak self] currentPage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.pageInfoLabel.text = "페이지 : \(currentPage)"
            }
        }
        
        // 뷰컨(뷰)는 변경이벤트 받기만 하고 UI 변경만 해주는 것임 즉 UI 바인딩만 처리
        // 로딩중 여부
        self.todosVM.notifyLoadingStateChanged = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.myTableView.tableFooterView = isLoading ? self.bottomIndicator : nil
                // 즉 로딩일때만 푸터뷰에 bottomIndicator를 넣어줘서 로딩뷰를 부름
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
            self.todosVM.fetchMore()
        }
    }
    
    
}
