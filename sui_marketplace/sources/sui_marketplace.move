module sui_mini_marketplace::marketplace;

use sui::balance;
use sui::coin;
use sui::object::{Self, ID};
use sui::sui::SUI;
use sui::table::{Self, Table};
use sui::transfer;
use sui::tx_context;
use sui_mini_marketplace::item::{Self, Item};

/// Error codes
const ENotOwner: u64 = 1;
const EInsufficientFee: u64 = 2;
const EListingNotFound: u64 = 3;
const EInsufficientPayment: u64 = 4;

const LISTING_FEE: u64 = 1000;

/// A struct to hold the item data in the marketplace.
struct Listing has key, store {
    item_id: ID,
    price: u64,
    seller: address,
    listed_item: Item, // The actual Item object is now owned by the Listing/Marketplace
}

/// The Marketplace struct is a Shared Object
struct Marketplace has key {
    id: object::UID,
    listings: Table<ID, Listing>, // Maps Item ID to Listing
    treasury: balance::Balance<SUI>, // To collect fees
}

// --- Initialization ---

public fun init(ctx: &mut tx_context::TxContext) {
    let market = Marketplace {
        id: object::new(ctx),
        listings: table::new(ctx),
        treasury: balance::zero(),
    };
    // The Marketplace must be shared after creation
    transfer::share_object(market);
}

// --- Core Functions ---

/// Creates a Listing, transfers the Item ownership to the Marketplace
/// (via the Listing struct), and charges a fee.
public entry fun list_item(
    market: &mut Marketplace,
    item: Item, // The seller passes their owned Item object
    mut fee_coin: coin::Coin<SUI>,
    ctx: &mut tx_context::TxContext,
) {
    assert!(coin::value(&fee_coin) >= LISTING_FEE, EInsufficientFee);

    let seller = tx_context::sender(ctx);
    let item_id = item::get_id(&item);
    let price = item::get_price(&item);

    // 1. Charge Fee
    let listing_fee = coin::split(&mut fee_coin, LISTING_FEE);
    balance::join(&mut market.treasury, coin::into_balance(listing_fee));

    // 2. Transfer Item to Marketplace (via Listing struct)
    let listing = Listing {
        item_id,
        price,
        seller,
        listed_item: item, // The item is now owned by the Listing struct
    };

    // 3. Add to Listings Table
    table::add(&mut market.listings, item_id, listing);

    // 4. Return change to seller
    transfer::public_transfer(fee_coin, seller);
}

/// Allows a user to purchase an item.
public entry fun buy_item(
    market: &mut Marketplace,
    item_id: ID,
    mut payment: coin::Coin<SUI>,
    ctx: &mut tx_context::TxContext,
) {
    let buyer = tx_context::sender(ctx);

    // 1. Remove Listing from Marketplace
    assert!(table::contains(&market.listings, item_id), EListingNotFound);
    let Listing { item_id: _, price, seller, listed_item: mut item_obj } = table::remove(
        &mut market.listings,
        item_id,
    );

    // 2. Check and Handle Payment
    assert!(coin::value(&payment) >= price, EInsufficientPayment);

    // Split the payment into the seller's portion and change
    let (to_seller, change) = coin::split(&mut payment, price);

    // 3. Credit Seller
    transfer::public_transfer(to_seller, seller);

    // 4. Return Change to Buyer
    transfer::public_transfer(change, buyer);

    // 5. Update Item ownership and transfer to Buyer
    item::update_owner(&mut item_obj, buyer);
    transfer::public_transfer(item_obj, buyer);
}

/// Allows the original seller to remove their item from the marketplace.
public entry fun remove_item(
    market: &mut Marketplace,
    item_id: ID,
    ctx: &mut tx_context::TxContext,
) {
    let caller = tx_context::sender(ctx);

    // 1. Check if item is listed
    assert!(table::contains(&market.listings, item_id), EListingNotFound);
    let listing = table::borrow(&market.listings, item_id);

    // 2. Permission Check
    assert!(caller == listing.seller, ENotOwner);

    // 3. Remove Listing and Retrieve Item
    let Listing { item_id: _, price: _, seller: _, listed_item: item_obj } = table::remove(
        &mut market.listings,
        item_id,
    );

    // 4. Transfer Item back to the Seller
    transfer::public_transfer(item_obj, caller);
}
