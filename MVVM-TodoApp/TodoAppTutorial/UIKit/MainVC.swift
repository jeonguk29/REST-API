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
    
    @IBOutlet var searchBar: UISearchBar!
    
    // 바텀 인디케이터뷰 : lazy 즉 사용할때 메모리에 올림
    lazy var bottomIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.systemBlue
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 44)
        return indicator
    }() // 클로저를 만들고 바로 호출해서 bottomIndicator안에 넣어준것
    
    // 새로고침을 위한 refreshControl
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        //        refreshControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) // 크기 변경
        refreshControl.tintColor = .systemBlue.withAlphaComponent(0.5)
        //        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침") // 표시할 문자열
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    // 검색결과를 찾지 못했다 뷰
    lazy var searchDataNotFoundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0,
                                        width: myTableView.bounds.width,
                                        height: 300))
        let label = UILabel()
        label.text = "검색결과를 찾을 수 없습니다 🗑️"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    var searchTermInputWorkItem : DispatchWorkItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        // 테이블뷰 설정
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.refreshControl = refreshControl
        self.myTableView.tableFooterView = bottomIndicator
   
        // ===
        // 서치바 설정
        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        // .editingChanged 글자 입력이 되었을때 실행될 이벤트 처리 Enum이라 다양한 값이 있음
        // ===
        
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
        
        // 당겨서 새로고침 완료
        // 💁 2.뷰모델한테 시키고난 다음 이벤트 받고 처리
        self.todosVM.notifyRefreshEnded = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        
        // 검색결과 없음 여부
        self.todosVM.notifySearchDataNotFound = { [weak self] notFound in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- notFound: \(notFound)")
            DispatchQueue.main.async {
                self.myTableView.backgroundView = notFound ? self.searchDataNotFoundView : nil
            }
        }
        
    }
}

//MARK: - 액션들
extension MainVC {
    /// 리프레시 처리
    /// - Parameter sender:
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        print(#fileID, #function, #line, "- ")
        
        // 💁 1.뷰모델한테 시키기
        self.todosVM.fetchRefresh()
    }
    
    /// 검색어가 입력되었다
    /// - Parameter sender:
    @objc fileprivate func searchTermChanged(_ sender: UITextField){
        print(#fileID, #function, #line, "- sender: \(String(describing: sender.text))")
        
        // - DispatchWorkItem는 특정 작업 블록을 나타내는 객체로, 이 작업을 큐에 제출하여 실행할 수 있습니다.
        // 검색어가 입력되면 기존 작업 취소
        searchTermInputWorkItem?.cancel()
        
        // 작업 하나를 생성
        let dispatchWorkItem = DispatchWorkItem(block: {
            // 백그라운드 - 사용자 입력 userInteractive (스레드를 바꿔줌 사용자가 입력할때)
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async { [weak self] in
                    guard let userInput = sender.text,
                          let self = self else { return }
                    
                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: \(userInput)")
                    #warning("TODO : - 검색 API 호출하기")
                    self.todosVM.todos = []
                    // 뷰모델 검색어 갱신
                    self.todosVM.searchTerm = userInput
                }
            }
        })
        
        // 기존작업을 나중에 취소하기 위해(또 글자를 입력한다면) 메모리 주소 일치 시켜줌
        self.searchTermInputWorkItem = dispatchWorkItem
        
        // ⭐️ 글자를 입력할때마다 땡기는건 너무 비효율적이라 글자 입력후 일정 시간이 흐른다음 땡겨오게 만든 것임(만든 작업을 실행)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
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
