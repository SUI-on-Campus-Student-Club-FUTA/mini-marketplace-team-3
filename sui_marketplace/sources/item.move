module {{YOUR_ADDRESS}}::item {

    use std::string;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    /// Represents a marketplace item.
    public struct Item has key, store {
        id: UID,
        name: string::String,
        price: u64,
        owner: address,
    }

    /// Create a new item.
    public fun new_item(
        name: string::String,
        price: u64,
        owner: address,
        ctx: &mut TxContext
    ): Item {
        Item {
            id: object::new(ctx),
            name,
            price,
            owner,
        }
    }

    /// Return the item's owner.
    public fun owner(item: &Item): address {
        item.owner
    }

    /// Return the item's price.
    public fun price(item: &Item): u64 {
        item.price
    }

    /// Transfer ownership to a new owner.
    public fun transfer_ownership(item: &mut Item, new_owner: address) {
        item.owner = new_owner;
    }
}
