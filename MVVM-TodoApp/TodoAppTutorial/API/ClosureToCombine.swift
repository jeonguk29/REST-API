//
//  ClosureToCombine.swift
//  TodoAppTutorial
//
//  Created by 정정욱 on 7/22/24.
//

import Foundation
import Combine


//MARK: - Closure -> Publisher
extension TodosAPI {
    
    /// 에러 처리 O - 미션풀이
    /// Closure -> Publisher
    static func fetchATodoClosureToPublisher(id: Int) -> AnyPublisher<Todo?, Never> {
        
        return Future { (promise: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) in
            fetchATodo(id: id, completion: { promise($0) })// 클로저 축약 문법 아래랑 같음 
//            fetchATodo(id: id, completion: { result in
//                promise(result)
//            })
        }
        .map{ $0.data }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }
    
    /// 에러 처리 O
    /// Closure -> Publisher
    static func fetchTodosClosureToPublisher(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, ApiError> {
        
        // Future에서 outPut에 해당하는게 반환하려는 녀석임
        return Future { (promise: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) in
            fetchTodos(page: page, completion: { result in
                promise(result) // BaseListResponse<Todo>
                
                // 위 아래는 동일한 로직임 자료형이 같아서 위로직을 사용했지만 다르다면 아래로직으로 처리
                //                switch result {
                //                case .success(let data) :
                //                    promise(.success(data))
                //                case .failure(let failure) :
                //                    promise(.failure(failure))
                //                }
            })
        }.eraseToAnyPublisher()
    }
    
    /// 에러 처리 O - 에러 형태 변경
    /// Closure -> Publisher
    static func fetchTodosClosureToPublisherMapError(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, ApiError> {
        return Future { (promise: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) in
            fetchTodos(page: page, completion: { result in
                promise(result)
            })
        }.mapError({ err in
            if let urlErr = err as? ApiError { // 지금은 에러타입이 같아서 이렇게 처리했지만 Future안에서 들오는 에러타입이 반환 에러타입과 다른 경우 사용하면 유용
                return ApiError.unauthorized
            }
            return err
        })
        .eraseToAnyPublisher()
    }
    
    /// 에러 처리 X - []
    /// Closure -> Publisher
    static func fetchTodosClosureToPublisherNoError(page: Int = 1) -> AnyPublisher<[Todo], Never> {
        return Future { (promise: @escaping (Result<[Todo], Never>) -> Void) in
            fetchTodos(page: page, completion: { result in
                switch result {
                case .success(let data):
                    promise(.success(data.data ?? []))
                case .failure(let failure):
                    promise(.success([]))
                } // 리엑티브 프로그래밍을 하기때문에 이안에서 전부 가공할 필요가 없음 아래처럼 하는게 일반적
            })
        }.eraseToAnyPublisher()
    }
    
    
    /// 에러 처리 X - []
    /// Closure -> Publisher
    static func fetchTodosClosureToPublisherReturnArray(page: Int = 1) -> AnyPublisher<[Todo], Never> {
        return Future { (promise: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) in
            fetchTodos(page: page, completion: { result in
                promise(result)
            })
        }// 딱 Future끝나면 사실상 Result<BaseListResponse<Todo>, ApiError>가 나올것임
        .map{ $0.data ?? [] } // 형태변환 비어있으면 빈배열 던지기
        .catch({ err in
            return Just([]) // 에러면 Just같은거 사용해서 한번 쏘겠습니다
        })
        //        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
    
}
