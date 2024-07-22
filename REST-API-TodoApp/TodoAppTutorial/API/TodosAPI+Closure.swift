//
//  TodosAPI+Closure.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/22.
//

import Foundation
import MultipartForm

/*
 클로져를 활용한 연쇄 API 처리
 */
extension TodosAPI {
    
   
    /// ⭐️ 할일 추가 -> 모든 할일 가져오기
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodos(title: String,
                                      isDone: Bool = false,
                                      completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void){
        // 1
        self.addATodo(title: title, completion: { result in
            switch result {
                // 1-1
            case .success(_):
                // 2
                self.fetchTodos(completion: {
                    switch $0 {
                        // 2-1
                    case .success(let data):
                        completion(.success(data)) // 해당 컴플리션은 addATodoAndFetchTodos에서 정의한 것임
                        // 2-2
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                })
                // 1-2
            case .failure(let failure):
                completion(.failure(failure)) // 해당 컴플리션은 addATodoAndFetchTodos에서 정의한 것임
            }
        })
        
        /*
         tip ApiError 이렇게 커스텀에러 타입을 정의하는게 좋은게 이렇게 연쇄 처리를할때 한번에 핸들링이 가능함
         */
    }
    
    /// 클로져 기반 api 동시 처리 - 동시에 처리해서 빠르게 끝날수 있음
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    
    
    static func deleteSelectedTodos(selectedTodoIds: [Int],
                                    completion: @escaping ([Int]) -> Void){
        
   
        // 1. 디스패치 그룹 생성
        let group = DispatchGroup()
        
        // 성공적으로 삭제가 이뤄진 녀석들
        var deletedTodoIds : [Int] = [Int]()
        
        selectedTodoIds.forEach { aTodoId in
            
            // 2. 디스패치 그룹에 넣음
            group.enter()
            
            self.deleteATodo(id: aTodoId,
                             completion: { result in
                switch result {
                case .success(let response):
                    // 삭제된 아이디를 삭제된 아이디 배열에 넣는다
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                        print("inner deleteATodo - success: \(todoId)")
                    }
                case .failure(let failure):
                    print("inner deleteATodo - failure: \(failure)")
                }
                group.leave() // 작업 완료 - 삭제할걸 5개를 선택하면 5번 만큼 반복 실행하는데 동시처리를 해줌
            })// 단일 삭제 API 호출
        }
        
        // 4. 모든게 완료되면 해당 블럭이 실행
        // Configure a completion callback
        group.notify(queue: .main) {
            // All requests completed
            print("모든 api 완료 됨")
            completion(deletedTodoIds)
        }
    }
    
}

