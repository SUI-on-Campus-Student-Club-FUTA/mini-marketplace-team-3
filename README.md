[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=20748796&assignment_repo_type=AssignmentRepo)

# Event Tickets Sui Move Project

This project is designed for students to practice and improve their skills. The structure below is a suggested starting point, but you are free to organize your code as you see fit.

## Project Overview

This project focuses on building a decentralized event ticketing system using Sui Move. Students will create smart contracts that allow organizers to set up events and sell tickets as unique digital assets, similar to NFTs. The system will handle ticket purchases, track ticket ownership, and ensure that only authorized organizers can validate ticket usage. Through this project, students will learn how to manage shared objects, implement state changes, and enforce role-based permissions within a blockchain environment. The goal is to provide hands-on experience with core concepts such as minting NFTs, updating state, and managing access control in smart contracts.

### Modules Needed
- **events**: Core logic for events & ticketing.
- **ticket**: NFT-like ticket structure.

### Objects
- **Event (shared object)**
  - `id: UID`
  - `name: string`
  - `ticket_price: u64`
  - `tickets_available: u64`
  - `organizer: address`
- **Ticket**
  - `id: UID`
  - `event_id: ID`
  - `owner: address`
  - `used: bool`

### Functions
- `create_event(name: string, ticket_price: u64, total: u64, organizer: address)`
  - Creates new event object.
- `buy_ticket(event: &mut Event, buyer: &mut Balance)`
  - Deducts balance.
  - Mints new Ticket.
  - Decreases tickets_available.
- `use_ticket(ticket: &mut Ticket, event: &mut Event, caller: address)`
  - Only organizer can mark as used.

### Constants
- `MAX_TICKETS: u64 = 1000;`

### Concepts Covered
- Shared objects
- Minting NFTs
- State updates (ticket count, ticket usage)
- Role-based actions (organizer vs. user)

---

**Note:** It is not compulsory to use the structure given above. This is just a headstart for you to have an idea on what to build. Each member of the team should work with this specification and improve upon it as needed.
