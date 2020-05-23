//
//  File.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol CardLayout: class {
    
    var grabbedCardView: CardView? { set get } // needed
    var presentedCardView: CardView? { set get } // needed
    
    var contentInset: UIEdgeInsets { set get } // needed
    
    func calculateLayoutValues(shouldLayoutView: Bool) // needed
    func updateContentSize()
    func layoutCards(animationDuration: TimeInterval?, animationOptions: UIView.KeyframeAnimationOptions, placeVisibleCardViews: Bool, completion: ((Bool) -> ())?) // needed
    func makeStackLayout()
    func makeCollapseLayout(collapsePresentedCardView: Bool)
    func placeVisibleCardViews()
    func insert(cardViews: [CardView]) // needed
    
    func grab(_ cardView: CardView, popup: Bool) // needed
    func updateGrabbedCardView(to offset: CGPoint) // needed
    func releaseGrabbedCardView() // needed
    
    func present(_ cardView: CardView, animated: Bool, completion: ((Bool) -> ())?) // needed
    func dismissPresentedCardView(_ animated: Bool, completion: ((Bool) -> ())?) // needed

    
}

extension CardLayout {
    
    func layoutCards(animationDuration: TimeInterval? = nil, animationOptions: UIView.KeyframeAnimationOptions = [.beginFromCurrentState, .calculationModeCubic], placeVisibleCardViews: Bool = true, completion: ((Bool) -> ())? = nil) {
        layoutCards(animationDuration: animationDuration, animationOptions: animationOptions, placeVisibleCardViews: placeVisibleCardViews, completion: completion)
    }
    
    func calculateLayoutValues(shouldLayoutView: Bool = true) {
        calculateLayoutValues(shouldLayoutView: shouldLayoutView)
    }
    
    func present(_ cardView: CardView, animated: Bool, completion: ((Bool) -> ())? = nil) {
        present(cardView, animated: animated, completion: completion)
    }
    
    func dismissPresentedCardView(_ animated: Bool, completion: ((Bool) -> ())? = nil) {
        dismissPresentedCardView(animated, completion: completion)
    }
    
}


struct Constants {
    static let presentingAnimationDuration: TimeInterval = 0.35
    static let dismissingAnimationDuration: TimeInterval = 0.35
    static let grabbingAnimationDuration: TimeInterval = 0.2
}
