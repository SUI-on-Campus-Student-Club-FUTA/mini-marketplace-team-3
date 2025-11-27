module sui_mini_marketplace::item;

use sui::object;
use sui::transfer;
use sui::tx_context;

struct Item has key, store {
    id: object::UID,
    name: string::String,
    price: u64,
    owner: address,
}

public fun new(
    name: string::String,
    price: u64,
    owner: address,
    ctx: &mut tx_context::TxContext,
): Item {
    Item {
        id: object::new(ctx),
        name,
        price,
        owner,
    }
}

public fun get_id(item: &Item): object::ID {
    object::uid_to_id(&item.id)
}

public fun get_owner(item: &Item): address {
    item.owner
}

public fun get_price(item: &Item): u64 {
    item.price
}

public fun transfer_ownership(item: &mut Item, new_owner: address) {
    item.owner = new_owner;
}

public fun delete(item: Item) {
    let Item { id, name: _, price: _, owner: _ } = item;
    id.delete();
}
