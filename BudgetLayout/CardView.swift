//
//  CardView.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    weak var budgetList: BudgetList? {
        return container()
    }
    
    var isPresented: Bool = false
    
    // MARK: Gesture Recognizers
    let tapGestureRecognizer = UITapGestureRecognizer()
    let panGestureRecognizer = UIPanGestureRecognizer()
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupCard()
        self.setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupCard()
        self.setupGestures()
    }
    
    private func setupCard() {
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
    }
    
    private func setupGestures() {
        
        self.tapGestureRecognizer.addTarget(self, action: #selector(self.tapped))
        self.tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.tapGestureRecognizer)
        
        self.panGestureRecognizer.addTarget(self, action: #selector(self.panned(_:)))
        self.panGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.panGestureRecognizer)
        
        self.longPressGestureRecognizer.addTarget(self, action: #selector(self.longPressed(_:)))
        self.longPressGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.longPressGestureRecognizer)
        
    }
    
    // MARK: Gesture Handlers
    
    @objc private func tapped() {
        if let _ = self.budgetList?.currentLayout?.presentedCardView {
            self.budgetList?.currentLayout?.dismissPresentedCardView(true)
        }
        else {
            self.budgetList?.currentLayout?.present(self, animated: true)
        }
    }
    
    @objc private func panned(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            self.budgetList?.currentLayout?.grab(self, popup: false)
        case .changed:
            self.updateGrabbedCardViewOffset(using: gestureRecognizer)
        default:
            self.budgetList?.currentLayout?.releaseGrabbedCardView()
        }
        
    }
    
    @objc private func longPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            self.budgetList?.currentLayout?.grab(self, popup: true)
        case .changed:
            ()
        default:
            self.budgetList?.currentLayout?.releaseGrabbedCardView()
        }
        
    }
    
    private func updateGrabbedCardViewOffset(using gestureRecognizer: UIPanGestureRecognizer) {
        let offset = gestureRecognizer.translation(in: self.budgetList)
        
        var directionalOffset = offset.y
        
        if let _ = self.budgetList?.currentLayout as? HorizontalCardLayout {
            directionalOffset = offset.x
        }
        
        if self.isPresented && directionalOffset > 0 {
            self.budgetList?.currentLayout?.updateGrabbedCardView(to: offset)
        } else if !self.isPresented {
            self.budgetList?.currentLayout?.updateGrabbedCardView(to: offset)
        }
    }
    
}

extension CardView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.longPressGestureRecognizer && self.isPresented {
            return false
        }
        else if gestureRecognizer == self.panGestureRecognizer && !self.isPresented && self.budgetList?.currentLayout?.grabbedCardView != self {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer != self.tapGestureRecognizer && otherGestureRecognizer != self.tapGestureRecognizer
    }
    
}

internal extension UIView {
    
    func container<T: UIView>() -> T? {
        
        var view = superview
        
        while view != nil {
            if let view = view as? T {
                return view
            }
            view = view?.superview
        }
        
        return nil
    }
    
}

