import uuid
import random
from datetime import datetime, timedelta
import json
import os

# Using the specified location codes
locations = ['HF-AMB', 'HF-CLD', 'HF-FIN', 'HF-FLV', 'SH-CLD']

# Packaging types with sizes
packaging_types = {
    'Plastic Bottles': ['PET 200ml', 'PET 1L', 'PET 1.85L'],
    'Cups': ['150g'],
    'Tubs': ['500g', '1kg'],
    'Bucket': ['1kg', '2.25kg', '5kg', '10kg', '16kg'],
    'Tray': ['Yoghurt 150g (6 pcs)']
}

# Statuses limited to specified values
statuses = ['Available', 'Out of Stock', 'Discontinued']

# Function to generate dummy inventory data for dairy and juice products
def generate_inventory_data(num_records=300):
    categories = ['Raw Materials', 'Dairy', 'Juices', 'Packaging']
    subcategories = {
        'Raw Materials': ['Milk', 'Cream', 'Fruit Concentrates', 'Sugar', 'Stabilizers', 
                         'Orange juice concentrate', 'Processed water', 'Citric acid', 'Stevia',
                         'Lemon Base', 'Dry Sugar', 'Water', 'Crystalline fructose', 
                         'Anhydrous citric acid', 'Ascorbic acid', 'Carrageenan gum',
                         'Riboflavin', 'Silicon dioxide', 'Clouding agent', 'Lemon flavor'],
        'Dairy': ['Plain Milk', 'Flavored Milk', 'Laban', 'Yogurt', 'Cheese', 'Butter', 'Ice Cream'],
        'Juices': ['Pomegranate Juice', 'Orange Juice', 'Apple Juice', 'Mango Juice', 
                   'Pineapple Juice', 'Strawberry Juice', 'Blueberry Juice', 'Mixed Fruit',
                   'Orange Nectar 50% Juice', 'Orange Juice Beverage 30% Juice',
                   'Orange Beverage 8% Juice', 'Orange Beverage 4% Juice',
                   'Ready-To-Drink Lemon Drink 12% Brix', 'Beverage Powder Mix'],
        'Packaging': []  # Will be filled dynamically
    }
    units = {
        'Raw Materials': ['kg', 'liters', 'tons'],
        'Dairy': ['liters', 'kg', 'pieces'],
        'Juices': ['liters', 'bottles', 'packs'],
        'Packaging': ['pieces', 'boxes', 'units']
    }

    # Dynamically create packaging subcategories with sizes
    for pack_type, sizes in packaging_types.items():
        for size in sizes:
            subcategories['Packaging'].append(f"{pack_type} {size}")

    inventory_data = []
    
    # Distribute records across categories
    records_per_category = num_records // len(categories)
    extra_records = num_records % len(categories)
    
    category_counts = {category: records_per_category for category in categories}
    
    # Distribute any extra records
    for i in range(extra_records):
        category_counts[categories[i]] += 1
    
    for category, count in category_counts.items():
        for i in range(count):
            if category == 'Packaging':
                product_name = random.choice(subcategories['Packaging'])
            else:
                product_name = random.choice(subcategories[category])

            # Create a product code based on category and random number
            category_code = category[0:2].upper()
            if category == 'Raw Materials':
                category_code = 'RM'
            elif category == 'Packaging':
                category_code = 'PA'
            product_code = f"{category_code}{random.randint(1000, 9999)}"

            record = {
                'id': str(uuid.uuid4()),
                'product_code': product_code,
                'product_name': product_name,
                'category': category,
                'unit_of_measure': random.choice(units[category]),
                'quantity_on_hand': random.randint(0, 1000),
                'location': random.choice(locations),
                'status': random.choice(statuses)
            }
            inventory_data.append(record)
    
    return inventory_data

