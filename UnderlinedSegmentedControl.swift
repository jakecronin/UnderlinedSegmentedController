//
//  UnderlinedSegmentedControl.swift
//  Paging Underlined Segmented Control
//
//  Created by Jake Cronin on 12/2/16.
//  Copyright © 2016 Jake Cronin. All rights reserved.
//

import UIKit

@IBDesignable class UnderlinedSegmentedControl: UIControl{
	
	private var underline = UIView()		//this is the view of the selectedLabel
	private var labels = [UILabel]()		//these labels are subviews to put onto the thumb, each representing a segment
	
	var itemNames: [String] = ["first", "second", "third"]{
		didSet{
			setupLabels()
		}
	}
	var selectedIndex: Int = 0{
		didSet{
			animateChangedSelection()
		}
	}
	var itemFont: UIFont = UIFont.systemFontOfSize(12){
		didSet{
			for label in labels{
				label.font = itemFont
			}

		}
	}
	
	//Selectable Properties editable directly from Attributes Inspector in Main Storyboard//////////////////
	@IBInspectable var selectedItemColor: UIColor = UIColor.blackColor(){
		didSet{
			changedColor()
		}
	}
	@IBInspectable var unselectedItemColor: UIColor = UIColor.brownColor(){
		didSet{
			changedColor()
		}
	}
	@IBInspectable var underlineColor: UIColor = UIColor.redColor(){
		didSet{
			changedColor()
		}
	}
	@IBInspectable var fontSize: CGFloat = 30{
		didSet{
			for label in labels{
				label.font = label.font.fontWithSize(fontSize)
			}

		}
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//SETUP FUNCTIONS//////////////////////////////////////////////////////////////////////////////////////////
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupSCView()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupSCView()
	}
	func setupSCView(){
		layer.cornerRadius = frame.height / 2
		layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
		layer.borderWidth = 2
		
		setupLabels() //set up the label views and add them as subviews to the segmented controller
		
		insertSubview(underline, atIndex: 0)
		
	}
	func setupLabels(){
		for label in labels{
			label.removeFromSuperview()	//remove all label views from segmented controller, so we have a blank slate
		}
		labels.removeAll(keepCapacity: true)	//empty labels array to make room for new labels
		
		for index in 0..<itemNames.count{
			let label = UILabel(frame: CGRectMake(0, 0, 40, 70))	//initialized at point (0,0) with hight 40, width 70
			label.text = itemNames[index]
			label.translatesAutoresizingMaskIntoConstraints = false
			label.textAlignment = .Center
			label.font = UIFont(name: "Avenir", size: 12)
			label.textColor = index == selectedIndex ? selectedItemColor : unselectedItemColor	//logic for selected or not
			self.addSubview(label)	//add label view as a subview to segmented view controller
			labels.append(label)	//add this newly created label to the array of labels
		}
		
		addConstraints(labels, scView: self, padding: 0)	//add constraints to all of the lables so they fit in the view controller nicely
	}	//build label views and add them to the scView, called by setupSCView
	func addConstraints(labels: [UIView], scView: UIView, padding: CGFloat){
		
		for (index, label) in EnumerateSequence(labels){	//for each label... set constraints
			//TOP CONSTRAINT
			var topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)	//set top of label to top of the segmented view
			
			//BOTTOM CONSTRAINT
			var bottomConstraint = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: scView, attribute: .Bottom, multiplier: 1.0, constant: 0)	//set bottom of label to bottom of segmented view
			
