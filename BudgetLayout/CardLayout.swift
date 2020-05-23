//
//  File.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol CardLayout: class {
    
    // MARK: Variables
    
    var grabbedCardView: CardView? { set get }
    var presentedCardView: CardView? { set get }
    var contentInset: UIEdgeInsets { set get }
    
    // MARK: Layout
    
    func calculateLayoutValues(shouldLayoutView: Bool)
    func layoutCards(animationDuration: TimeInterval?, animationOptions: UIView.KeyframeAnimationOptions, placeVisibleCardViews: Bool, completion: ((Bool) -> ())?)
    func insert(cardViews: [CardView])
    
    // MARK: Presentation
    
    func present(_ cardView: CardView, animated: Bool, completion: ((Bool) -> ())?)
    func dismissPresentedCardView(_ animated: Bool, completion: ((Bool) -> ())?)

    // MARK: Grabbing
    
    func grab(_ cardView: CardView, popup: Bool)
    func updateGrabbedCardView(to offset: CGPoint)
    func releaseGrabbedCardView()
    
    
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
