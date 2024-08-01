//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation
import Combine
class TodosVM {
    
    // MARK: - step2
    // 가공된 최종 데이터
    var todos : [Todo] = [] {
        didSet {
            print(#fileID, #function, #line, "- ")
            self.notifyTodosChanged?(todos)
        }
    }
    
    // MARK: - step3
    var currentPage: Int = 1 {
        didSet {
            print(#fileID, #function, #line, "- ") // API 성공시 페이지가 바뀜 
            self.notifyCurrentPageChanged?(currentPage)
        }
    }
    
    var isLoading : Bool = false {
        didSet {
            print(#fileID, #function, #line, "- ")
            notifyLoadingStateChanged?(isLoading)
        }
    }
    
    // 데이터 변경 이벤트 - 클로저로 이벤트를 전달해주는 것임 변경되었다고
    var notifyTodosChanged : (([Todo]) -> Void)? = nil
    
    // 현재페이지 변경 이벤트
    var notifyCurrentPageChanged : ((Int) -> Void)? = nil
    
    // 로딩중 여부 변경 이벤트
    var notifyLoadingStateChanged : ((_ isLoading: Bool) -> Void)? = nil
    
    // 리프레시 완료 이벤트
    var notifyRefreshEnded : (() -> Void)? = nil
    
    init(){
        print(#fileID, #function, #line, "- ")
        
        fetchTodos()

    }
    
    
    /// 더 가져오기
    func fetchMore(){
        print(#fileID, #function, #line, "- ")
        self.fetchTodos(page: currentPage + 1)
     
    }
    
    
    // MARK: - step1
    /// 할일 가져오기
    /// - Parameter page: 페이지
    func fetchTodos(page: Int = 1){
        print(#fileID, #function, #line, "- <#comment#>")
        
        // 데이터 불러오는데 또 불러오지 못하게 처리
        if isLoading {
            print("로딩중입니다...")
            return
        }
        isLoading = true
        
        // 페이징 처리 한번 될때마다 딜레이 주기 없으면 바로바로 호출이 되는 것
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            
            // 서비스 로직
            TodosAPI.fetchTodos(page: page, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    // 페이지 갱신
                    self.currentPage = page
                    
                    if let fetchedTodos : [Todo] = response.data{
                        if page == 1 {
                            self.todos = fetchedTodos // 첫 페이지면 값을 넣고
                        } else {
                            self.todos.append(contentsOf: fetchedTodos) // 페이징 처리라면 기존 값에 값 추가
                        }
                       
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    
                }
                self.notifyRefreshEnded?() // 만약 새로고침으로 해당 메서드를 호출했다면 끝났다고 알림
                self.isLoading = false
                
            })
            
        })
      
        
    }
    
    /// 데이터 리프레시
    func fetchRefresh(){
        print(#fileID, #function, #line, "- ")
        self.fetchTodos(page: 1)
    }
    
    
    /// API 에러처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증안됨")
            case .decodingError:
                print("디코딩 에러입니당ㅇㅇ")
            default:
                print("default")
            }
        }
        
    }// handleError
    
}
