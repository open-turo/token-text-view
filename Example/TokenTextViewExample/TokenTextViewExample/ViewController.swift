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

            let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
            toolbar.setItems([flexSpace, doneButton], animated: false)
            toolbar.sizeToFit()
            tokenTextView.inputAccessoryView = toolbar
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

    @objc func didTapDone() {
        tokenTextView.resignFirstResponder()
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
        tableView.deselectRow(at: indexPath, animated: false)
        let token = tokenList[indexPath.row]
        tokenTextView.insertToken(token)
    }


}
