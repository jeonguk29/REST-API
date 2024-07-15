//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation
import Combine
class TodosVM: ObservableObject {
    
    init(){
        print(#fileID, #function, #line, "- ")
//        TodosAPI.fetchTodos { [weak self] result in // 클로저를 사용하기 때문에 [weak self] 사용 : 강한 참조 없애기
//            
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        }//
        
//        TodosAPI.fetchATodo(id: 1550, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.searchTodos(searchTerm: "빡코딩") { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - search todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        }//
        
//        TodosAPI.addATodo(title: "유유유유유유유", isDone: false, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM addATodo - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.addATodoJson(title: "유유유유유유유2", isDone: false, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM addATodo - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
        TodosAPI.editTodoJson(id: 5427,
                              title: "유유유유333333",
                              isDone: true,
                              completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let aTodoResponse):
                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
            case .failure(let failure):
                print("TodosVM addATodo - failure: \(failure)")
                self.handleError(failure)
            }
        })
        
    }// init
    
    
 
    
    /// API 에러처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음") // 어떤 기능으로 처리를 해도됨 특정 뷰를 보여준다던지 등등
            case .unauthorized:
                print("인증안됨")
            default:
                print("default")
            }
        }
        
    }// handleError
}
