//
//  ClosureToAsync.swift
//  TodoAppTutorial
//
//  Created by 정정욱 on 7/22/24.
//

import Foundation
import Combine

//MARK: - Closure to Async
extension TodosAPI {
    
    /// 에러 처리 X - result - withCheckedContinuation를 사용
    /// Closure -> Async
    static func fetchTodosClosureToAsync(page: Int = 1) async -> Result<BaseListResponse<Todo>, ApiError> {
        return await withCheckedContinuation { (continuation: CheckedContinuation<Result<BaseListResponse<Todo>, ApiError>, Never>) in
            // 나오는 자료형 써주기
            
            // fetchTodos 클로저 함수를 호출
            fetchTodos(page: page, completion: { (result : Result<BaseListResponse<Todo>, ApiError>) in
                continuation.resume(returning: result)
                // resume은 Continuation블럭을 나가면서 Result 값이 Async로 나가는것
            })
        }
    }
    
    /// 에러 처리 X - [Todo]
    /// Closure -> Async
    static func fetchTodosClosureToAsyncReturnArray(page: Int = 1) async -> [Todo] {
        return await withCheckedContinuation { (continuation: CheckedContinuation<[Todo], Never>) in
            
            fetchTodos(page: page, completion: { (result : Result<BaseListResponse<Todo>, ApiError>) in
                
                switch result {
                case .success(let success):
                    continuation.resume(returning: success.data ?? [])
                case .failure(let _):
                    continuation.resume(returning: [])
                }
            })
        }
    }
    
    
    /// 에러 처리 O
    /// Closure -> Async
    static func fetchTodosClosureToAsyncWithError(page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        // 자체가 에러를 던지는거라 try 해줘야함
        // continuation에 반환타입 명시
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<BaseListResponse<Todo>, Error>) in
            
            fetchTodos(page: page, completion: { (result : Result<BaseListResponse<Todo>, ApiError>) in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            })
        })
    }
    
    /// 에러 처리 O - 에러 형태 변경
    /// Closure -> Async
    static func fetchTodosClosureToAsyncWithMapError(page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<BaseListResponse<Todo>, Error>) in
            
            fetchTodos(page: page, completion: { (result : Result<BaseListResponse<Todo>, ApiError>) in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                    
                    // resume으로 내던질때 에러 형태를 변경해서 던지면 되는것임
                case .failure(let failure):
                    
                    if let decodingErr = failure as? DecodingError {
                        continuation.resume(throwing: ApiError.decodingError)
                        return
                    }
                    
                    continuation.resume(throwing: ApiError.unknown(failure))
                }
            })
        })
    }
    
    /// 에러 처리 O - 미션 풀이
    /// Closure -> Async
    static func fetchATodoClosureToAsync(id: Int) async throws -> BaseResponse<Todo> {
        return try await withCheckedThrowingContinuation({ (continuation : CheckedContinuation<BaseResponse<Todo>, Error>) in
            fetchATodo(id: id, completion: { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success) // 성공은 실제 값이라 returning로 던지기
                case .failure(let failure):
                    continuation.resume(throwing: failure) // 에러 타입은 throwing로 던지기 
                }
            })
        })
    }
    
    /// 에러 처리 X - 미션 풀이
    /// Closure -> Async
    static func fetchATodoClosureToAsyncNoError(id: Int) async -> BaseResponse<Todo>? {
        return await withCheckedContinuation({ (continuation : CheckedContinuation<BaseResponse<Todo>?, Never>) in
            fetchATodo(id: id, completion: { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let _):
                    continuation.resume(returning: nil)
                }
            })
        })
    }
    
    /// 에러 처리 O - 미션 풀이 - 에러 형태 변경
    /// Closure -> Async
    static func fetchATodoClosureToAsyncMapError(id: Int) async throws -> BaseResponse<Todo> {
        return try await withCheckedThrowingContinuation({ (continuation : CheckedContinuation<BaseResponse<Todo>, Error>) in
            fetchATodo(id: id, completion: { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    
                    if let decodingErr = failure as? DecodingError {
                        continuation.resume(throwing: ApiError.decodingError)
                        return
                    }
                    
                    continuation.resume(throwing: failure)
                }
            })
        })
    }
    
}