# Fixed recipes based on 1000 liter/kg scale
fixed_recipes = {
    'Orange Nectar 50% Juice': [
        {'ingredient_name': 'Orange juice concentrate', 'quantity_required': 95.2, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Processed water', 'quantity_required': 904.8, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Citric acid', 'quantity_required': 5.8, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stevia', 'quantity_required': 0.5, 'unit_of_measure': 'kg'}
    ],
    'Orange Juice Beverage 30% Juice': [
        {'ingredient_name': 'Orange juice concentrate', 'quantity_required': 57.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Processed water', 'quantity_required': 943.0, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Citric acid', 'quantity_required': 4.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stevia', 'quantity_required': 0.6, 'unit_of_measure': 'kg'}
    ],
    'Orange Beverage 8% Juice': [
        {'ingredient_name': 'Orange juice concentrate', 'quantity_required': 15.2, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Processed water', 'quantity_required': 984.8, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Citric acid', 'quantity_required': 3.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stevia', 'quantity_required': 0.65, 'unit_of_measure': 'kg'}
    ],
    'Orange Beverage 4% Juice': [
        {'ingredient_name': 'Orange juice concentrate', 'quantity_required': 7.6, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Processed water', 'quantity_required': 992.4, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Citric acid', 'quantity_required': 2.2, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stevia', 'quantity_required': 0.7, 'unit_of_measure': 'kg'}
    ],
    'Ready-To-Drink Lemon Drink 12% Brix': [
        {'ingredient_name': 'Lemon Base', 'quantity_required': 30.8, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Dry Sugar', 'quantity_required': 70.4, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Water', 'quantity_required': 898.8, 'unit_of_measure': 'kg'}
    ],
    'Beverage Powder Mix for 1000L': [
        {'ingredient_name': 'Crystalline fructose', 'quantity_required': 35.3, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Anhydrous citric acid', 'quantity_required': 3.66, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Ascorbic acid', 'quantity_required': 0.28, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Carrageenan gum', 'quantity_required': 0.06, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Riboflavin', 'quantity_required': 0.01, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Silicon dioxide', 'quantity_required': 0.2, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Clouding agent', 'quantity_required': 0.13, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Lemon flavor', 'quantity_required': 0.21, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stevia', 'quantity_required': 0.24, 'unit_of_measure': 'kg'}
    ],
    'Plain Yogurt': [
        {'ingredient_name': 'Milk', 'quantity_required': 970.0, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Milk powder', 'quantity_required': 30.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stabilizer', 'quantity_required': 5.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Yogurt culture', 'quantity_required': 2.0, 'unit_of_measure': 'kg'}
    ],
    'Flavored Milk': [
        {'ingredient_name': 'Milk', 'quantity_required': 930.0, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Sugar', 'quantity_required': 60.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Flavor', 'quantity_required': 10.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Stabilizer', 'quantity_required': 2.0, 'unit_of_measure': 'kg'}
    ],
    'Laban': [
        {'ingredient_name': 'Milk', 'quantity_required': 980.0, 'unit_of_measure': 'L'},
        {'ingredient_name': 'Laban culture', 'quantity_required': 15.0, 'unit_of_measure': 'kg'},
        {'ingredient_name': 'Salt', 'quantity_required': 5.0, 'unit_of_measure': 'kg'}
    ]
}

# Function to generate dummy recipe data using fixed 1000 liter/kg scale recipes
def generate_recipe_data_fixed(inventory_data, num_recipes=100):
    recipe_data = []
    
    # Use our fixed recipes as much as possible
    recipe_count = 0
    
    # First use all our fixed recipes
    for recipe_name, ingredients in fixed_recipes.items():
        recipe_code = f"R{random.randint(1000, 9999)}"
        product_code = f"P{random.randint(1000, 9999)}"  # Dummy finished product code

        for step_num, ingredient in enumerate(ingredients, 1):
            record = {
                'id': str(uuid.uuid4()),
                'recipe_code': recipe_code,
                'recipe_name': recipe_name,
                'product_code': product_code,
                'ingredient_code': f"I{random.randint(1000, 9999)}",
                'ingredient_name': ingredient['ingredient_name'],
                'quantity_required': ingredient['quantity_required'],
                'unit_of_measure': ingredient['unit_of_measure'],
                'step_number': step_num,
                'instructions': ''  # No instructions as requested
            }
            recipe_data.append(record)
        
        recipe_count += 1
    
    # Generate more random recipes if needed to reach the target number
    raw_materials = [item for item in inventory_data if item['category'] == 'Raw Materials']
    dairy_products = [item for item in inventory_data if item['category'] == 'Dairy']
    juice_products = [item for item in inventory_data if item['category'] == 'Juices']
    finished_products = dairy_products + juice_products
    
    remaining_recipes = num_recipes - recipe_count
    
    for i in range(remaining_recipes):
        if finished_products:
            product = random.choice(finished_products)
            product_code = product['product_code']
            product_name = product['product_name']
            recipe_code = f"R{random.randint(1000, 9999)}"
            recipe_name = f"Recipe for {product_name}"
            
            # Each recipe has 3-7 ingredients
            num_ingredients = random.randint(3, 7)
            if len(raw_materials) >= num_ingredients:
                ingredients = random.sample(raw_materials, num_ingredients)
                
                for step_num, ingredient in enumerate(ingredients, 1):
                    quantity = round(random.uniform(1.0, 100.0), 2)
                    record = {
                        'id': str(uuid.uuid4()),
                        'recipe_code': recipe_code,
                        'recipe_name': recipe_name,
                        'product_code': product_code,
                        'ingredient_code': ingredient['product_code'],
                        'ingredient_name': ingredient['product_name'],
                        'quantity_required': quantity,
                        'unit_of_measure': ingredient['unit_of_measure'],
                        'step_number': step_num,
                        'instructions': ''  # No instructions as requested
                    }
                    recipe_data.append(record)
    
    return recipe_data

# Function to generate dummy machines data with the specified locations
def generate_machines_data(num_records=18):
    # Machine types specific to dairy and juice production
    types = [
        'Homogenizer', 'Separator', 'Pasteurizer', 'UHT Processing Unit', 
        'Batch Mixer', 'Continuous Freezer', 'Filling Machine', 'CIP System',
        'Fruit Pulping Machine', 'Juice Extractor', 'Vacuum Concentrator',
        'Aseptic Filling Machine', 'Standardization Unit', 'Cream Processing Unit'
    ]
    
    statuses = ['Operational', 'Under Maintenance', 'Out of Service', 'Scheduled Maintenance']
    
    manufacturers = ['Alfa Laval', 'GEA', 'Tetra Pak', 'APV', 'SPX', 
                     'Tetrapak', 'Technogel', 'Promag', 'Carpigiani']
    
    machines_data = []
    for _ in range(num_records):
        machine_type = random.choice(types)
        manufacturer = random.choice(manufacturers)
        machine_name = f"{manufacturer} {machine_type} {random.choice(['A', 'B', 'C', 'D', 'E', ''])}-{random.randint(100, 999)}"
        
        # Create maintenance dates
        last_maintenance = datetime.now() - timedelta(days=random.randint(1, 365))
        next_maintenance = last_maintenance + timedelta(days=random.randint(30, 180))
        
        record = {
            'id': str(uuid.uuid4()),
            'machine_code': f"M{random.randint(1000, 9999)}",
            'machine_name': machine_name,
            'type': machine_type,
            'manufacturer': manufacturer,
            'location': random.choice(locations),
            'status': random.choice(statuses),
            'last_maintenance_date': last_maintenance.strftime('%Y-%m-%d'),
            'next_maintenance_due': next_maintenance.strftime('%Y-%m-%d')
        }
        machines_data.append(record)
    return machines_data

# Function to generate dummy suppliers data
def generate_suppliers_data(num_records=700):
    # Saudi cities
    cities = ['Riyadh', 'Jeddah', 'Dammam', 'Mecca', 'Medina', 'Al Khobar', 'Tabuk', 'Abha']
    
    # Supplier categories
    categories = [
        'Raw Milk', 'Fruit Suppliers', 'Packaging Materials', 'Food Additives',
        'Processing Equipment', 'Dairy Ingredients', 'Logistics Services'
    ]
    
    # Known dairy and food companies in Saudi Arabia
    known_suppliers = [
        'Almarai', 'SADAFCO', 'NADEC', 'Arla Foods', 'Danone SA', 
        'Al-Othman Holding', 'BEL SA', 'Nestlé SA', 'Juice World',
        'Al Rawabi Dairy', 'Gulf & Safa Dairies', 'Al Ain Farms'
    ]
    
    supplier_statuses = ['Active', 'Inactive', 'On Hold', 'New']
    
    suppliers_data = []
    
    # First add the known suppliers
    for supplier in known_suppliers:
        supplier_category = []
        if 'Dairy' in supplier or supplier in ['Almarai', 'SADAFCO', 'NADEC', 'Arla Foods', 'Danone SA']:
            supplier_category.append('Raw Milk')
            supplier_category.append('Dairy Ingredients')
        if 'Juice' in supplier or supplier == 'Almarai':
            supplier_category.append('Fruit Suppliers')
        
        if not supplier_category:  # If no category was assigned
            supplier_category = [random.choice(categories)]
        
        record = {
            'id': str(uuid.uuid4()),
            'supplier_code': f"S{random.randint(1000, 9999)}",
            'supplier_name': supplier,
            'address': f"{random.randint(100, 999)} {random.choice(['King Fahd Rd', 'King Abdullah Rd', 'Industrial Area'])}, {random.choice(cities)}",
            'phone': f"+966-{random.randint(10, 99)}-{random.randint(100, 999)}-{random.randint(1000, 9999)}",
            'email': f"info@{supplier.lower().replace(' ', '')}.com.sa",
            'product_categories': supplier_category,
            'status': random.choice(supplier_statuses)
        }
        suppliers_data.append(record)
    
    # Generate remaining generic suppliers
    for i in range(len(suppliers_data), num_records):
        supplier_name = f"Saudi {random.choice(['Foods', 'Dairy', 'Packaging', 'Juice', 'Distribution'])} Company {random.randint(1, 999)}"
        category = random.choice(categories)
        
        record = {
            'id': str(uuid.uuid4()),
            'supplier_code': f"S{random.randint(1000, 9999)}",
            'supplier_name': supplier_name,
            'address': f"{random.randint(100, 999)} {random.choice(['Industrial City', 'Business District', 'Commercial Area'])}, {random.choice(cities)}",
            'phone': f"+966-{random.randint(10, 99)}-{random.randint(100, 999)}-{random.randint(1000, 9999)}",
            'email': f"info@{supplier_name.lower().replace(' ', '').replace('&', 'and')}.com.sa",
            'product_categories': [category],
            'status': random.choice(supplier_statuses)
        }
        suppliers_data.append(record)
    
    return suppliers_data

# Function to split inventory by category
def split_inventory_by_category(inventory_data):
    categories = {}
    for item in inventory_data:
        category = item['category'].lower().replace(' ', '_')
        if category not in categories:
            categories[category] = []
        categories[category].append(item)
    return categories

# Function to save data to separate files
def save_to_separate_files(data_dict):
    # Create output directory if it doesn't exist
    if not os.path.exists('output'):
        os.makedirs('output')
    
    # Split inventory data by category and save to separate files
    inventory_by_category = split_inventory_by_category(data_dict['inventory'])
    for category, items in inventory_by_category.items():
        filename = f"output/{category}_inventory.json"
        with open(filename, 'w') as f:
            json.dump({item['id']: item for item in items}, f, indent=2)
        print(f"Generated {len(items)} {category} inventory items -> {filename}")
    
    # Save recipes, machines, and suppliers to separate files
    with open('output/recipes.json', 'w') as f:
        json.dump({item['id']: item for item in data_dict['recipes']}, f, indent=2)
    print(f"Generated {len(data_dict['recipes'])} recipe steps -> output/recipes.json")
    
    with open('output/machines.json', 'w') as f:
        json.dump({item['id']: item for item in data_dict['machines']}, f, indent=2)
    print(f"Generated {len(data_dict['machines'])} machines -> output/machines.json")
    
    with open('output/suppliers.json', 'w') as f:
        json.dump({item['id']: item for item in data_dict['suppliers']}, f, indent=2)
    print(f"Generated {len(data_dict['suppliers'])} suppliers -> output/suppliers.json")

# Generate all datasets with specified quantities
inventory = generate_inventory_data(300)
recipes = generate_recipe_data_fixed(inventory, 100)
machines = generate_machines_data(18)
suppliers = generate_suppliers_data(700)

# Create a dictionary with all data
all_data = {
    'inventory': inventory,
    'recipes': recipes,
    'machines': machines,
    'suppliers': suppliers
}

# Save data to separate files
save_to_separate_files(all_data)
