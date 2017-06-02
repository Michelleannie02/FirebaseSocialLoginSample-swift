//
//  CustomTableView.swift
//  FirebaseSocialLoginSample
//
//  Created by S-SAKU on 2016/11/26.
//  Copyright © 2016年 S-SAKU. All rights reserved.
//

import UIKit

@IBDesignable

class CustomTableView: UITableView {


    @IBInspectable var bgFileName: String = "" {
        didSet {
            setupView()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setupView()
        }
    }

    //topLeft,topRight,bottomRight,bottomLeft
    @IBInspectable var RadiCorners: String = "true,true,true,true" {
        didSet {
            setupView()
        }
    }

    private func setupView() {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))

        let bundle = Bundle(for: self.classForCoder)


        if let image = UIImage(named: bgFileName  , in: bundle, compatibleWith: self.traitCollection) {
            imageView.image = image
        }

        self.addSubview(imageView)
        self.sendSubview(toBack: imageView)

        var corners:UIRectCorner
        corners = UIRectCorner.init(rawValue: 0)

        let aryStr = RadiCorners.characters.split(separator: ",").map { String($0)}
        let aryBool = aryStr.map{(a: String) -> Bool in
            Bool.init(a)!
        }

        for (idx,value) in aryBool.enumerated() {
            guard value else {
                continue
            }
            switch idx {
            case 0:
                corners.insert(.topLeft)
            case 1:
                corners.insert(.topRight)
            case 2:
                corners.insert(.bottomRight)
            case 3:
                corners.insert(.bottomLeft)
            default: break

            }
        }

        let path = UIBezierPath(roundedRect:self.bounds,
                                byRoundingCorners:corners,
                                cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
        self.setupView()
    }

}
