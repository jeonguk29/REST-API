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
    
    
    var isLoading : Bool = false {
        didSet {
            print(#fileID, #function, #line, "- ")
            notifyLoadingStateChanged?(isLoading)
        }
    }
    
    /// 검색어
    var searchTerm: String = "" {
        didSet {
            print(#fileID, #function, #line, "- searchTerm: \(searchTerm)")
            if searchTerm.count > 0 {
                self.searchTodos(searchTerm: searchTerm)
            } else {
                self.fetchTodos()
            }
        }
    }
    
    // pageInfo를 통해 값을 가져옴 currentPage를 부르기만 하면 아래 로직이 실행됨
    var currentPage: Int {
        get {
            if let pageInfo = self.pageInfo,
               let currentPage = pageInfo.currentPage {
                return currentPage
            } else {
                return 1 // pageInfo 값이 없다면
            }
        }
    }
    
    var pageInfo : Meta? = nil {
        didSet {
            print(#fileID, #function, #line, "- pageInfo: \(pageInfo)")
            
            // 다음페이지 있는지 여부 이벤트
            self.notifyHasNextPage?(pageInfo?.hasNext() ?? true)
            
            // 현재 페이지 변경 이벤트
            self.notifyCurrentPageChanged?(currentPage)
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
    
    // 검색결과 없음 여부 이벤트
    var notifySearchDataNotFound : ((_ noContent: Bool) -> Void)? = nil
    
    // 다음페이지 있는지  이벤트
    var notifyHasNextPage : ((_ hasNext: Bool) -> Void)? = nil
    
    //  할일 추가완료 이벤트
    var notifyTodoAdded : (() -> Void)? = nil
    
    //  에러발생 이벤트
    var notifyErrorOccured : ((_ errMsg: String) -> Void)? = nil
    
    
    init(){
        print(#fileID, #function, #line, "- ")
        
        fetchTodos()
        
    }
    
    
    /// 할일 검색하기
    /// - Parameters:
    ///   - searchTerm: 검색어
    ///   - page: 페이지
    func searchTodos(searchTerm: String, page: Int = 1){
        print(#fileID, #function, #line, "- <#comment#>")
        
        if searchTerm.count < 1 {
            print("검색어가 없습니다")
            return
        }
        
        if isLoading {
            print("로딩중입니다...")
            return
        }
        
        guard pageInfo?.hasNext() ?? true else {
            return print("다음페이지 없음")
        }
        
        self.notifySearchDataNotFound?(false)
        
        if page == 1 {
            self.todos = []
        }
  
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // 서비스 로직
            TodosAPI.searchTodos(searchTerm: searchTerm,
                                 page: page,
                                 completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.isLoading = false
                    // 페이지 갱신
                    if let fetchedTodos : [Todo] = response.data,
                       let pageInfo : Meta = response.meta{
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        self.pageInfo = pageInfo
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    self.isLoading = false
                    self.handleError(failure)
                }
                self.notifyRefreshEnded?()
            })
        })
    }
    
    /// 더 가져오기
    func fetchMore(){
        print(#fileID, #function, #line, "- ")
        
        // 다음페이지가 반드시 있어야 하고 로딩중이 아니여야 한다.
        guard let pageInfo = self.pageInfo,
              pageInfo.hasNext(),
              !isLoading else {
            return print("다음페이지가 없다")
        }
        
        if searchTerm.count > 0 { // 검색어가 있으면
            self.searchTodos(searchTerm: searchTerm, page: self.currentPage + 1)
        } else {
            self.fetchTodos(page: currentPage + 1)
        }
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
                    if let fetchedTodos : [Todo] = response.data,
                       let pageInfo : Meta = response.meta{
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        self.pageInfo = pageInfo // 응답으로 들어온 pageInfo
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    
                }
                self.notifyRefreshEnded?() // 만약 새로고침으로 해당 메서드를 호출했다면 끝났다고 알림
                self.isLoading = false
                
            })
            
        })
        
        
    }
    
    
    /// 할일추가
    /// - Parameter title: 할일 타이틀
    func addATodo(_ title: String) {
        print(#fileID, #function, #line, "- title: \(title)")
        
        if isLoading {
            print("로딩중이다")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.addATodoAndFetchTodos(title: title, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.isLoading = false
                // 페이지 갱신
                if let fetchedTodos : [Todo] = response.data,
                   let pageInfo : Meta = response.meta{
                    self.todos = fetchedTodos
                    self.pageInfo = pageInfo
                    self.notifyTodoAdded?()
                }
            case .failure(let failure):
                print("failure: \(failure)")
                self.isLoading = false
                self.handleError(failure)
            }
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
        
        guard let apiError = err as? TodosAPI.ApiError else {
            print("모르는 에러입니다.")
            return
        }
        
        print("handleError : err : \(apiError.info)")
        
        switch apiError {
        case .noContent:
            print("컨텐츠 없음")
            self.notifySearchDataNotFound?(true) // 검색결과 없으면 참으로 터트리기
        case .unauthorized:
            print("인증안됨")
        case .decodingError:
            print("디코딩 에러입니당ㅇㅇ")
        case .errResponseFromServer:
            print("서버에서 온 에러입니다 : \(apiError.info)") // 에러 관련 클로저를 여기서 터트려주기
            self.notifyErrorOccured?(apiError.info)
        default:
            print("default")
        }
        
        
    }// handleError
    
}
