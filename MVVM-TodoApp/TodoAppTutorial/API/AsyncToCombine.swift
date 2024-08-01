//
//  AsyncToCombine.swift
//  TodoAppTutorial
//
//  Created by 정정욱 on 7/26/24.
//

import Foundation
import Combine


//MARK: - Async to Combine
extension TodosAPI {
    
    
    /* 해당 코드랑 동일하다고 생각하면 이해하기 편함 위에코드
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
     */
    
    // Async 한번에 대한 이벤트를 퍼블리셔로 보내는것이기 때문에 Future를 사용
    static func fetchTodosAsyncToPublisher(page: Int) -> AnyPublisher<BaseListResponse<Todo>, Error> {
        
        return Future { (promise: @escaping (Result<BaseListResponse<Todo>, Error>) -> Void) in
            Task{
                do {
                    let asyncResult = try await fetchTodosWithAsync(page: page)
                    
                    promise(.success(asyncResult))
                    
                } catch {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
 
    
    
    // 위 코드를 편하게 사용하기 위한 제네릭 만들기
    // asyncWork 즉 어싱크 작업이 일어나는 함수 자체를 클로저로 매개변수로 넣으려는것임 
    static func genericAsyncToPublisher<T>(asyncWork: @escaping () async throws -> T) -> AnyPublisher<T, Error> {
        
        return Future { (promise: @escaping (Result<T, Error>) -> Void) in
            Task{
                do {
                    let asyncResult = try await asyncWork()
                    
                    promise(.success(asyncResult))
                    
                } catch {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// 퍼블리셔 흐림에서 중간에 async를 써야한다면 이런식도 가능 참고만 
extension Publisher {
    
    func mapAsync<T>(asyncWork: @escaping (Output) async throws -> T) -> Publishers.FlatMap<Future<T, Error>, Publishers.SetFailureType<Self, Error>> {
        
        return flatMap { output in
            return Future { (promise: @escaping (Result<T, Error>) -> Void) in
                Task{
                    do {
                        let asyncResult = try await asyncWork(output)
                        
                        promise(.success(asyncResult))
                        
                    } catch {
                        
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
}

