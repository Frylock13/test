//
//  RecipesViewController.swift
//  Shandy
//
//  Created by Vitaliy on 25/09/2016.
//  Copyright © 2016 Vitaliy. All rights reserved.
//

import UIKit
import Alamofire

class RecipesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private(set) var _category: Category!
    
    var category: Category {
        get {
            return _category
        }
        set {
            _category = newValue
        }
    }
    
    var recipes: [Recipe] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = _category.name
        tableView.delegate = self
        tableView.dataSource = self
        
        downloadRecipesDataFromJson(category_id: _category.id)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? RecipeCell {
            
            let recipe = recipes[indexPath.row]
            
            cell.updateUI(recipe: recipe)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    
    func downloadRecipesDataFromJson(category_id: Int) {
        
        let recipesPath = "\(BASE_URL)/categories/\(category_id)/recipes.json"
        let recipesUrl = URL(string: recipesPath)!
        
        Alamofire.request(recipesUrl).responseJSON { response in
            debugPrint(response)     // prints detailed description of all response properties
            
            print("JSON: \(response.result.value)")
            
            self.addRecipesToAnArray(array: response.result.value as! NSArray)
        }
    }
    
    private func addRecipesToAnArray(array: NSArray) {
        for recipeDict in array {
            var ingredientsList: [String] = []
            
            if let dict = recipeDict as? NSDictionary {
                
                if let ingredients = dict["ingredients"] as? [Dictionary<String, AnyObject>] {
                    for obj in ingredients {
                        ingredientsList.append(obj["name"]! as! String)
                    }
                }
                let joinedIngredientsList = ingredientsList.joined(separator: ",")
                
                
                let recipe = Recipe(name: "\(dict["name"]!)", thumbUrl: "\(dict["thumb_url"]!)", ingredientsList: joinedIngredientsList, glassName: "\(dict["glass_name"]!)")
                
                self.recipes.append(recipe)
                self.tableView.reloadData()
            }
        }
    }
}
