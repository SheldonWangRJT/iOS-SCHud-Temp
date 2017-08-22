//
//  SCHudView.swift
//  SCHud
//
//  Created by Xiaodan Wang on 8/17/17.
//  Copyright © 2017 Xiaodan Wang. All rights reserved.
//

import UIKit

protocol UIViewProtocol {
}
extension UIView: UIViewProtocol {
}

protocol SCHudViewProtocol {
    var viewSize: SCViewSize { set get }
    var viewTheme: SCCubeTheme { set get }
    var titleDesc: String { set get }
    var titleAttributedText: NSMutableAttributedString? { set get }
    var cubeFaceAlpha: CGFloat { set get }
    var viewBackgroundColor: UIColor { set get }
    var viewBlurEffect: SCBlurEffect { set get }
    
    func show(to superView: UIView)
    func hide()
}

open class SCHudView: UIView, SCHudViewProtocol {

    //MARK: - properties
    //ContainerView contains cube
    @IBOutlet private var containerView: UIView!
    //Actual Cube View
    @IBOutlet private var cubeView: UIView!
    //Title is the descprition label
    @IBOutlet private var title: UILabel!
    //BottomSpacingView generates spaces from Title to the bottom
    @IBOutlet private var bottomSpacingView: UIView!
    //EffectView Related
    //BlurEffectView holds all the subviews
    @IBOutlet private var blurEffectView: UIVisualEffectView!
    //BlurEffectContantView
    @IBOutlet private var effectContantView: UIView!
    
    //Rotation transform
    private var rotationTransform: CATransform3D = CATransform3DIdentity
    private var cube3dLayer = CATransformLayer()
    
    //Style related
    //ViewSize sets the whole loading view size
    public var viewSize: SCViewSize = .medium
    //
    public var viewTheme: SCCubeTheme = .blackWhite {
        didSet {
            switch viewTheme {
            case .blackWhite:
                viewBackgroundColor = .white
            case .rainbow:
                viewBlurEffect = .dark
                viewBackgroundColor = .clear
            default:
                viewBackgroundColor = .white
                break
            }
        }
    }
    //TitleDesc will set the Title.text
    public var titleDesc: String {
        get {
            return title.text ?? ""
        }
        set {
            title.text = newValue
            title.isHidden = newValue.isEmpty ? true : false
            bottomSpacingView.isHidden = newValue.isEmpty ? true : false
        }
    }
    //TitleAttributedText will set up attributedText for the title label
    public var titleAttributedText: NSMutableAttributedString?
    
    //CubeFaceAlpha will set the alpha for all the cube faces
    public var cubeFaceAlpha: CGFloat = 0.7
    
    //ViewBackGroundColor will set the whole view background color
    //Note: other color than clear will disable the blur effect
    public var viewBackgroundColor: UIColor = .clear {
        didSet {
            if viewBackgroundColor != .clear {
                applyShadow()
                blurEffectView.effect = nil
            } else {
                removeShadow()
            }
            effectContantView.backgroundColor = viewBackgroundColor
        }
    }
    
    //ViewBlurEffect will set the blur effect for whole view
    public var viewBlurEffect: SCBlurEffect = .dark {
        didSet {
            switch viewBlurEffect {
            case .none:
                blurEffectView.effect = nil
            case .extraLight:
                blurEffectView.effect = UIBlurEffect(style: .extraLight)
            case .light:
                blurEffectView.effect = UIBlurEffect(style: .light)
            case .dark:
                blurEffectView.effect = UIBlurEffect(style: .dark)
            }
        }
    }
    
    //MARK: - initialization
    public init() {
        super.init(frame: CGRect.zero)
        initXibFile()
        initStyle()
        initTransform()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initXibFile()
        initStyle()
        initTransform()
    }
    
