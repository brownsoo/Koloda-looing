//
//  ViewController.swift
//  KolodaLooping-Test
//
//  Created by hanhyonsoo on 2018. 3. 10..
//  Copyright © 2018 hansoo.labs. All rights reserved.
//

import UIKit
import Koloda

class ViewController: UIViewController {

    private var kolodaView: KolodaView!
    private let items = ["1", "2", "3", "4", "5"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.8, alpha: 1)
        kolodaView = KolodaView()
        view.addSubview(kolodaView)
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        kolodaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        kolodaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        kolodaView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        kolodaView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        kolodaView.isLoop = true
        kolodaView.appearanceAnimationDuration = 0.23
        kolodaView.countOfVisibleCards = 3
        kolodaView.delegate = self
        kolodaView.dataSource = self
    }
}

extension ViewController: KolodaViewDelegate {
    func kolodaDidResetCard(_ koloda: KolodaView) {
        print("kolodaDidResetCard")
    }

    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }

    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return true
    }

    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        return true
    }
}

extension ViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return items.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .slow
    }

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.down]
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card = CardView()
        card.title.text = "\(items[index]) card"
        return card
    }

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        print("didShowCardAt \(index)")
    }
}


private class CardView: UIView {

    static let defaultSize = CGSize(width: 290, height: 165)

    convenience public init() {
        self.init(frame: CGRect())
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInit()
    }

    private(set) var title: UILabel!

    private func onInit() {

        self.clipsToBounds = false
        self.layer.shadowColor =
                UIColor(red: CGFloat(79 / 255.0), green: CGFloat(132 / 255.0), blue: CGFloat(213 / 255.0), alpha: CGFloat(1)).cgColor
        self.layer.drawsAsynchronously = true
        self.layer.cornerRadius = 8
        self.backgroundColor = UIColor.white

        title = UILabel()
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: self.topAnchor, constant: 52).isActive = true
        title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 22).isActive = true
        title.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        title.textColor = UIColor.black

    }
}