# Proxy Standards 

### **1. Transparent Proxy Standard**
The Transparent Proxy pattern is a widely-used and simple proxy standard introduced by OpenZeppelin. It ensures a clear distinction between the proxy and the implementation contract roles.

Key Points:

* Admin & Users: The proxy has an admin (typically the contract owner) and regular users. Only the admin can interact with the proxy for upgrade functions, while users interact directly with the logic.
* Function Calls: The admin is restricted from calling functions that exist in the implementation contract (to prevent accidental execution of logic).
* Upgradeability: The proxy delegates all calls (except for admin upgrade calls) to the implementation contract using delegatecall.
* Usage: Best suited when the contract needs simple, upgradeable functionality with clear admin/user separation.
* Pros: Easy to implement and commonly used for straightforward upgrades.
* Cons: Slightly more expensive due to admin separation logic.

### **2. Universal Upgradeable Proxy Standard (UUPS)**
The UUPS proxy pattern is a more gas-efficient alternative to the Transparent Proxy, also used by OpenZeppelin. UUPS proxies rely on upgrade functions defined within the implementation contract itself, rather than the proxy contract.

Key Points:

* Upgradeable Logic: The upgrade function is implemented in the logic contract, allowing the contract to be self-upgradable.
* Minimal Proxy Logic: The proxy itself contains minimal logic and just forwards calls via delegatecall to the implementation.
* Efficiency: More gas-efficient compared to the Transparent Proxy because it lacks the admin logic.
* Admin Role: Requires careful handling of access control, usually using a role-based approach (e.g., onlyOwner).
* Pros: Lower gas costs during regular operations since admin logic is not required in the proxy contract.
* Cons: Requires more care in writing secure upgrade functions in the logic contract.

### 3. **Beacon Proxy**
The Beacon Proxy standard is useful when there are multiple proxies that need to point to the same implementation contract.

Key Points:

* Beacon Contract: A beacon is a contract that holds the address of the implementation logic. Proxies interact with the beacon, which provides the current implementation address.
* Multiple Proxies: Many proxy contracts can be linked to a single beacon, making it easy to upgrade all proxies by simply updating the implementation in the beacon.
* Upgrade Management: The beacon contract is responsible for managing the upgrade process, and all proxies interact with it to determine the current implementation.
* Pros: Centralized upgrade logic for multiple proxies, making mass upgrades efficient.
* Cons: Slightly more complex than Transparent or UUPS proxies. Involves an additional beacon contract.

### **4. Diamond Standard (EIP-2535)**
The Diamond Standard is a highly flexible and modular proxy mechanism that allows multiple logic contracts to be used and upgraded in a single contract.

Key Points:

* Facets: Instead of using a single implementation contract, the Diamond Standard allows a contract to delegate calls to multiple logic contracts (called facets).
* Function Selectors: The proxy routes calls to different facets based on function selectors.
* Modular Upgradeability: You can upgrade individual facets without affecting the rest of the contract.
* Size Limit: Solves the issue of contract size limits (24KB) by spreading functionality across multiple facets.
* Pros: Extremely modular and flexible, allowing upgrades and logic changes to parts of the contract without affecting the whole.
* Cons: Complex to implement and manage, requiring careful planning for routing function selectors and handling facets.

### **5. Minimal Proxy (Clones) (EIP-1167)**
The Minimal Proxy pattern, also known as Clones, is designed to deploy multiple instances of a contract with minimal deployment costs. It uses a minimal proxy contract that points to a single logic contract.

Key Points:

* Cheap Deployment: Minimal proxies reduce the gas cost by using a very small piece of bytecode to delegate all calls to a logic contract.
* Immutable Logic: The logic contract cannot be upgraded.
* Cloning: Often used for deploying large numbers of contract instances that share the same logic.
* Pros: Very cost-effective for deploying multiple instances of a contract.
* Cons: Lacks upgradeability. All proxies point to the same logic contract permanently.

### **6. ERC-897: Delegate Proxy**
This is a generic delegate proxy standard that defines how a proxy contract can forward function calls to another contract using delegatecall.

Key Points:

* Delegatecall: The proxy uses delegatecall to forward calls to an implementation contract.
* No Upgrade Mechanism: ERC-897 describes the behavior of delegate proxies but doesn’t prescribe an upgrade mechanism, so it can be implemented flexibly.
* Pros: Flexible standard, forming the basis for many other proxy mechanisms.
* Cons: No built-in upgradeability, requires additional mechanisms to implement upgrades.

These were some of the most common proxy standards out there. Hope you find these helpful!

### Thank you for reading ✨
