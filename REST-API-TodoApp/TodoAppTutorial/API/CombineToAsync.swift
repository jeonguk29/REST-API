//
//  CombineToAsync.swift
//  TodoAppTutorial
//
//  Created by 정정욱 on 7/23/24.
//

import Foundation
import Combine

extension TodosAPI {
    // 구독 O
    // 받은 이벤트 기반으로 async 로 보냄
    /// combine -> async
    static func fetchTodosWithPublisherToAsync(page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        // 클로저를 Async 반환할때랑 동일한 방법임
        // 에러 던질거라 try 붙임
        return try await withCheckedThrowingContinuation({ (continuation : CheckedContinuation<BaseListResponse<Todo>, Error>) in
            
            var cancellable : AnyCancellable? = nil
            // 우리가 TodosAPI+Combine 에서는 구독을 하지않고 데이터 스트림 물줄기만 변경한거였음
            
            //1. 기존 publisher 이벤트를 구독 (cancellable는 sink 사용시 메모리 참조를 담아두고 구독 끝나면 메모리 참조까지 없애줄거임 )
            cancellable = fetchTodosWithPublisher(page: page)
                // 2. 들어온 이벤트의 결과에 따라 async 이벤트 처리
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("finished")
                    case .failure(let failure):
                        print("failure : \(failure)")
                        continuation.resume(throwing: failure) // 실패 응답을 반환
                    }
                    cancellable?.cancel() // API 호출 끝나면 메모리에서 날려주기
                }, receiveValue: { response in
                    print("receiveValue : \(response)")
                    continuation.resume(returning: response) // 값이 정상적으로 들어면 값을 반환
                })
        })
        
    }
}


// 위 방법을 확장으로 관리해서 편하게 사용하기
extension AnyPublisher {
    
    func toAsync() async throws -> Output {
        
        return try await withCheckedThrowingContinuation({ (continuation : CheckedContinuation<Output, Error>) in
            
            var cancellable : AnyCancellable? = nil
            
            //1. 기존 publisher 이벤트를 구독
            cancellable = first() // first() : 데이터 스트림에서 첫번째 값을 보내고 종료
                // 2. 들어온 이벤트의 결과에 따라 async 이벤트 처리
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        continuation.resume(throwing: failure)
                    }
                    cancellable?.cancel()
                }, receiveValue: { response in
                    continuation.resume(returning: response)
                })
        })
    }
}

//MARK: - Combine Retry
extension Publisher {
    
    
    func retryWithDelayAndCondition<T, E>(retryCount: Int = 1,
                                    delay: Int = 1,
                                    when: ((Error) -> Bool)? = nil
    ) -> Publishers.TryCatch<Self, AnyPublisher<T, E>> where T == Self.Output, E == Self.Failure {
        return self.tryCatch({ err -> AnyPublisher<T, E> in
                
            // 조건
            guard (when?(err) ?? true) else {
                throw err
            }
                
            return Just(Void())
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main) // 딜레이
                .flatMap { _ in
                    return self
                }
                .retry(retryCount - 1)
                .eraseToAnyPublisher()
            })
    }
    
}
