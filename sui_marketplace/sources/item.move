module sui_mini_marketplace::item;

use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context;

/// The Item struct that will be owned by users.
struct Item has key, store {
    id: UID,
    name: string::String,
    price: u64,
    owner: address, // Redundant for owned objects, but useful for marketplace listing data
}

/// Creates a new Item and transfers it to the creator.
public fun new(name: string::String, price: u64, ctx: &mut tx_context::TxContext): Item {
    let sender = tx_context::sender(ctx);
    let item = Item {
        id: object::new(ctx),
        name,
        price,
        owner: sender,
    };
    // Transfer the newly created item to the transaction sender (creator)
    transfer::transfer(item, sender);
}

// --- Getters ---

public fun get_id(item: &Item): object::ID {
    object::uid_to_id(&item.id)
}

public fun get_owner(item: &Item): address {
    item.owner
}

public fun get_price(item: &Item): u64 {
    item.price
}

// --- Mutator ---

/// Updates the owner field when the item is purchased.
public fun update_owner(item: &mut Item, new_owner: address) {
    item.owner = new_owner;
}

/// Destroys the Item object.
public fun delete(item: Item) {
    let Item { id, name: _, price: _, owner: _ } = item;
    id.delete();
}