			//RIGHT CONSTRAINT
			var rightConstraint: NSLayoutConstraint
			if index == labels.count - 1{	//last label right side gets set to right edge of segmented view
				rightConstraint = NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: scView, attribute: .Right, multiplier: 1.0, constant: 0)
			}else{	//other labels have their right side set against neighbor label
				let buttonOnRight = labels[index + 1]
				rightConstraint = NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: buttonOnRight, attribute: .Left, multiplier: 1.0, constant: -padding)
			}
			
			//LEFT CONSTRAINT
			var leftConstraint: NSLayoutConstraint
			if index == 0{	//this is the first label, so left constarint set against left side of segmented view
				leftConstraint = NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: scView, attribute: .Left, multiplier: 1.0, constant: padding)
			}else{
				let buttonOnRight = labels[index-1]
				leftConstraint = NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: buttonOnRight, attribute: .Right, multiplier: 1.0, constant: padding)
			
				//WIDTH CONSTRAINT
				//now for each label (excluding the first label), set its width constraint equal to first label
				let firstItem = labels[0]
				var widthConstraint = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: firstItem, attribute: .Width, multiplier: 1.0  , constant: 0)
				scView.addConstraint(widthConstraint)
			}
			
			//ADD CONSTRAINTS TO THE SEGMENTED CONTROLLER
			scView.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
		}
	}	//add constraints to labels so they fit into segmented view controller nicely, called by setupLabels
	override func layoutSubviews() {
		super.layoutSubviews()
		let selectedLabel = self.labels[self.selectedIndex]
		let underlineHeight: CGFloat = 5
		let underlineOffset: CGFloat = 5
		let textFrame = self.frameOfTextInLabel(selectedLabel)
		
		self.underline.frame = CGRectMake(textFrame.minX, textFrame.maxY + underlineOffset, textFrame.width, underlineHeight)

		
		underline.backgroundColor = underlineColor
		underline.layer.cornerRadius = underline.frame.height / 2
		
		animateChangedSelection()
	}//used to get set position and size of 'selectedView' as we did not give it constraints
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	//RUNTIME FUNCTIONS//////////////////////////////////////////////////////////////////////////////////////////
	func animateChangedSelection(){
		for label in labels {	//give all labels 'unselected' color
			label.textColor = unselectedItemColor
		}
		var label = labels[selectedIndex]			//give seleted label the 'selected label' color
		label.textColor = selectedItemColor
		
		UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5 , initialSpringVelocity: 0.8, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
			let selectedLabel = self.labels[self.selectedIndex]
			let underlineHeight: CGFloat = 5
			let underlineOffset: CGFloat = 5
			let textFrame = self.frameOfTextInLabel(selectedLabel)
			
			self.underline.frame = CGRectMake(textFrame.minX, textFrame.maxY + underlineOffset, textFrame.width, underlineHeight)
			
			}, completion: nil)	//selected view slides over to the index that was selected
	}	//handle logic and animation when selectedIndex changes and we need to move the selectedView
	override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
		
		let location = touch.locationInView(self)	//tracks touches without our segmented view
		
		var calculatedIndex : Int?
		for (index, item) in EnumerateSequence(labels) {	//figure out which index was selected
			
			let frame = frameOfTextInLabel(item)//frameOfTextInLabel(item)
			if frameOfTextInLabel(item).contains(location) {
				calculatedIndex = index
			}
		}
		
		if calculatedIndex != nil {
			selectedIndex = calculatedIndex!	//when index is changed, animateChangedSelection is automatically called
			sendActionsForControlEvents(.ValueChanged)	//trigger any events hooked up to this segmented control
		}
		return false
	}
	func frameOfTextInLabel(label: UILabel) -> CGRect{
		
		let textSize = label.intrinsicContentSize()
		let xOffset = (label.frame.width - textSize.width) / 2
		let	x = label.frame.minX + xOffset
		
		let yOffset = (label.frame.height - textSize.height) / 2
		let y = label.frame.minY + yOffset
		
		let width = textSize.width
		let height = textSize.height
		//let y = label.textRectForBounds(label.frame, limitedToNumberOfLines: 0).minY
		//let yTop = label.textRectForBounds(self.frame, limitedToNumberOfLines: 0).minY
		//let yBottom =
		//let y = self.frame.minY //+ yOffset
		let toReturn = CGRectMake(x, y, width, height)
		return toReturn
	}
	
	private func changedColor(){
		for label in labels{
			label.textColor = unselectedItemColor
		}
		labels[selectedIndex].textColor = selectedItemColor
		underline.backgroundColor = underlineColor
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
}