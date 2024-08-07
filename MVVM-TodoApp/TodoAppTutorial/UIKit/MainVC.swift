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
    
    @IBOutlet var showAddTodoAlertBtn: UIButton!
    
    @IBOutlet var selectedTodosInfoLabel: UILabel!
    
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
    
    // 가져올 데이터가 없다 뷰
    lazy var bottomNoMoreDataView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0,
                                        width: myTableView.bounds.width,
                                        height: 60))
        let label = UILabel()
        label.text = "더 이상 가져올 데이터가 없습니다... 🐶"
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
        
        // 버튼 액션 설정
        self.showAddTodoAlertBtn.addTarget(self, action: #selector(showAddTodoAlert), for: .touchUpInside)
        
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
        
        // 다음페이지 존재 여부
        self.todosVM.notifyHasNextPage = { [weak self] hasNext in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- hasNext: \(hasNext)")
            DispatchQueue.main.async {
                self.myTableView.tableFooterView = !hasNext ? self.bottomNoMoreDataView : nil // 다음페이지 없으면 nil
            }
        }
        
        // 할일 추가완료
        self.todosVM.notifyTodoAdded = { [weak self] in
            guard let self = self else { return }
            print(#fileID, #function, #line, "")
            DispatchQueue.main.async {
                // 스크롤뷰를 처음으로 올림
                self.myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
        // 에러 발생시
        self.todosVM.notifyErrorOccured = { [weak self] errMsg in
            guard let self = self else { return }
            print(#fileID, #function, #line, "")
            DispatchQueue.main.async {
                self.showErrAlert(errMsg: errMsg)
            }
        }
        
        // 선택 아이템 변경 알림을 처리
        self.todosVM.notifySelectedTodoIdsChanged = { [weak self] selectedTodoIds in
            guard let self = self else { return }
            print(#fileID, #function, #line, "")
            DispatchQueue.main.async {
                
                // 안에 id 배열을 하나의 문자열로 만들어 대입
                let idsInfoString = selectedTodoIds.map{ "\($0)" }.joined(separator: ", ")
                
                self.selectedTodosInfoLabel.text = "선택된 할일들 : [" + idsInfoString + "]"
            }
            
        }
    }
}

//MARK: - 얼럿
extension MainVC {
    
   
    /// 할일 추가 얼럿 띄우기
    @objc fileprivate func showAddTodoAlert(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "추가", message: "할일을 입력해주세요", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "예) 빡코딩하기"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: { [weak alert] (_) in
            if let userInput = alert?.textFields?[0].text {
                print("userInput: \(userInput)")
                self.todosVM.addATodo(userInput)
            }
        })
        
        let closeAction = UIAlertAction(title: "닫기", style: .destructive)// .destructive 닫기는 빨간색 처리
        
        alert.addAction(closeAction)
        alert.addAction(confirmAction)

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 에러 얼럿 띄우기
    @objc fileprivate func showErrAlert(errMsg: String){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "안내", message: errMsg, preferredStyle: .alert)

        let closeAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(closeAction)
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 할일 삭제 얼럿 띄우기
    @objc fileprivate func showDeleteTodoAlert(_ id: Int){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "할일 삭제", message: "id:\(id) 할일을 삭제하시겠습니까?", preferredStyle: .alert)

        let submitAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            // 뷰모델 -> 해당 할일 삭제
            self.todosVM.deleteATodo(id)
        })
        
        let closeAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(submitAction)
        
        alert.addAction(closeAction)
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 할일 수정 얼럿 띄우기
    @objc fileprivate func showEditTodoAlert(_ id: Int, _ existingTitle: String){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "수정", message: "id: \(id)", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "예) 빡코딩하기"
            textField.text = existingTitle
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: { [weak alert] (_) in
            if let userInput = alert?.textFields?[0].text {
                print("userInput: \(userInput)")
                self.todosVM.editATodo(id, userInput)
            }
        })
        
        let closeAction = UIAlertAction(title: "닫기", style: .destructive)
        
        alert.addAction(closeAction)
        alert.addAction(confirmAction)

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
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
    
    /// 쎌의 삭제 버튼 클릭시
    /// - Parameter id: <#id description#>
    fileprivate func onDeleteItemAction(_ id: Int) {
        print(#fileID, #function, #line, "- id: \(id)")
        self.showDeleteTodoAlert(id)
    }
    
    /// 쎌의 수정 버튼 클릭시
    /// - Parameters:
    ///   - id: 아이디
    ///   - editedTitle: 변경된 타이틀
    fileprivate func onEditItemAction(_ id: Int, _ editedTitle: String) {
        print(#fileID, #function, #line, "- id: \(id), editedTitle: \(editedTitle)")
        self.showEditTodoAlert(id, editedTitle)
    }
    
    /// 쎌의 아이템 선택 이벤트
    /// - Parameters:
    ///   - id: 아이디
    ///   - isOn: 선택여부
    fileprivate func onSelectionItemAction(_ id: Int, _ isOn: Bool) {
        print(#fileID, #function, #line, "- id: \(id), isOn: \(isOn)")
        #warning("TODO : - 선택된 요소 변경하라고 뷰모델 한테 알리기")
        self.todosVM.handleTodoSelection(id, isOn: isOn)
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
        cell.updateUI(cellData, self.todosVM.selectedTodoIds)
        
       
        // 💁 2.Cell에서 이벤트 호출을 뷰컨에서 처리할 로직을 정의
//        cell.onDeleteActionEvent = {
//            print(#fileID, #function, #line, "- id: \($0)")
//            self.todosVM.deleteATodo($0)
//        }
        
        /*
         (Int) -> Void : 클로저가 들어옴 해당 클로저 부분을 함수로 바꿀수가 있는 것임
         클로저에 대한 부분을 위처럼 넣어도 되지만 cellForRowAt에 대한 부분이 너무 비대해짐 그래서 해당 부분을 함수로 빼서 넣어주는 방법이 좋음

         */
        cell.onDeleteActionEvent = onDeleteItemAction
        
        cell.onEditActionEvent = onEditItemAction
        
        cell.onSelectedActionEvent = onSelectionItemAction(_:_:)
        
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
