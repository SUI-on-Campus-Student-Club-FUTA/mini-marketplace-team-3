[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=20748796&assignment_repo_type=AssignmentRepo)

# Sui Move Mini Marketplace Project Specification

This project is designed for students to practice and improve their skills. The structure below is a suggested starting point; you are free to modify it as needed.

## Project Overview
Build a mini marketplace using Sui Move where users can list items for sale, browse available items, and purchase items from other users. The project will help you understand shared objects, ownership transfer, balance management, and permission checks in Sui Move. You will implement core marketplace logic, item management, and transaction handling.

### Modules Needed
- **marketplace**: Core logic for listing & buying items.
- **item**: Defines the structure of an item object.

### Objects
- **Item**
  - `id`: UID
  - `name`: string
  - `price`: u64
  - `owner`: address
- **Marketplace (shared object)**
  - Holds a vector of item IDs (listings).

### Functions
- `list_item(market: &mut Marketplace, name: string, price: u64)`
  - Creates new Item object, adds to marketplace.
- `buy_item(market: &mut Marketplace, item_id: ID, buyer: &mut Balance)`
  - Allows a user to purchase an item from the marketplace.
  - Transfers ownership of the item to the buyer.
  - Deducts the item's price from the buyer's balance and credits it to the seller.
  - Ensures the buyer has sufficient balance and the item is available for sale.
- `remove_item(market: &mut Marketplace, item_id: ID, caller: address)`
  - Only owner can delist.

### Constants
- Listing fee: `const LISTING_FEE: u64 = 1000;`

### Concepts Covered
- Shared objects
- Ownership transfer
- Balance deduction & addition
- Permission checks

---

Feel free to use or modify this structure. The goal is to implement the core logic and learn key concepts in Sui Move.

