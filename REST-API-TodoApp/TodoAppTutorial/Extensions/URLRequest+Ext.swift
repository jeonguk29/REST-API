//
//  URLRequest+Ext.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/22.
//

import Foundation

extension URLRequest {
    // 문자열 값을 인코딩해서 httpBody에 넣어줌
    // Put으로 수정할때 application/x-www-form-urlencoded 방식에서 활용
    
    private func percentEscapeString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
    
    // 자기 자신의 값을 변경하려면 mutating 들어가야함 URLRequest 구조체이기 때문
    /*
     구조체에서는 자기자신이 가진 멤버변수 값 변경할때 mutating을 사용해야함 클래스는 그냥 사용해도 괜찮음
     */
    mutating func percentEncodeParameters(parameters: [String : String]) {
        let parameterArray : [String] = parameters.map { (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(self.percentEscapeString(value))"
        }
        httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
