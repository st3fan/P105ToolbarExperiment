// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit


let BUTTON_SIZE = CGSize(width: 60, height: 60)
let BUTTON_HORIZONTAL_SPACING: CGFloat = 8.0
let BUTTON_BOTTOM_MARGIN: CGFloat = 2.0

let LABEL_FONT_NAME: String = "FiraSans-UltraLight"
let LABEL_FONT_SIZE: CGFloat = 13.0


struct ToolbarItem
{
    var title: String
    var imageName: String
    var viewController: UIViewController
}

extension ToolbarItem
{
    static let Bookmarks = ToolbarItem(title: "Bookmarks", imageName: "Sofa", viewController: BookmarksViewController(nibName: "BookmarksViewController", bundle: nil))
    static let History = ToolbarItem(title: "History", imageName: "Sofa", viewController: HistoryViewController(nibName: "HistoryViewController", bundle: nil))
    static let Reader = ToolbarItem(title: "Reader", imageName: "Sofa", viewController: ReaderViewController(nibName: "ReaderViewController", bundle: nil))
    static let Settings = ToolbarItem(title: "Settings", imageName: "Sofa", viewController: SettingsViewController(nibName: "SettingsViewController", bundle: nil))
}

func maskedImageWithColor(mask: UIImage, color: UIColor) -> UIImage
{
    UIGraphicsBeginImageContextWithOptions(mask.size, false, 0.0)
    var context = UIGraphicsGetCurrentContext()
    var rect = CGRect(x: 0, y: 0, width: mask.size.width, height: mask.size.height)
    CGContextTranslateCTM(context,0.0,mask.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, mask.CGImage);
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

class ToolbarButtonView: UIView
{
    var item: ToolbarItem?
    var button: UIButton?
    var label: UILabel?
    
    func initialize(toolbarItem: ToolbarItem) {
        self.item = toolbarItem
        self.tintColor = UIColor.whiteColor()

        let image = UIImage(named: toolbarItem.imageName)
        
        self.button = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        button?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button?.setImage(maskedImageWithColor(image, UIColor.whiteColor()), forState: UIControlState.Normal)
        button?.setImage(maskedImageWithColor(image, UIColor.orangeColor()), forState: UIControlState.Selected)
        addSubview(self.button!)

        
        self.label = UILabel()
        label?.font = UIFont(name: LABEL_FONT_NAME, size: LABEL_FONT_SIZE)
        label?.textAlignment = NSTextAlignment.Center
        label?.text = toolbarItem.title
        label?.textColor = UIColor.whiteColor()
        label?.sizeToFit()
        addSubview(self.label!)
    }
    
    init(toolbarItem: ToolbarItem) {
        super.init(frame: CGRect(x: 0, y: 0, width: BUTTON_SIZE.width, height: BUTTON_SIZE.height))
        self.initialize(toolbarItem)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize(ToolbarItem.Bookmarks)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let button = self.button {
            button.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
            button.frame = CGRectOffset(button.frame, 0, -(button.frame.size.height/2) + 12)
        }

        if let label = self.label {
            label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
            label.frame = CGRectOffset(label.frame, 0, label.frame.size.height/2 + 10)
        }
    }
}


class ToolbarContainerView: UIView
{
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var origin = CGPoint(x: (frame.width - CGFloat(countElements(subviews) - 1) * BUTTON_SIZE.width - CGFloat(countElements(subviews) - 2) * BUTTON_HORIZONTAL_SPACING) / 2.0,
            y: (frame.height - BUTTON_SIZE.height) / 2.0)
        
        for view in subviews as [UIView] {
            if (view.frame.width == BUTTON_SIZE.width) {
                view.frame = CGRect(origin: origin, size: view.frame.size)
                origin.x += BUTTON_SIZE.width + BUTTON_HORIZONTAL_SPACING
            }
        }
    }
}


class ToolbarViewController: UIViewController
{
    var items: [ToolbarItem] = [ToolbarItem.Bookmarks, ToolbarItem.History, ToolbarItem.Reader, ToolbarItem.Settings]
    var buttonViews: [ToolbarButtonView] = []
    
    var _selectedButtonIndex: Int = -1
    
    var selectedButtonIndex: Int {
        get {
            return _selectedButtonIndex
        }
        set (newButtonIndex) {
            if (_selectedButtonIndex != -1) {
                if let currentButton = buttonViews[_selectedButtonIndex].button {
                    currentButton.selected = false
                }
            }

            if let newButton = buttonViews[newButtonIndex].button {
                newButton.selected = true
            }
            
            // Update the active view controller
            
            if let buttonContainerView = view.viewWithTag(1) {
                var onScreenFrame = view.frame
                onScreenFrame.size.height -= buttonContainerView.frame.height
                onScreenFrame.origin.y += buttonContainerView.frame.height
                
                var offScreenFrame = onScreenFrame
                offScreenFrame.origin.y += offScreenFrame.height

                if (_selectedButtonIndex == -1) {
                    var visibleViewController = items[newButtonIndex].viewController
                    visibleViewController.view.frame = onScreenFrame
                    addChildViewController(visibleViewController)
                    view.addSubview(visibleViewController.view)
                    visibleViewController.didMoveToParentViewController(self)
                } else {
                    var visibleViewController = items[_selectedButtonIndex].viewController
                    var newViewController = items[newButtonIndex].viewController
                    
                    visibleViewController.willMoveToParentViewController(nil)
                    
                    newViewController.view.frame = offScreenFrame
                    addChildViewController(newViewController)
                    
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                    
                    transitionFromViewController(visibleViewController, toViewController: newViewController, duration: 0.25, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
                        // Slide the visible controller down
                        visibleViewController.view.frame = offScreenFrame
                    }, completion: { (Bool) -> Void in
                        visibleViewController.view.removeFromSuperview()
                        self.view.addSubview(newViewController.view)
                        newViewController.view.frame = offScreenFrame
                        
                        UIView.animateWithDuration(0.25, animations: { () -> Void in
                            newViewController.view.frame = onScreenFrame
                        }, completion: { (Bool) -> Void in
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        })
                    })
                }
            }
            
            _selectedButtonIndex = newButtonIndex
        }
    }
    
    func tappedButton(sender: UIButton!) {
        for (index, buttonView) in enumerate(buttonViews) {
            if (buttonView.button == sender) {
                selectedButtonIndex = index
                break
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        if let buttonContainerView = view.viewWithTag(1) {
            for (index, item) in enumerate(items) {
                var toolbarButtonView = ToolbarButtonView(toolbarItem: item)
                buttonContainerView.addSubview(toolbarButtonView)
                toolbarButtonView.button?.addTarget(self, action: "tappedButton:", forControlEvents: UIControlEvents.TouchUpInside)
                buttonViews.append(toolbarButtonView)
            }

            selectedButtonIndex = 0
        }
    }
}
