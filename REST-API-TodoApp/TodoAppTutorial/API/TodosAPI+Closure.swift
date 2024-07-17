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
    
}