    private func initXibFile() {
        if let view = Bundle(for: SCHudView.self).loadNibNamed(String(describing: SCHudView.self), owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.frame = bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    
    private func initStyle() {
        applyShadow()
        title.adjustsFontSizeToFitWidth = true
        title.isHidden = true
        bottomSpacingView.isHidden = true
    }
    
    private func initTransform() {
        rotationTransform.m34 = 1 / -600
    }
    
    private func applyShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
    }
    
    private func removeShadow() {
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    // Create font style
    private func setAttributedString(for theme: SCCubeTheme, with title: String) -> NSMutableAttributedString {
        let attriTitle = NSMutableAttributedString(string: title)
        switch theme {
        case .blackWhite:
            let range = NSRange(location: 0, length: title.characters.count)
            attriTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
            return attriTitle
        case .rainbow:
            let rainbowColors: [UIColor] = [
                UIColor.white
            ]
            for (ind, _) in title.characters.enumerated() {
                let range = NSRange(location: ind, length: 1)
                let colorInd: Int = ind % rainbowColors.count
                attriTitle.addAttribute(NSForegroundColorAttributeName, value: rainbowColors[colorInd], range: range)
            }
            return attriTitle
        case .custom(_, _, _, _, _, _, _):
            return titleAttributedText ?? attriTitle
        }
    }
    
    // MARK: - create cube
    private func createCube(with theme: SCCubeTheme) {
        var faceAndEdgeColors: [UIColor]
        switch theme {
        case .blackWhite:
            faceAndEdgeColors = [
                UIColor.black,
                UIColor.clear,
                UIColor.black,
                UIColor.clear,
                UIColor.clear,
                UIColor.clear,
                UIColor.black  // edge color
            ]
        case .rainbow:
            faceAndEdgeColors = [
                UIColor.red,
                UIColor.blue,
                UIColor.yellow,
                UIColor.green,
                UIColor.orange,
                UIColor.purple,
                UIColor.white  // edge color
            ]
        case .custom(let color1, let color2, let color3, let color4, let color5, let color6, let edgeColor):
            faceAndEdgeColors = [
                color1,
                color2,
                color3,
                color4,
                color5,
                color6,
                edgeColor  // edge color
            ]
        }
        createCubeFaces(with: faceAndEdgeColors)
    }
    
    private func createCubeFaces(with colors: [UIColor]) {
        if colors.count == 7 {
            createTransformLayer(colors)
        }
        else {
            Utility.log(message: "6 colors are required to render all the cube surfaces")
            fatalError("6 colors are required to render all the cube surfaces")
        }
    }
    
    private func createTransformLayer(_ colors: [UIColor]) {
        let BORDERWIDTH: CGFloat = 1
        
        // MARK: - internal function calculate frame
        func calculateCubeFrame() -> CGRect {
            //If description label text is not empty
            if frame.height > frame.width {
                return CGRect(
                    x:0,
                    y:0,
                    width:frame.height-25-50-15-BORDERWIDTH*2, //width equals height
                    height:frame.height-25-50-15-BORDERWIDTH*2 //height is self.frame - label height - top & bot cube view space - stack view space - border with offset (2 * 2)
                )
            }
            else {
                return CGRect(
                    x:0,
                    y:0,
                    width:frame.width-50-BORDERWIDTH*2,
                    height:frame.height-50-BORDERWIDTH*2
                )
            }
        }
        
        let FRAME: CGRect = calculateCubeFrame()
        let CUBEWIDTH: CGFloat = FRAME.size.width
        // Create a transform layer
        let transformLayer:CATransformLayer = CATransformLayer()
        transformLayer.frame = FRAME
        let centralPoint:CGPoint = CGPoint(x: transformLayer.bounds.size.width/2.0, y: transformLayer.bounds.size.height/2.0)

        // MARK: - internal function set style
        func setStyle(for layer: CALayer, with color: UIColor) {
            layer.frame = FRAME
            layer.position = centralPoint
            layer.borderWidth = BORDERWIDTH
            layer.borderColor = colors[6].cgColor
            layer.backgroundColor =
                color == .clear ?
                color.cgColor :
                color.withAlphaComponent(cubeFaceAlpha).cgColor
        }
        
        // Note: rotate will also rotate the x-y-z coordinates system
        // to rotate it of 90° along the y axis and translate it
        let degrees:CGFloat = 90.0
        let radians:CGFloat = degrees * CGFloat.pi / 180
        
        // This is the font side of the cube
        let layer0 = CALayer()
        setStyle(for: layer0, with: colors[0])
        
        // This is the right side.
        let layer1 = CALayer()
        setStyle(for: layer1, with: colors[1])
        var tempTransform: CATransform3D = CATransform3DIdentity
        tempTransform = CATransform3DRotate(tempTransform, radians, 0, 1, 0)
        tempTransform = CATransform3DTranslate(tempTransform, 0, 0, CUBEWIDTH/2.0)
        tempTransform = CATransform3DTranslate(tempTransform, CUBEWIDTH/2.0, 0.0, 0.0)
        layer1.transform = tempTransform
        
        // This is the back side of the cube.
        let layer2 = CALayer()
        setStyle(for: layer2, with: colors[2])
        tempTransform = CATransform3DIdentity
        tempTransform = CATransform3DTranslate(tempTransform, 0.0, 0.0, -CUBEWIDTH)
        layer2.transform = tempTransform
        
        // This is the left side of the cube.
        let layer3 = CALayer()
        setStyle(for: layer3, with: colors[3])
        tempTransform = CATransform3DIdentity
        tempTransform = CATransform3DRotate(tempTransform, radians, 0.0, 1.0, 0.0)
        tempTransform = CATransform3DTranslate(tempTransform, 0, 0, -CUBEWIDTH/2.0)
        tempTransform = CATransform3DTranslate(tempTransform, CUBEWIDTH/2.0, 0.0, 0.0)
        layer3.transform = tempTransform

        // This is the top side of the cube.
        let layer4 = CALayer()
        setStyle(for: layer4, with: colors[4])
        tempTransform = CATransform3DIdentity
        tempTransform = CATransform3DTranslate(tempTransform, 0, 0, -CUBEWIDTH/2.0)
        tempTransform = CATransform3DTranslate(tempTransform, 0, -CUBEWIDTH/2.0, 0)
        tempTransform = CATransform3DRotate(tempTransform, radians, 1.0, 0.0, 0.0)
        layer4.transform = tempTransform
        
        // This is the bot side of the cube
        let layer5 = CALayer()
        setStyle(for: layer5, with: colors[5])
        tempTransform = CATransform3DIdentity
        tempTransform = CATransform3DTranslate(tempTransform, 0, 0, -CUBEWIDTH/2.0)
        tempTransform = CATransform3DTranslate(tempTransform, 0, CUBEWIDTH/2.0, 0)
        tempTransform = CATransform3DRotate(tempTransform, radians, 1.0, 0.0, 0.0)
        layer5.transform = tempTransform
        
        transformLayer.addSublayer(layer0)
        transformLayer.addSublayer(layer1)
        transformLayer.addSublayer(layer2)
        transformLayer.addSublayer(layer3)
        transformLayer.addSublayer(layer4)
        transformLayer.addSublayer(layer5)
        
        // Move the anchorPoint at the center of the cube
        transformLayer.anchorPointZ = -CUBEWIDTH/2.0
        
        cube3dLayer = transformLayer
        cubeView.layer.addSublayer(cube3dLayer)
    }

    @objc private func rotateCube() {
        rotationTransform = CATransform3DRotate(rotationTransform, CGFloat.pi * 4.5 / 180.0, 0.0, 1.0, 0.0)
        cube3dLayer.transform = rotationTransform
    }

    /// Use this function to show the cube onto the desired view
    public func show(to superView: UIView) {
        DispatchQueue.main.async {
            let edgeLength = superView.frame.width * self.viewSize.rawValue
            self.frame.size = CGSize(
                width: edgeLength,
                height: self.titleDesc.isEmpty ? edgeLength : edgeLength + 25 + 15
            )
            self.center = superView.center
            self.createCube(with: self.viewTheme)
            self.title.attributedText = self.setAttributedString(for: self.viewTheme, with: self.titleDesc)
            superView.addSubview(self)
            _ = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.rotateCube), userInfo: nil, repeats: true)
        }
    }
    
    public func hide() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
//    open class func printSomething() {
//        Utility.log(message: "hello world")
//    }
}
