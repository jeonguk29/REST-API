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
    // 데이터 변경 이벤트 - 클로저로 이벤트를 전달해주는 것임 변경되었다고
    var notifyTodosChanged : (([Todo]) -> Void)? = nil
    
    init(){
        print(#fileID, #function, #line, "- ")
        
        fetchTodos()
    }
    
    
    // MARK: - step1
    /// 할일 가져오기
    /// - Parameter page: 페이지
    func fetchTodos(page: Int = 1){
        print(#fileID, #function, #line, "- <#comment#>")
        

        // 서비스 로직
        TodosAPI.fetchTodos(page: page, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                
                if let fetchedTodos : [Todo] = response.data{
                    self.todos = fetchedTodos
                }
            case .failure(let failure):
                print("failure: \(failure)")
                
            }
            
        })
        
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
