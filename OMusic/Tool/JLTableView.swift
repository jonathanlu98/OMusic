//
//  JLTableView.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/9/17.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class JLTableView: UITableView {

    private var headView: (UIView & JLTableHeaderViewProtocol)?
    
    override private init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, style: UITableView.Style, headView: (UIView & JLTableHeaderViewProtocol)) {
        super.init(frame: frame, style: style)
    }
    
}




