//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation
import Combine
class TodosVM: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
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
        
//        TodosAPI.editTodoJson(id: 5427,
//                              title: "유유유유333333",
//                              isDone: true,
//                              completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM addATodo - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.editTodo(id: 5427,
//                              title: "유유유유5555555",
//                              isDone: true,
//                              completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM addATodo - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.deleteATodo(id: 5422,
//                              completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM deleteATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM deleteATodo - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
        
        /*
         서비스 레이아웃 쪽에서 이런 뷰컨이나 뷰모델이 API 호출하는데 최대한 모든걸 다 맡김 : 연쇄 호출 하는거 다 알아서 하고 값만 줘 
         */
//        TodosAPI.addATodoAndFetchTodos(
//                                title: "바바바가 추가함 하하하 0111",
//                                completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let todolistResponse):
//                print("TodosVM addATodoAndFetchTodos - todolistResponse: \(todolistResponse.data?.count)")
//            case .failure(let failure):
//                print("TodosVM addATodoAndFetchTodos - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
        
//        TodosAPI.deleteSelectedTodos(selectedTodoIds: [5430, 5424, 5425]) { [weak self] deletedTodos in
//            print("TodosVM deleteSelectedTodos - deletedTodos: \(deletedTodos)")
//            /*
//             deleteATodo에 출력부분이 이렇게 나옴 동시 호출 되는 것을 확인 할 수 있음 
//             TodoAppTutorial/TodosAPI.swift deleteATodo(id:completion:) 638 - deleteATodo 호출됨 / id: 5430
//             TodoAppTutorial/TodosAPI.swift deleteATodo(id:completion:) 638 - deleteATodo 호출됨 / id: 5424
//             TodoAppTutorial/TodosAPI.swift deleteATodo(id:completion:) 638 - deleteATodo 호출됨 / id: 5425
//             */
//            
//        }

        
        // [3037,3036] 중간에 없는거 하나 넣으면 TodosVM fetchSelectedTodos - failure: noContent를 반환
//        TodosAPI.fetchSelectedTodos(selectedTodoIds: [3933,3036], completion: { result in
//            switch result {
//            case .success(let data):
//                print("TodosVM fetchSelectedTodos - data: \(data)")
//            case .failure(let failure):
//                print("TodosVM fetchSelectedTodos - failure: \(failure)")
//            }
//        })
        
        
        TodosAPI.fetchTodosWithPublisherResult()
            .sink { result in
                switch result {
                case .failure(let failure) :
                    self.handleError(failure)
                case .success(let baseListTodoResponse):
                    print("TodosVM - fetchTodosWithPublisherResult: \(baseListTodoResponse)")
                }
            }.store(in: &subscriptions) // 찌꺼기 처리
        

        
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
