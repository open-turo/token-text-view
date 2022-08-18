//
//  ViewController.swift
//  TokenTextViewExample
//
//  Created by Chris Lee on 8/11/22.
//

import UIKit

class TokenTextViewExampleController: UIViewController {
    @IBOutlet private var tokenTextView: TokenTextView! {
        didSet {
            tokenTextView.layer.borderColor = UIColor.black.cgColor
            tokenTextView.layer.borderWidth = 1.0
        }
    }
    @IBOutlet private var tokenListTableView: UITableView!

    private let tokenList = MockDataLoader.loadMockTokenList() ?? []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tokenTextView.tokenList = tokenList
    }

    @IBAction func didTapGenerateTemplatedTextButton(_ sender: Any) {
        let templatedText = tokenTextView.templatedText
        let alertController = UIAlertController(title: nil, message: templatedText, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Done", style: .cancel))
        present(alertController, animated: true)
    }
}

extension TokenTextViewExampleController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tokenList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()
        tableViewCell.textLabel?.text = tokenList[indexPath.row].name
        return tableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let token = tokenList[indexPath.row]
        tokenTextView.insertToken(token)
    }


}
