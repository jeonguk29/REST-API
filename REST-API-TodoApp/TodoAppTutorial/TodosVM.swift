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
        
        
//        TodosAPI.fetchTodosWithPublisherResult()
//            .sink { result in
//                switch result {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .success(let baseListTodoResponse):
//                    print("TodosVM - fetchTodosWithPublisherResult: \(baseListTodoResponse)")
//                }
//            }.store(in: &subscriptions) // 찌꺼기 처리
//        
        
        
        
        // 에러가 들어올수도 있어서 receiveCompletion, receiveValue 있는걸로 처리
//        TodosAPI.fetchTodosWithPublisher()
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리
//            
//            
        
//        TodosAPI.addATodoAndFetchTodosWithPublisher(title: "값을 추가해보자")
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리
        
        
//        TodosAPI.addATodoAndFetchTodosWithPublisherNoError(title: "값을 추가해보자")
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)") // 에러면 빈 배열이 들어옴
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리

//        TodosAPI.addATodoAndFetchTodosWithPublisherNoErrorSwitchToLatest(title: "SwitchToLatest를 사용해보자 ")
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)") // 에러면 빈 배열이 들어옴
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리
        
//        TodosAPI.deleteSelectedTodosWithPublisherMergeWithError(selectedTodoIds: [3036, 3035, 3031])
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리
        
        /*
         TodoAppTutorial/TodosAPI+Combine.swift deleteATodoWithPublisher(id:) 611 - deleteATodo 호출됨 / id: 3036
         TodoAppTutorial/TodosAPI+Combine.swift deleteATodoWithPublisher(id:) 611 - deleteATodo 호출됨 / id: 3035
         TodoAppTutorial/TodosAPI+Combine.swift deleteATodoWithPublisher(id:) 611 - deleteATodo 호출됨 / id: 3031
         TodosVM - response: 3036
         TodosVM - response: 3035
         TodosVM - response: 3031
         
         응답도 3번, 중간에 에러나면 데이터 스트림 끊어짐
         3개 다 존재하지 않는걸로 보내면
         handleError : err : 데이터가 없습니다. 한번 응답받고 끝남
         */
        
        
        
//        TodosAPI.deleteSelectedTodosWithPublisherMerge(selectedTodoIds: [5423, 3033, 5415])
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리
        /*
         TodosVM - response: 3034
         TodosVM - response: 3064
         실제 삭제된것만 응답 받음 3031은 없는 데이터임 
         
         */
        
//        TodosAPI.deleteSelectedTodosWithPublisherZip(selectedTodoIds: [5414, 5418, 5413, 3333])
//            .sink( receiveCompletion : { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .failure(let failure) :
//                    self.handleError(failure)
//                case .finished:
//                    print("TodosVM - finished")
//                }
//            }, receiveValue: { response in
//                print("TodosVM - response: \(response)")
//            })
//            .store(in: &subscriptions) // 찌꺼기 처리
//        // TodosVM - response: [5414, 5418, 5413] Zip은 이렇게 묶어서 한번에 들어옴, 삭제된것만 들어옴 3333은 없는 데이터임
        
        
//        Task { // 비동기 처리 작업의 한 단위
//            let response = await TodosAPI.fetchTodosWithAsyncResult()
//            print("fetchTodosWithAsyncResult response: \(response)")
//        }
        
        Task { // 비동기 처리 작업의 한 단위
            do {
                let response = try await TodosAPI.fetchTodosWithAsync()
                print("fetchTodosWithAsyncResult response: \(response)")
            } catch {
                self.handleError(error)
            }
     
        }
        
    }// init
    
    
 
    
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
