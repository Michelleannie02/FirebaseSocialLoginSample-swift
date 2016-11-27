//
//  BackGroundView.swift
//
//  Created by S-SAKU on 2016/11/26.
//  Copyright © 2016年 S-SAKU. All rights reserved.
//

import UIKit


@IBDesignable
class BackGroundView: UIView {
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

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
    @IBInspectable var RadiCorners: String = "false,false,false,false" {
        didSet {
            setupView()
        }
    }

    private var defaultBackgroundColor = UIColor.clear

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

    override public func prepareForInterfaceBuilder() {
        let processInfo = ProcessInfo.processInfo
        let environment = processInfo.environment
        let projectSourceDirectories : AnyObject = environment["IB_PROJECT_SOURCE_DIRECTORIES"]! as AnyObject
        let directories = projectSourceDirectories.components(separatedBy: ":")

        if directories.count != 0 {
            let firstPath = directories[0] as String
            let imagePath = firstPath.appending("/PrepareForIB/" + bgFileName)

            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))

            if let image = UIImage(contentsOfFile: imagePath){
                imageView.image = image
            }

            self.addSubview(imageView)
            self.sendSubview(toBack: imageView)

        }
    }

}


