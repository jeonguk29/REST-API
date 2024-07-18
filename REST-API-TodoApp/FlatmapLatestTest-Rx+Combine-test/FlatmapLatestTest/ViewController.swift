//
//  ViewController.swift
//  FlatmapLatestTest
//
//  Created by Jeff Jeong on 2022/10/12.
//

import UIKit
import RxSwift
import RxCocoa
import Combine
import CombineCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var testBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        testBtn
        //            .rx
        //            .tap
        //            .subscribe(onNext: {
        //                print(#fileID, #function, #line, "- ")
        //            })
        //            .disposed(by: disposeBag)
        
        //        testBtn.rx.tap
        //            .scan(0) { aNumber, _ -> Int in
        //                return aNumber + 1
        //            }
        //            .flatMapLatest { tapNumber -> Observable<Int> in
        //                Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        //                    .do(onNext: { intervalNumber  in
        //                        print(#line, "tapNumber: \(tapNumber) - intervalNumber: \(intervalNumber)")
        //                    })
        //            }.subscribe(onNext: { intervalNumber in
        ////                print(#line, "result intervalNumber: \(intervalNumber)")
        //            })
        //            .disposed(by: disposeBag)
        
        
        
//        testBtn.tapPublisher // CombineCocoa가 지원
//            .handleEvents(receiveOutput: {
//                print("tapped")
//            })
//            .scan(0) { aNumber, _ -> Int in // T 들어오는값, 반환값
//                // tapPublisher로 이벤트가 들어오면 값을 활용하여 새로운 퍼블리셔 만들기
//                return aNumber + 1
//            }
//            .flatMap { tapNumber -> AnyPublisher<Int, Never> in
//                Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//                // 1초당 메인스레드에서 초를 증가시킴
//                    .scan(0) { aNumber, _ -> Int in
//                        return aNumber + 1
//                    }
//                    .handleEvents(receiveOutput: { intervalNumber in
//                        print(#line, "tapNumber: \(tapNumber) - intervalNumber: \(intervalNumber)")
//                    }).eraseToAnyPublisher()
//            }
//            .sink { resultNumber in
//                
//            }.store(in: &subscriptions)
        /*
         데이터 스트림이 끊기지 않고 새로운 데이터 스트림을 만들어 이어나감
         tapped
         64 tapNumber: 1 - intervalNumber: 1
         64 tapNumber: 1 - intervalNumber: 2
         64 tapNumber: 1 - intervalNumber: 3
         64 tapNumber: 1 - intervalNumber: 4
         tapped
         64 tapNumber: 1 - intervalNumber: 5
         64 tapNumber: 2 - intervalNumber: 1
         64 tapNumber: 1 - intervalNumber: 6
         64 tapNumber: 2 - intervalNumber: 2
         64 tapNumber: 1 - intervalNumber: 7
         64 tapNumber: 2 - intervalNumber: 3
         tapped
         64 tapNumber: 1 - intervalNumber: 8
         64 tapNumber: 2 - intervalNumber: 4
         64 tapNumber: 3 - intervalNumber: 1
         64 tapNumber: 1 - intervalNumber: 9
         64 tapNumber: 2 - intervalNumber: 5
         64 tapNumber: 3 - intervalNumber: 2
         64 tapNumber: 1 - intervalNumber: 10
         64 tapNumber: 2 - intervalNumber: 6
         */
        
        
        testBtn.tapPublisher // CombineCocoa가 지원
            .handleEvents(receiveOutput: {
                print("tapped")
            })
            .scan(0) { aNumber, _ -> Int in // T 들어오는값, 반환값
                // tapPublisher로 이벤트가 들어오면 값을 활용하여 새로운 퍼블리셔 만들기
                return aNumber + 1
            }
            .map { tapNumber -> AnyPublisher<Int, Never> in
                Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                // 1초당 메인스레드에서 초를 증가시킴
                    .scan(0) { aNumber, _ -> Int in
                        return aNumber + 1
                    }
                    .handleEvents(receiveOutput: { intervalNumber in
                        print(#line, "tapNumber: \(tapNumber) - intervalNumber: \(intervalNumber)")
                    }).eraseToAnyPublisher()
            }
            .switchToLatest() // 가장 최신의 받은 퍼블리셔만 돌려 받음
            .sink { resultNumber in
                
            }.store(in: &subscriptions)
        /*
         tapped
         111 tapNumber: 1 - intervalNumber: 1
         111 tapNumber: 1 - intervalNumber: 2
         111 tapNumber: 1 - intervalNumber: 3
         111 tapNumber: 1 - intervalNumber: 4
         tapped
         111 tapNumber: 2 - intervalNumber: 1
         111 tapNumber: 2 - intervalNumber: 2
         111 tapNumber: 2 - intervalNumber: 3
         111 tapNumber: 2 - intervalNumber: 4
         tapped
         111 tapNumber: 3 - intervalNumber: 1
         111 tapNumber: 3 - intervalNumber: 2
         111 tapNumber: 3 - intervalNumber: 3
         111 tapNumber: 3 - intervalNumber: 4
         */
        
        
        
    }
}
