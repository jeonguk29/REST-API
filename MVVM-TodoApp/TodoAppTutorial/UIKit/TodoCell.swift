//
//  TodoCell.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/10.
//

import Foundation
import UIKit

class TodoCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    var cellData : Todo? = nil
    
    // 삭제액션
    var onDeleteActionEvent: ((Int) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
    }
    
    /// 썔 데이터 적용
    /// - Parameters:
    ///   - cellData : <#파라미터 설명#>
    func updateUI(_ cellData: Todo){
        
        guard var id : Int = cellData.id, var title : String = cellData.title else {
            print("id, title 이 없습니다.")
            return
        }
        self.cellData = cellData
        self.titleLabel.text = "아이디 \(id)"
        self.contentLabel.text = title
        
    }
    
    @IBAction func onEditBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- <#comment#>")
    }
    
    
    @IBAction func onDeleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- <#comment#>")
        
        // 💁 1.Cell에서 이벤트 호출
        guard let id = cellData?.id else { return }
        self.onDeleteActionEvent?(id) // 이벤트를 메인 뷰 컨트롤러에게 전달하는 것임 
        
    }
    
}
