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
        TodosAPI.fetchTodos { result in
            switch result { // 컴플리션 핸들러 즉 반환 타입을 체크
            case .success(let todosResponse):
                print("TodosVM - todosResponse: \(todosResponse)")
            case .failure(let failure):
                print("TodosVM - failure: \(failure)")
            }
        }//
    }// init
    
}
