//
//  EnvironmentListViewController.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 10/8/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import UIKit
import IntegratedPaymentSolutionSDK

class EnvironmentListViewController: UITableViewController {
    static let environmentListCellId = "EnvironmentListCell"
    static let showCheckoutSegueId = "ShowCheckoutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Select Environment"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.environmentListCellId, for: indexPath) as? EnvironmentListCell else {
            fatalError("Unable to dequeue \(Self.environmentListCellId)")
        }
        let name = AppDelegate.ENV_NAME
        cell.config(name: name)
        return cell
    }
}
