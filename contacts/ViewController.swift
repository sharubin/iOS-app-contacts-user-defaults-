//
//  ViewController.swift
//  contacts
//
//  Created by Artsem Sharubin on 27.11.2021.
//

import UIKit

class ViewController: UIViewController {
    private func loadContacts() {
        contacts = storage.load()
    }
    
    var contacts: [ContactProtocol] = [] {
        didSet {
            contacts.sort { $0.title < $1.title }
            //сохранение контактов в хранилище
            storage.save(contacts: contacts)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      storage = ContactStorage()
        loadContacts()
    }
    
    @IBOutlet var tableView: UITableView!
    @IBAction func showNewContactAlert() {
        //создание алерт контроллер
        let alertController = UIAlertController(title: "создайте новый контакт", message: "введите имя и телефон", preferredStyle: .alert)
        
        //добавляем первое текстовое поле в алерт контроллер
        alertController.addTextField { textField in
            textField.placeholder = "имя"
        }
        // добавляем второе текстовое поле в алерт контроллер
        alertController.addTextField { textField in
            textField.placeholder = "номер телефона"
            }
        // создаем кнопки
        // кнопка создания контакта
        let createButton = UIAlertAction(title: "создать", style: .default) { _ in
            guard let contactName = alertController.textFields?[0].text,
                  let contactPhone = alertController.textFields?[1].text else {
                      return
                  }
            // создаем новый контакт
            let contact = Contact(title: contactName, phone: contactPhone)
            self.contacts.append(contact)
            self.tableView.reloadData()
            }
        // кнопка отмены
        let cancelButton = UIAlertAction(title: "отменить", style: .cancel, handler: nil)
        
        //добавляем кнопки в alert controller
        alertController.addAction(cancelButton)
        alertController.addAction(createButton)
        
        //отображаем алерт контроллер
        self.present(alertController, animated: true, completion: nil)
    }
    var storage: ContactStorageProtocol!
    }

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell
    if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
    print("Используем старую ячейку для строки с индексом \(indexPath.row)")
    cell = reuseCell
    } else {
    print("Создаем новую ячейку для строки с индексом \(indexPath.row)")
    cell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
    }
    configure(cell: &cell, for: indexPath)
    return cell
    }
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        var configuration = cell.defaultContentConfiguration()
        // имя контакта
        configuration.text = contacts[indexPath.row].title
        //номер телефона контакта
        configuration.secondaryText = contacts[indexPath.row].phone
        cell.contentConfiguration = configuration
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // действие удаления
        let actionDelete = UIContextualAction(style: .destructive, title: "удалить") { _,_,_ in
            //удаляем контакт
            self.contacts.remove(at: indexPath.row)
            //заново формируем табличное представление
            tableView.reloadData()
        }
        //формируем экземпляр, описывающий доступные действия
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}
