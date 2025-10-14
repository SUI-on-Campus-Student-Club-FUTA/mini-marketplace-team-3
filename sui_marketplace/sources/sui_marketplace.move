module sui_mini_marketplace::marketplace {
    use sui::object;
    use sui::tx_context;
    use sui::transfer;
    use sui::balance;
    use sui::coin;
    use sui::sui;
    use sui_mini_marketplace::item;

    const LISTING_FEE: u64 = 1000;

    struct Marketplace has key {
        id: object::UID,
        listings: vector<object::ID>,
        owner: address,
    }

    public entry fun init(ctx: &mut tx_context::TxContext): Marketplace {
        let id = object::new(ctx);
        let owner = tx_context::sender(ctx);
        Marketplace { id, listings: vector::empty(), owner }
    }

    public entry fun list_item(
        market: &mut Marketplace,
        name: string::String,
        price: u64,
        mut fee: coin::Coin<sui::SUI>,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(coin::value(&fee) >= LISTING_FEE, 1);
        let seller = tx_context::sender(ctx);
        let item_obj = item::new(name, price, seller, ctx);
        let item_id = item::get_id(&item_obj);
        vector::push_back(&mut market.listings, item_id);
        transfer::share_object(item_obj);
        coin::burn(fee);
    }

    public entry fun buy_item(
        market: &mut Marketplace,
        item_id: object::ID,
        mut payment: coin::Coin<sui::SUI>,
        ctx: &mut tx_context::TxContext
    ) {
        let buyer = tx_context::sender(ctx);
        let item_ref = transfer::take_shared<Item>(item_id);
        let price = item::get_price(&item_ref);
        let owner = item::get_owner(&item_ref);
        assert!(coin::value(&payment) >= price, 2);

        let (to_seller, change) = coin::split(&mut payment, price);
        transfer::public_transfer(to_seller, owner);
        if coin::value(&change) > 0 {
            transfer::public_transfer(change, buyer);
        }

        let mut item_owned = item_ref;
        item::transfer_ownership(&mut item_owned, buyer);
        transfer::public_transfer(item_owned, buyer);

        vector::remove(&mut market.listings, item_id);
    }

    public entry fun remove_item(
        market: &mut Marketplace,
        item_id: object::ID,
        caller: address,
    ) {
        let item_ref = transfer::take_shared<Item>(item_id);
        let owner = item::get_owner(&item_ref);
        assert!(caller == owner, 3);

        let item_owned = item_ref;
        item::delete(item_owned);
        vector::remove(&mut market.listings, item_id);
    }
}
